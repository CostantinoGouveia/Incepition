#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Permissões
chown -R mysql:mysql /var/lib/mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Inicialização
if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Arranca temporariamente
mariadbd --user=mysql --skip-networking --socket=/tmp/mysql.sock &
PID="$!"

# Espera o DB
for i in {1..30}; do
    if mariadb-admin --socket=/tmp/mysql.sock ping > /dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Configuração inicial
mariadb --socket=/tmp/mysql.sock <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

# Criar DB e user
mariadb --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}" <<EOF
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
CREATE DATABASE IF NOT EXISTS wordpress;
CREATE USER IF NOT EXISTS 'wp_user'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp_user'@'%';
FLUSH PRIVILEGES;
EOF

# Para e reinicia corretamente
mariadb-admin --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}" shutdown

wait "$PID"

exec mariadbd --user=mysql