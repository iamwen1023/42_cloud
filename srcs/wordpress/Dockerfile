FROM debian:bookworm
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y wget vim \
                       php php-fpm php-mysql php-curl php-gd php-mbstring \
                       php-xml php-zip php-intl mariadb-client net-tools && \
    rm -rf /var/lib/apt/lists/*

RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www && \
    cd /var/www && \
    tar -xzf wordpress-6.0-fr_FR.tar.gz && \
    rm wordpress-6.0-fr_FR.tar.gz

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# FIX: Change ownership to www-data and set proper permissions
RUN chown -R www-data:www-data /var/www/wordpress
RUN chmod -R 755 /var/www/wordpress
RUN chmod 644 /var/www/wordpress/wp-config-sample.php

RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

COPY ./conf/php-fpm.conf /etc/php/8.2/fpm/php-fpm.conf
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/auto_config.sh /etc/auto_config.sh

# FIX: Make script executable
RUN chmod +x /etc/auto_config.sh

# FIX: Add working directory and user
WORKDIR /var/www/wordpress
USER www-data

CMD bash /etc/auto_config.sh



# 1. recopier les fichiers de configuration php-fpm.conf et pool.d/www.conf + Copy dans le docker file
# 2. optionnel : rediriger les logs dans stdout et stderr dans le fichier php-fpm.conf
# 3. dans le docker file : CMD > php-fpm7.3
# 4. Creer le dossier /run/php avec + chown www-data depuis le dockerfile
# 5. Faire des tests dans firefox et regarder les logs nginx + phpfpm pour avancer
# 6. Optionnel : installer net-tools depuis le docker fil pour voir si le port 9000 est en ecoute sur wordpress avec la commande "netstat -tunlp | grep 9000"

