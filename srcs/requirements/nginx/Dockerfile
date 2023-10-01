FROM debian:buster

# Update package lists and install Nginx and Openssl

RUN apt-get update -y && \
	apt-get -y install nginx openssl \
    && rm -rf /var/lib/apt/lists/*

# Generate a self-signed SSL certificate for Nginx

RUN openssl req -x509 \
	-nodes \
	-days 365 \
	-subj "/C=IT/ST=RM/O=42RomaLuiss/CN=ntozzi.42.fr" \
	-newkey rsa:2048 \
	-keyout /etc/ssl/private/nginx-selfsigned.key \
	-out /etc/ssl/certs/nginx-selfsigned.crt;

# Create a directory for SSL certificates

RUN mkdir -p /etc/ssl

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY setup/config.sh /bin/config.sh

EXPOSE 443

ENTRYPOINT [ "/bin/bash" , "/bin/config.sh" ]