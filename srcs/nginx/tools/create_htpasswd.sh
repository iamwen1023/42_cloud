#!/bin/bash
set -euo pipefail

# Create htpasswd file for PHP-MyAdmin authentication
# Uses PHPMYADMIN_USER and PHPMYADMIN_PASSWORD from environment variables

ADMIN_USER=${PHPMYADMIN_USER:-admin}
ADMIN_PASSWORD=${PHPMYADMIN_PASSWORD:-ChangeMe_Admin_123}

# Create the htpasswd file
echo "${ADMIN_USER}:$(openssl passwd -apr1 "${ADMIN_PASSWORD}")" > /etc/nginx/.htpasswd

echo "Created htpasswd file for user: ${ADMIN_USER}"
echo "Access PHP-MyAdmin at: https://your-domain/phpmyadmin/"
echo "Username: ${ADMIN_USER}"
echo "Password: ${ADMIN_PASSWORD}"