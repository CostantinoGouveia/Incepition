#!/bin/bash
# Shebang: Indica que este é um script bash

set -e
# 'set -e' faz o script parar se qualquer comando falhar
# Evita que o WordPress tente iniciar sem base de dados configurada

# ========== LEITURA DAS PASSWORDS DOS SECRETS ==========
# Lê a password da base de dados do ficheiro de secrets (Docker Secrets)
# Docker Secrets é mais seguro que variáveis de ambiente
DB_PASSWORD=$(cat /run/secrets/db_password)

# Lê a password do utilizador editor do WordPress
# Este utilizador tem permissões reduzidas (não é administrador)
WP_EDITOR_PASSWORD=$(cat /run/secrets/wp_editor_password)

# Lê a password do utilizador administrador do WordPress
# Este é o utilizador principal com todas as permissões
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)

# ========== ESPERA PELA BASE DE DADOS ==========
# Loop que tenta conectar ao MariaDB durante até 60 segundos
# Isto é necessário porque o MariaDB pode levar tempo a iniciar completamente
# Usamos 60 segundos porque é um serviço remoto (noutro container)
for i in $(seq 1 60); do
    # Tenta fazer ping ao servidor MariaDB
    # -h"${DB_HOST}": Host do servidor (vem da variável de ambiente Docker)
    # -u"${MYSQL_USER}": Utilizador da base de dados
    # -p"${DB_PASSWORD}": Password do utilizador
    # > /dev/null 2>&1: Redireciona toda a saída para não aparecer no ecrã
    if mariadb-admin ping -h"${DB_HOST}" -u"${MYSQL_USER}" -p"${DB_PASSWORD}" > /dev/null 2>&1; then
        # Se o ping foi bem-sucedido, sai do loop
        break
    fi
    # Espera 1 segundo antes de tentar novamente
    sleep 1
done

# ========== NAVEGAR PARA O DIRECTÓRIO DO WORDPRESS ==========
# Muda para o directório onde o WordPress será instalado e executado
cd /var/www/html

# ========== VERIFICAÇÃO E INSTALAÇÃO DO WORDPRESS ==========
# Verifica se o ficheiro de configuração do WordPress já existe
# Se existe, significa que o WordPress já foi instalado noutras execuções
if [ ! -f wp-config.php ]; then
    # ========== DOWNLOAD DO WORDPRESS ==========
    # Faz download dos ficheiros do WordPress
    # --allow-root: Permite que wp-cli execute como root (necessário em containers)
    wp core download --allow-root

    # ========== CRIAÇÃO DA CONFIGURAÇÃO DO WORDPRESS ==========
    # Cria o ficheiro wp-config.php com os dados de conexão à base de dados
    wp config create \
        # --dbname: Nome da base de dados (vem da variável de ambiente)
        --dbname="${MYSQL_DATABASE}" \
        # --dbuser: Utilizador da base de dados
        --dbuser="${MYSQL_USER}" \
        # --dbpass: Password do utilizador da base de dados
        --dbpass="${DB_PASSWORD}" \
        # --dbhost: Host/endereço do servidor MariaDB na rede Docker
        --dbhost="${DB_HOST}" \
        # --allow-root: Permite execução como root
        --allow-root

    # ========== INSTALAÇÃO DO WORDPRESS ==========
    # Executa a instalação inicial do WordPress e cria o site
    wp core install \
        # --url: URL do site (deve ser HTTPS e usar o domínio configurado)
        --url="https://${DOMAIN_NAME}" \
        # --title: Título do site do WordPress
        --title="${WP_TITLE}" \
        # --admin_user: Username do utilizador administrador
        --admin_user="${WP_ADMIN_USER}" \
        # --admin_password: Password do utilizador administrador
        --admin_password="${WP_ADMIN_PASSWORD}" \
        # --admin_email: Email do utilizador administrador (para notificações)
        --admin_email="${WP_ADMIN_EMAIL}" \
        # --allow-root: Permite execução como root
        --allow-root

    # ========== CRIAÇÃO DE UTILIZADOR EDITOR ==========
    # Cria um utilizador secundário com permissões de editor (menos permissões que admin)
    # Isto é útil para permitir que outras pessoas editem conteúdo sem acesso total
    wp user create "${WP_EDITOR_USER}" "${WP_EDITOR_EMAIL}" \
        # "${WP_EDITOR_USER}": Username do novo utilizador (vem da variável de ambiente)
        # "${WP_EDITOR_EMAIL}": Email do novo utilizador
        # --role=editor: Define o papel/permissões do utilizador (editor tem permissões reduzidas)
        --role=editor \
        # --user_pass: Password do utilizador
        --user_pass="${WP_EDITOR_PASSWORD}" \
        # --allow-root: Permite execução como root
        --allow-root
fi

# ========== EXECUÇÃO DO PHP-FPM ==========
# Inicia o PHP-FPM (FastCGI Process Manager) que processa os ficheiros PHP
# exec substitui o processo actual do script - importante para Docker receber sinais SIGTERM
# -F: modo foreground (não daemoniza) - necessário para Docker saber quando o serviço está a correr
# 8.2: Versão do PHP que foi instalada no Dockerfile
exec php-fpm8.2 -F