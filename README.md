# 42 Cloud Automated WordPress Deployment

This project deploys a TLS-enabled WordPress with MariaDB, Nginx, and phpMyAdmin using Docker Compose, and provides an Ansible playbook to fully automate provisioning on Ubuntu 20.04+ hosts over SSH.

## Prerequisites

- Ubuntu 20.04 LTS target with SSH and Python installed
- Your user has sudo privileges (password or NOPASSWD)
- Ansible installed on your control machine

## Quick start (local)

1. Copy `.env.example` to `.env` and fill in values.
2. Create bind-mount directories:
   - `/home/wlo/data/database`
   - `/home/wlo/data/wordpress`
3. Build and start:
   - `make build && make up`
4. Visit `https://<your-host>`
   - WordPress served at `/`
   - phpMyAdmin at `/phpmyadmin/`

## Ansible automated deployment

Inventory example (`inventory.ini`):

```
[web]
your_server_ip ansible_user=ubuntu ansible_python_interpreter=/usr/bin/python3
```

Run:

```
ansible-playbook -i inventory.ini ansible/site.yml
```

The playbook will:
- Install Docker, Docker Compose, and dependencies
- Push project files and `.env` variables
- Create data directories
- Build images and bring up the stack

## Services

- Nginx: TLS reverse proxy (443)
- WordPress: PHP-FPM (internal 9000)
- MariaDB: internal only (3306)
- phpMyAdmin: internal, proxied at `/phpmyadmin/`

# 42_cloud



docker compose down -v --remove-orphans 2>/dev/null || true

docker ps -aq | xargs -r docker rm -fv

docker images -aq | xargs -r docker rmi -f

docker volume ls -q | xargs -r docker volume rm -f

docker network ls -q | grep -vE '^(bridge|host|none)$' | xargs -r docker network rm


docker builder prune -af
docker system prune -af --volumes

sudo systemctl restart docker
