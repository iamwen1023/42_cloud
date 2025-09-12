#!/bin/bash
set -euo pipefail

RUNTIME_DIR=/run/mysqld
DATA_DIR=/var/lib/mysql
SOCKET_PATH=${RUNTIME_DIR}/mysqld.sock

mkdir -p "${RUNTIME_DIR}"
chown -R mysql:mysql "${RUNTIME_DIR}"
chown -R mysql:mysql "${DATA_DIR}"
chmod 777 "${RUNTIME_DIR}"

# First-run initialization only when the system tables directory is missing
if [ ! -d "${DATA_DIR}/mysql" ]; then
  echo "Initializing MariaDB data directory..."
  mariadb-install-db --user=mysql --datadir="${DATA_DIR}" >/dev/null

  echo "Starting temporary MariaDB for initialization..."
  mysqld_safe --datadir="${DATA_DIR}" --skip-networking=0 --socket="${SOCKET_PATH}" &

  for i in {1..60}; do
    if mysqladmin ping --protocol=socket --socket="${SOCKET_PATH}" --silent; then
      break
    fi
    sleep 1
  done

  mysql --protocol=socket --socket="${SOCKET_PATH}" -uroot <<SQL
-- Fix root authentication: change from unix_socket to password auth
UPDATE mysql.user SET plugin='mysql_native_password' WHERE user='root' AND host='localhost';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${SQL_ROOT_PASSWORD}');
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';
FLUSH PRIVILEGES;
SQL

  mysqladmin --protocol=socket --socket="${SOCKET_PATH}" -uroot -p"${SQL_ROOT_PASSWORD}" shutdown || true
  touch "${DATA_DIR}/.configured"
fi

# Handle pre-existing data directory without configuration
if [ -d "${DATA_DIR}/mysql" ] && [ ! -f "${DATA_DIR}/.configured" ]; then
  echo "Existing data directory detected. Applying one-time root/password and schema setup via init-file..."
  INIT_SQL=$(mktemp /tmp/mariadb-init.XXXXXX.sql)
  cat >"${INIT_SQL}" <<SQL
-- Fix root authentication: change from unix_socket to password auth
UPDATE mysql.user SET plugin='mysql_native_password' WHERE user='root' AND host='localhost';
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('${SQL_ROOT_PASSWORD}');
-- create application database and user
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';
FLUSH PRIVILEGES;
SQL
  # Mark as configured before starting to avoid repeated attempts in restart loops
  touch "${DATA_DIR}/.configured"
  exec /usr/bin/mysqld_safe --datadir="${DATA_DIR}" --init-file="${INIT_SQL}"
fi

exec /usr/bin/mysqld_safe --datadir="${DATA_DIR}"
