FROM debian:buster

RUN apt update -y && apt upgrade -y && \
	apt install -y php \
	php-fpm \
    php-mysql \
    php-gd \
    php-curl \
    php-zip \
    wget \
    mariadb-client

# Create a directory for PHP-FPM socket

RUN mkdir -p /run/php && chown www-data:www-data /run/php

# Create the /var/www/html directory and set permissions

RUN mkdir -p /var/www/html && chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \;

# Copy configuration files

COPY setup/config.sh /bin/config.sh
COPY conf/www.conf /etc/php/7.3/fpm/pool.d

# Download and install WP-CLI 

RUN wget -O /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
chmod +x /usr/local/bin/wp

WORKDIR /var/www/html

EXPOSE 9000
EXPOSE 3306

ENTRYPOINT [ "/bin/bash" , "/bin/config.sh" ]
