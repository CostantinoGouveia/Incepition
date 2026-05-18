# ========== BASE DO CONTAINER ==========
# Usa Debian oldstable como imagem base (versão estável anterior da Debian)
# Debian é leve, estável e tem bom suporte para bases de dados
# oldstable garante stabilidade e receberá suporte prolongado
FROM debian:oldstable

# ========== INSTALAÇÃO DE PACOTES ==========
# Actualiza o repositório de pacotes antes de instalar
# && chain permite múltiplos comandos na mesma camada Docker (mais eficiente)
RUN apt-get update && apt-get install -y mariadb-server mariadb-client \
    # mariadb-server: O servidor de base de dados MariaDB em si
    # É o software que vai guardar e gerir os dados do WordPress
    # mariadb-client: Ferramentas de cliente para interagir com o MariaDB
    # Inclui mariadb-admin, mariadb, etc - usadas no script run.sh
    && rm -rf /var/lib/apt/lists/*
    # rm -rf /var/lib/apt/lists/*: Remove os ficheiros de cache do apt
    # Isto reduz o tamanho da imagem Docker (não precisa guardar histórico)

# ========== COPIAR FICHEIROS DE CONFIGURAÇÃO ==========
# Copia o ficheiro de configuração específico do MariaDB
# conf/50-server.cnf: Configuração do servidor (settings do MariaDB)
# As configurações customizadas permitem ajustar performance, limite de conexões, etc
COPY conf/50-server.cnf /etc/mysql/mariadb.cnf.d/50-server.cnf

# ========== COPIAR O SCRIPT DE INICIALIZAÇÃO ==========
# Copia o script run.sh do container host para o container Docker
# tools/run.sh: O script que vimos comentado acima
# /usr/local/bin/run.sh: Destino (é prático ter scripts em /usr/local/bin)
COPY tools/run.sh /usr/local/bin/run.sh

# ========== TORNAR O SCRIPT EXECUTÁVEL ==========
# Dá permissão de execução ao script run.sh
# chmod +x: Adiciona permissão de execução ao ficheiro
# Sem isto, o sistema não consegue executar o script
RUN chmod +x /usr/local/bin/run.sh

# ========== EXPOSIÇÃO DE PORTAS ==========
# Expõe a porta 3306 (porta padrão do MySQL/MariaDB)
# Isto avisa ao Docker e a quem usa a imagem que este container pode escutar nesta porta
# EXPOSE é apenas documentação - a porta precisa ser mapeada no docker-compose.yml
EXPOSE 3306

# ========== COMANDO DE INICIALIZAÇÃO ==========
# Define o comando que será executado quando o container iniciar
# CMD marca este como o comando padrão (pode ser substituído no docker run)
# ["/usr/local/bin/run.sh"]: Executa o script que prepara e inicia o MariaDB
CMD ["/usr/local/bin/run.sh"]