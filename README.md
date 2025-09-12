## 42 Cloud – WordPress on Docker with Ansible

This repo provisions a WordPress stack (Nginx + PHP-FPM + MariaDB) with Docker Compose and automates remote deployment via Ansible.

### Architecture (concepts)
- Nginx serves HTTP on port 80 and proxies PHP to `wordpress:9000`.
- WordPress runs PHP-FPM; configuration is automated by `srcs/wordpress/tools/auto_config.sh` using WP-CLI.
- MariaDB stores the application database. First-run initialization creates DB and user.
- Bind mounts persist data on the host (`DATA_DIR`), so container rebuilds don’t lose content.
- Health checks: MariaDB is healthy when it accepts `mysqladmin ping`; WordPress is healthy when `wp core is-installed` succeeds. Ansible waits on these.

### Directory layout
- `srcs/`: Dockerfiles, compose file, service configs
- `ansible/`: Playbook, roles, and deployment tasks
- `ansible/roles/app/tasks/main.yml`: copies project, writes remote `.env`, builds and starts stack

### Local run (optional)
1) Create data dirs and local `.env` in `srcs/` (example keys below).
2) Start:
```
cd srcs
docker compose up -d --build
```
3) Visit `http://localhost` (or the mapped port if you changed it).

### Environment variables (remote .env is templated by Ansible)
- Required:
  - `SQL_DATABASE`, `SQL_USER`, `SQL_PASSWORD`, `SQL_ROOT_PASSWORD`
  - `WORDPRESS_URL`, `WORDPRESS_TITLE`, `WORDPRESS_AMD_USER`, `WORDPRESS_AMD_USER_PSW`, `ADMIN_EMAIL`
  - `DATA_DIR` (host path for bind mounts; default via Ansible is `/root/data` or set to `/var/lib/42_cloud1`)

### Remote deployment (Ansible)
Prereqs on your control machine: Ansible installed; SSH access to Ubuntu host with sudo.

1) Create `ansible/inventory.ini` (do NOT commit secrets):
```
[web]
server1 ansible_host=<IP> ansible_user=root ansible_python_interpreter=/usr/bin/python3

[web:vars]
SQL_DATABASE=wordpress
SQL_USER=wp_user
SQL_PASSWORD=ChangeMe_WpDb_123
SQL_ROOT_PASSWORD=ChangeMe_Root_123
WORDPRESS_URL=http://<IP>
WORDPRESS_TITLE=My Local Blog
WORDPRESS_AMD_USER=admin
WORDPRESS_AMD_USER_PSW=ChangeMe_Admin_123
ADMIN_EMAIL=admin@example.com
DATA_DIR=/root/data
```

2) Deploy:
```
cd ansible
ansible-playbook -i inventory.ini site.yml
```

3) Verify on the host:
```
ssh root@<IP>
cd /opt/42_cloud1/srcs
docker compose ps
curl -I http://127.0.0.1
```

### Common operations
- Show logs:
```
cd /opt/42_cloud1/srcs && docker compose logs --tail=200 nginx wordpress mariadb
```
- Recreate everything (DESTROYS DATA):
```
cd /opt/42_cloud1/srcs && docker compose down -v
```
- Remote cleanup (from control machine):
```
ansible all -i ansible/inventory.ini -b -m shell -a "bash -lc 'cd /opt/42_cloud1/srcs && docker compose down -v || true; \
docker ps -aq | xargs -r docker rm -f; docker volume prune -f; docker image prune -af'"
```

### Troubleshooting
- WordPress exits with DB error 1130 (host not allowed): ensure MariaDB grants include `%` host and DB exists. Example inside DB container:
```
mysql -uroot -p"$SQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS \`$SQL_DATABASE\`; \
CREATE USER IF NOT EXISTS \`$SQL_USER\`@'%' IDENTIFIED BY '$SQL_PASSWORD'; \
GRANT ALL PRIVILEGES ON \`$SQL_DATABASE\`.* TO \`$SQL_USER\`@'%'; FLUSH PRIVILEGES;"
```
- Port 80 conflicts: stop host services `apache2`/`nginx`, or change compose port mapping.
- Health waits: Ansible prints logs on failure (MariaDB and WordPress) to aid debugging.

### Security notes
- Keep `ansible/inventory.ini` out of Git (add to `.gitignore`). Commit a redacted `inventory.sample.ini` for reference.
- Prefer `/var/lib/42_cloud1` or `/srv/42_cloud1` for `DATA_DIR` in production.
- Expose only Nginx (80); keep MariaDB internal to the Docker network.
