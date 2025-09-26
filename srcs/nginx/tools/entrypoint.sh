#!/bin/bash
set -euo pipefail

# Ensure htpasswd is generated at runtime using env-provided credentials
/usr/local/bin/create_htpasswd.sh

# Start Nginx in foreground
exec nginx -g "daemon off;" 