FROM debian:bookworm

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y nginx curl openssl && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/nginx /var/www/wordpress

COPY conf/nginx.conf /etc/nginx/nginx.conf

RUN chmod 755 /var/www && chown -R www-data:www-data /var/www

CMD [ "nginx", "-g", "daemon off;" ]
