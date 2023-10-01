#!/bin/bash

CONF=/var/www/html/wp-config.php

if [ -f "$CONF" ]; then
    echo "WordPress is already configured."
else
  
    sleep 5
    service php7.3-fpm start
    cd /var/www/html/

    # Download WordPress core
    
	wp core download --allow-root

    # Create WordPress config with values from the env file

    wp config create --dbname="$WP_DB_NAME" --dbuser="$WP_DB_USER" --dbpass="$WP_DB_PWD" --dbhost="$DB_HOST" --dbcharset="utf8" --dbcollate="utf8_general_ci" --allow-root

    # Install WordPress

    wp core install --url="$DOMAIN_NAME" --title="$WP_TITLE" --admin_user="$WP_ADMIN" --admin_password="$WP_ADMIN_PWD" --admin_email="$WP_ADMIN_EMAIL" --skip-email --allow-root

    # Create a user with the author role
    
	wp user create "$WP_USER" "$WP_USER_EMAIL" --role=author --user_pass="$WP_USER_PWD" --allow-root

    # Stop PHP-FPM
	
    service php7.3-fpm stop
fi

echo "Inception is up and running!"

# Start PHP-FPM in foreground

php-fpm7.3 -F