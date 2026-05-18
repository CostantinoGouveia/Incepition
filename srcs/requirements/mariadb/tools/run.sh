#!/bin/bash
# Shebang: Indica que este é um script bash

set -e
# 'set -e' faz o script parar se qualquer comando falhar
# Isto é importante para evitar erros em cascata

# Lê a senha do banco de dados do ficheiro de secrets (Docker Secrets)
# Docker Secrets é mais seguro que variáveis de ambiente pois não aparecem em ps ou inspect
DB_PASSWORD=$(cat /run/secrets/db_password)

# Lê a senha root do ficheiro de secrets
# Usamos uma senha root forte para segurança da base de dados
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Inicializa a variável INITIALIZED para controlar se é primeira execução
INITIALIZED=0

# ========== SECÇÃO DE PERMISSÕES ==========
# Muda o dono dos diretórios para o utilizador mysql
# Isto é necessário porque MariaDB precisa de acesso aos seus próprios directórios
chown -R mysql:mysql /var/lib/mysql
# Cria o diretório de runtime do MySQL se não existir
mkdir -p /run/mysqld
# Muda o dono do diretório de runtime para mysql
chown -R mysql:mysql /run/mysqld

# ========== SECÇÃO DE INICIALIZAÇÃO ==========
# Verifica se é a primeira execução (se a pasta de dados não existe)
if [ ! -d "/var/lib/mysql/mysql" ]; then
    # Marca como primeira inicialização
    INITIALIZED=1
    # Cria a estrutura inicial da base de dados
    # --user=mysql: Executa com permissões do utilizador mysql
    # --datadir=/var/lib/mysql: Define o diretório de armazenamento
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# ========== ARRANQUE TEMPORÁRIO ==========
# Inicia o MariaDB em modo de fundo (background) para configuração inicial
# --user=mysql: Executa com permissões do utilizador mysql
# --skip-networking: Desativa rede (segurança: só conexão local por socket)
# --socket=/tmp/mysql.sock: Usa socket Unix local para comunicação
# & no final: Coloca o processo em background
mariadbd --user=mysql --skip-networking --socket=/tmp/mysql.sock &
# Guarda o ID do processo para depois esperar ou terminar
PID="$!"

# ========== PREPARAÇÃO DO COMANDO DE PING ==========
# Verifica se é primeira inicialização para determinar comando de ping
if [ "$INITIALIZED" -eq 1 ]; then
    # Se é primeira inicialização, root ainda não tem password
    PING_CMD=(mariadb-admin --socket=/tmp/mysql.sock -uroot)
else
    # Se já existe base de dados, root precisa de password
    PING_CMD=(mariadb-admin --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}")
fi

# ========== ESPERA PELO ARRANQUE DO DB ==========
# Loop que tenta conectar ao MariaDB durante até 30 segundos
# Isto garante que o DB tem tempo para iniciar antes de prosseguir
for i in $(seq 1 30); do
    # Executa o comando de ping armazenado em PING_CMD
    # >/dev/null 2>&1 redireciona toda a saída para não aparecer no ecrã
    if "${PING_CMD[@]}" ping >/dev/null 2>&1; then
        # Se o ping foi bem-sucedido, sai do loop
        break
    fi
    # Espera 1 segundo antes de tentar novamente
    sleep 1
done

# ========== VALIDAÇÃO DO ARRANQUE ==========
# Verifica se o DB está realmente acessível após os 30 segundos
if ! "${PING_CMD[@]}" ping >/dev/null 2>&1; then
    # Se ainda não esta acessível, imprime erro e termina
    # >&2 redireciona para stderr (stream de erros) em vez de stdout
    echo "ERRO: MariaDB nao arrancou a tempo." >&2
    exit 1
fi

# ========== CONFIGURAÇÃO INICIAL (PRIMEIRA EXECUÇÃO) ==========
# Se é primeira inicialização, configura a password do root
if [ "$INITIALIZED" -eq 1 ]; then
    # Usa heredoc (<<-SQL) para executar múltiplos comandos SQL
    # A password é inserida através de variável de ambiente
    mariadb --socket=/tmp/mysql.sock -uroot <<-SQL
	# Altera a password do utilizador root
	# 'localhost' significa que root só pode conectar localmente
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
	# Aplica as mudanças de permissões imediatamente
	FLUSH PRIVILEGES;
	SQL
fi

# ========== CRIAÇÃO DA BASE DE DADOS E UTILIZADOR ==========
# Cria a base de dados para WordPress e o utilizador que a acede
# Isto é executado em todas as inicializações (IF NOT EXISTS evita erro se já existir)
mariadb --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}" <<-SQL
# Cria a base de dados para WordPress (a variável vem das env do Docker)
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
# Cria o utilizador WordPress
# '%' significa que pode conectar de qualquer host (necessário em rede Docker)
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
# Dá todas as permissões ao utilizador WordPress na sua base de dados
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
# Aplica as mudanças de permissões imediatamente
FLUSH PRIVILEGES;
SQL

# ========== DESLIGAMENTO E REINÍCIO FINAL ==========
# Desliga o MariaDB que está a correr com --skip-networking
# Isto força um encerramento limpo
mariadb-admin --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}" shutdown

# Espera que o processo com PID=$PID termine
# || true significa que mesmo que o processo já tenha terminado, o comando não falha
wait "$PID" || true

# ========== EXECUÇÃO FINAL DO SERVIÇO ==========
# Inicia o MariaDB em modo de produção
# exec substitui o processo actual (importante para Docker receber sinais)
# --bind-address=0.0.0.0: Escuta em todas as interfaces de rede
# Isto é necessário porque o WordPress está noutro container (rede Docker)
exec mariadbd --user=mysql --bind-address=0.0.0.0