FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y nginx curl openssl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/nginx /var/www/wordpress

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/create_htpasswd.sh /usr/local/bin/create_htpasswd.sh
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod 755 /var/www && chown -R www-data:www-data /var/www
RUN chmod +x /usr/local/bin/create_htpasswd.sh /usr/local/bin/entrypoint.sh

# Use runtime entrypoint to generate credentials and start Nginx
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
