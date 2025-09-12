#!/bin/bash
set -euo pipefail

WP_PATH="/var/www/wordpress"
DB_HOST="mariadb:3306"

# Wait for MariaDB to be ready
for i in {1..60}; do
  if mysqladmin ping -hmariadb -uroot -p"${SQL_ROOT_PASSWORD}" --silent >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Ensure WordPress files exist (downloaded in Dockerfile), skip re-download

# Configure wp-config.php
if [ -f "${WP_PATH}/wp-config.php" ]; then
  # Update DB constants to match env (quoted strings, not raw)
  wp config set DB_NAME     "${SQL_DATABASE}" --path="${WP_PATH}" --type=constant --quiet || true
  wp config set DB_USER     "${SQL_USER}"     --path="${WP_PATH}" --type=constant --quiet || true
  wp config set DB_PASSWORD "${SQL_PASSWORD}" --path="${WP_PATH}" --type=constant --quiet || true
  wp config set DB_HOST     "${DB_HOST}"      --path="${WP_PATH}" --type=constant --quiet || true
else
  wp config create --dbname="${SQL_DATABASE}" --dbuser="${SQL_USER}" --dbpass="${SQL_PASSWORD}" --dbhost="${DB_HOST}" --path="${WP_PATH}" --quiet
fi

# Do not create the database via wp; MariaDB init handles it

# Install WordPress only if not installed
if ! wp core is-installed --path="${WP_PATH}" >/dev/null 2>&1; then
  wp core install \
    --url="${WORDPRESS_URL}" \
    --title="${WORDPRESS_TITLE}" \
    --admin_user="${WORDPRESS_AMD_USER}" \
    --admin_password="${WORDPRESS_AMD_USER_PSW}" \
    --admin_email="${ADMIN_EMAIL}" \
    --path="${WP_PATH}" --quiet
fi

# Ensure an example author exists (idempotent)
if ! wp user get bob --field=ID --path="${WP_PATH}" >/dev/null 2>&1; then
  wp user create bob bob@example.com --user_pass="${SQL_PASSWORD}" --role=author --path="${WP_PATH}" --quiet
fi

# Ensure theme is installed and active
if ! wp theme is-installed astra --path="${WP_PATH}" >/dev/null 2>&1; then
  wp theme install astra --path="${WP_PATH}" --quiet
fi
wp theme activate astra --path="${WP_PATH}" --quiet || true

/usr/sbin/php-fpm8.2 --nodaemonize
