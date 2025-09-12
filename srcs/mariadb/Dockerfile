FROM debian:bookworm

RUN apt-get update -y && \
    apt-get install -y vim mariadb-server && \
    rm -rf /var/lib/apt/lists/*

COPY conf/my.cnf /etc/mysql/my.cnf
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/db_config.sh /usr/local/bin/db_config.sh

RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    chmod 777 /run/mysqld && \
    chmod +x /usr/local/bin/db_config.sh

ENTRYPOINT ["/usr/local/bin/db_config.sh"]