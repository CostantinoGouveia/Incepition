#!/bin/bash
set -e

DB_PASSWORD=$(cat /run/secrets/db_password)

DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

INITIALIZED=0
# Permissões
chown -R mysql:mysql /var/lib/mysql
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Inicialização
if [ ! -d "/var/lib/mysql/mysql" ]; then
    INITIALIZED=1
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql
fi

# Arranca temporariamente
mariadbd --user=mysql --skip-networking --socket=/tmp/mysql.sock &
PID="$!"

if [ "$INITIALIZED" -eq 1 ]; then
    PING_CMD=(mariadb-admin --socket=/tmp/mysql.sock -uroot)
else
    PING_CMD=(mariadb-admin --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}")
fi

# Espera o DB
for i in $(seq 1 30); do
    if "${PING_CMD[@]}" ping >/dev/null 2>&1; then
        break
    fi
    sleep 1
done


if ! "${PING_CMD[@]}" ping >/dev/null 2>&1; then
    echo "ERRO: MariaDB nao arrancou a tempo." >&2
    exit 1
fi

# Configuração inicial
if [ "$INITIALIZED" -eq 1 ]; then
    mariadb --socket=/tmp/mysql.sock -uroot <<-SQL
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
	FLUSH PRIVILEGES;
	SQL
fi

# Criar DB e user
mariadb --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}" <<-SQL
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
SQL

# Para e reinicia corretamente
mariadb-admin --socket=/tmp/mysql.sock -uroot -p"${DB_ROOT_PASSWORD}" shutdown

wait "$PID" || true

exec mariadbd --user=mysql --bind-address=0.0.0.0