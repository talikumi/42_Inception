#!/bin/sh

# Create the directory if it doesn't exist

if [ ! -d "/run/mysqld" ]; then
    mkdir -p /run/mysqld
    chown -R mysql:mysql /run/mysqld
fi

# Check if MariaDB system tables exist and initialize if not

if [ ! -d "/var/lib/mysql/mysql" ]; then
    chown -R mysql:mysql /var/lib/mysql

    # Initialize the db

    mysql_install_db --basedir=/usr --datadir=/var/lib/mysql --user=mysql --rpm > /dev/null

    # Create a temp SQL file

    tmp=$(mktemp)
    if [ ! -f "$tmp" ]; then
        echo "Failed to create a temporary SQL file."
        exit 1
    fi

    # Write SQL commands to the temp test file

    cat <<EOF >"$tmp"
USE mysql;
FLUSH PRIVILEGES;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test';
DELETE FROM mysql.user WHERE User='${DB_ROOT}' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
ALTER USER '${DB_ROOT}'@'localhost' IDENTIFIED BY '${DB_ROOT_PWD}';
CREATE DATABASE ${WP_DB_NAME} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '${WP_DB_USER}'@'%' IDENTIFIED BY '${WP_DB_PWD}';
GRANT ALL PRIVILEGES ON ${WP_DB_NAME}.* TO '${WP_DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # Execute mysqld in bootstrap mode

    /usr/bin/mysqld --user=mysql --bootstrap < "$tmp"
    rm -f "$tmp"
fi

# Update MariaDB config

sed -i "s|skip-networking|# skip-networking|g" /etc/my.cnf.d/mariadb-server.cnf
sed -i "s|.*bind-address\s*=.*|bind-address=0.0.0.0|g" /etc/my.cnf.d/mariadb-server.cnf

# Start MariaDB

exec /usr/bin/mysqld --user=mysql --console