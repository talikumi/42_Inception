#!/bin/bash

MAGENTA="\e[35m"
RED="\e[31m"
YELLOW="\e[33m"
GREEN="\e[32m"
RESET="\e[0m"
CHECK="✔"

project_directory="/home/vboxuser/Desktop/Inception/srcs"
root_directory=/home/vboxuser/Desktop/Inception/

execute_command() {
  local description="$1"
  local command="$2"
  echo "${MAGENTA}${description} ${RESET}"
  echo "${YELLOW}Checking request...${RESET}"
  sleep 3
  eval "${command}"
  echo "${MAGENTA}---------------------------------------${RESET}"
  echo ""
  sleep 5
}

# Function to check for the presence of a word in a file

check_word_in_file() {
  local word="$1"
  local file="$2"
  if grep -q "$word" "$file"; then
    echo "${GREEN}The word '${word}' is found in this file.${RESET}"
  else
    echo "${GREEN}The word '${word}' is not found in this file.${RESET}"
  fi
}

echo ""

# Request 1: Check Docker Compose file for specific words 'network:host' or 'links:'

execute_command "Checking Docker Compose file for 'network:host' and 'links:' (must not be present)": \
"check_word_in_file 'network:host' '${project_directory}/docker-compose.yml'; check_word_in_file 'links:' '${project_directory}/docker-compose.yml'"

# Request 2: Check Docker Compose file for specific words 'network' or 'networks'

execute_command "Checking Docker Compose file for 'network' or 'networks' (must be present):" \
"check_word_in_file 'network' '${project_directory}/docker-compose.yml'; check_word_in_file 'networks' '${project_directory}/docker-compose.yml'"

# Request 3: Check Makefile and script files for specific word '--link' (must not be present)

echo "${MAGENTA}Checking Makefile for '--link' (must not be present):${RESET}"
echo "${YELLOW}Checking request...${RESET}"
sleep 3
if grep -q -- "--link" "${root_directory}/Makefile"; then
    echo "${RED}The word '--link' is found in this file.${RESET}"
else
    echo "${GREEN}The word '--link' is not found in this file.${RESET}"
fi

sleep 3

# Loop through all .sh files in the root directory to search for specific word '--link'

find "${root_directory}" -type f -name "*.sh" | while read -r script_file; do
  echo ""
  echo "${MAGENTA}Checking $(basename "$script_file") for '--link' (must not be present):${RESET}"
  echo "${YELLOW}Checking request...${RESET}"
  sleep 3
  if grep -q -- "--link" "$script_file"; then
    echo "${RED}The word '--link' is found in this file.${RESET}"
  else
    echo "${GREEN}The word '--link' is not found in this file.${RESET}"
  fi
done
echo "${MAGENTA}---------------------------------------${RESET}"
echo ""

# Request 4: Check Dockerfiles for the presence of 'tail -f' or background commands in the entrypoint section

find "${project_directory}" -type f -name "Dockerfile" | while read -r dockerfile; do
  execute_command "Checking $(basename "$dockerfile") for 'tail -f' or background commands in entrypoint (must not be present):" \
  "if grep -q -E 'ENTRYPOINT.*tail -f|ENTRYPOINT.*&' '$dockerfile'; then
    echo '${RED}Tail -f or bg commands found in this file.${RESET}'
  else
    echo '${GREEN}Tail -f or bg commands are not found in this file.${RESET}'
  fi"
done

# Request 5: Ensure entrypoint scripts don't run programs in the background

find "${root_directory}" -type f -name "*.sh" | while read -r script_file; do
  execute_command "Checking $(basename "$script_file") for background commands in entrypoints (must not be present):" \
  "if grep -r -E '.*&' '$script_file'; then
    echo '${RED}Background commands found in this file.${RESET}'
  else
    echo '${GREEN}Background commands are not found in this file.${RESET}'
  fi"
done

# Request 6: Ensure no scripts run an infinite loop with commands 'sleep infinity', 'tail -f /dev/null' or 'tail -f /dev/random'

find "${root_directory}" -type f -name "*.sh" | while read -r script_file; do
  if grep -q -r -E 'sleep infinity|tail -f /dev/null|tail -f /dev/random' "$script_file"; then
    execute_command "Checking for infinite loops in script file (must not be present):" \
      "echo '${RED}Infinite loop commands found.${RESET}'"
  else
    execute_command "Checking for infinite loops in script file (must not be present):" \
      "echo '${GREEN}No infinite loop commands found.${RESET}'"
  fi
done

# Request 8: Ensure all files to config are located inside the srcs folder

execute_command "Checking if config files are located inside the srcs folder:" \
"ls '${project_directory}'"

# Request 9: Ensure srcs and the Makefile are located inside the root folder

execute_command "Checking if the srcs directory and Makefile are inside the root folder:" \
"ls '${root_directory}'"

# Request 15: Ensure WordPress is installed and accessible via HTTPS

if curl -I -k https://ntozzi.42.fr &>/dev/null; then
  execute_command "Verifying WordPress installation via HTTPS (must work):" \
    "echo '${GREEN}WordPress is installed and accessible via HTTPS.${RESET}'"
else
  execute_command "Verifying WordPress installation via HTTPS (must work):" \
    "echo '${RED}WordPress is not installed or not accessible via HTTPS.${RESET}'"
fi

# Request 16: Ensure WordPress is installed and verify it is not accessible via HTTP

final_url=$(curl -I -L http://ntozzi.42.fr 2>/dev/null | awk '/^Location: / { print $2 }' | tr -d '\r\n')

if [ "$final_url" = "https://"* ]; then
  execute_command "Verifying WordPress installation via HTTP (must fail):" \
    "echo '${RED}WordPress is not installed or not accessible via HTTP.${RESET}'"
else
  execute_command "Verifying WordPress installation via HTTP (must fail):" \
    "echo '${GREEN}WordPress is not accessible via HTTP.${RESET}'"
fi


# Request 21: Try to access the service through port 80 and capture the response status code

response_code=$(curl -s -o /dev/null -w "%{http_code}" http://localhost)
if [ "$response_code" -eq 200 ]; then
  execute_command "Trying to access the service through port 80 (must fail):" \
    "echo '${RED}Connection to port 80 succeeded (Response code: $response_code).${RESET}'"
else
  execute_command "Trying to access the service through port 80 (must fail):" \
    "echo '${GREEN}Connection to port 80 failed (Response code: $response_code).${RESET}'"
fi

# Request 19: Ensure Docker images have specific names (mariadb, wordpress, nginx)

if docker images | grep -q -E 'mariadb|wordpress|nginx'; then
  execute_command "Checking for specific Docker image names (mariadb, wordpress, nginx):" \
    "echo '${GREEN}All required Docker images are found.${RESET}'"
else
  execute_command "Checking for specific Docker image names (mariadb, wordpress, nginx):" \
    "echo '${RED}One or more required Docker images are missing.${RESET}'"
fi

# Request 22: Use 'docker-compose ps' to check WordPress container

if docker ps | grep -q "wordpress"; then
  execute_command "Checking WordPress container using 'docker-compose ps':" \
    "echo '${GREEN}WordPress container is running.${RESET}'"
else
  execute_command "Checking WordPress container using 'docker-compose ps':" \
    "echo '${RED}WordPress container is not running.${RESET}'"
fi

# Request 22: Use 'docker-compose ps' to check MariaDB container

if docker ps | grep -q "mariadb"; then
  execute_command "Checking MariaDB container using 'docker-compose ps':" \
    "echo '${GREEN}MariaDB container is running.${RESET}'"
else
  execute_command "Checking MariaDB container using 'docker-compose ps':" \
    "echo '${RED}MariaDB container is not running.${RESET}'"
fi

# Request 22: Use 'docker-compose ps' to check Nginx container

if docker ps | grep -q "nginx"; then
  execute_command "Checking Nginx container using 'docker-compose ps':" \
    "echo '${GREEN}Nginx container is running.${RESET}'"
else
  execute_command "Checking Nginx container using 'docker-compose ps':" \
    "echo '${RED}Nginx container is not running.${RESET}'"
fi

# Inspect the volume and check its device field

volume_device=$(docker volume inspect wordpress --format '{{ .Options.device }}')
expected_device="/home/ntozzi.42.fr/data/wordpress/"

if [ "$volume_device" = "$expected_device" ]; then
  execute_command "Checking the device path of wordpress using 'docker volume inspect wordpress':" \
    "echo '${GREEN}Device path is correct: $expected_device.${RESET}'"
else
  execute_command "Checking the device path of wordpress using 'docker volume inspect wordpress':" \
    "echo '${RED}Device path is incorrect: $volume_device.${RESET}'"
fi

# Inspect the volume and check its device field

volume_device=$(docker volume inspect db --format '{{ .Options.device }}')
expected_device="/home/ntozzi.42.fr/data/db/"

if [ "$volume_device" = "$expected_device" ]; then
  execute_command "Checking the device path of db using 'docker volume inspect db':" \
    "echo '${GREEN}Device path is correct: $expected_device.${RESET}'"
else
  execute_command "Checking the device path of db using 'docker volume inspect db':" \
    "echo '${RED}Device path is incorrect: $volume_device.${RESET}'"
fi

# Request 10: Run Docker commands to stop containers, remove containers, images, volumes, and networks

execute_command "Stopping containers:" \
  "docker stop \$(docker ps -qa)" 

execute_command "Removing containers:" \
  "docker rm \$(docker ps -qa)"

execute_command "Removing images:" \
  "docker rmi -f \$(docker images -qa)"

execute_command "Removing volumes:" \
  "docker volume rm \$(docker volume ls -q)"

execute_command "Removing networks:" \
  "docker network rm \$(docker network ls -q) 2>/dev/null"

# Request 11: Ensure docker-network is used in the compose file

execute_command "Checking if 'docker-network' is used in the Docker Compose file:" \
"if grep -q 'networks' '${project_directory}/docker-compose.yml'; then
  echo '${GREEN}docker-network found in this file.${RESET}'
else
  echo '${RED}docker-network is not found in this file.${RESET}'
fi"

# Request 12: List Docker networks

execute_command "Listing Docker Networks:" \
"docker network ls"

# Request 13: Check for the word "443" in Nginx config

execute_command "Checking Nginx config file for 443 (must be present):" \
"check_word_in_file '443' '${project_directory}/requirements/nginx/conf/nginx.conf';"

# Request 14: Ensure an SSL/TLS certificate is used

execute_command "Checking Nginx config file for SSL certificate (must be present):" \
"check_word_in_file 'ssl_certificate' '${project_directory}/requirements/nginx/conf/nginx.conf';"

# Request 17: Ensure one Dockerfile per service (WordPress, MariaDB, NGINX) and that they are not empty

if [ -f "${project_directory}/requirements/wordpress/Dockerfile" ] && \
   [ -f "${project_directory}/requirements/mariadb/Dockerfile" ] && \
   [ -f "${project_directory}/requirements/nginx/Dockerfile" ]; then
  execute_command "Checking for Dockerfiles, one Dockerfile per service (WordPress, MariaDB, NGINX) and that they are not empty:" \
    "echo '${GREEN}All Dockerfiles exist.${RESET}'"
else
  execute_command "Checking for Dockerfiles, one Dockerfile per service (WordPress, MariaDB, NGINX) and that they are not empty:" \
    "echo '${RED}One or more Dockerfiles are missing.${RESET}'"
fi

# Request 18: Ensure every container is built from the penultimate stable version of Alpine Linux or Debian Buster

if grep -q -r 'FROM alpine:3.' "${project_directory}/requirements/mariadb/Dockerfile" || grep -q -r 'FROM debian:buster' "${project_directory}/requirements/mariadb/Dockerfile"; then
  execute_command "Checking Alpine Linux and Debian Buster versions in MariaDB Dockerfile:" \
    "echo '${GREEN}Correct Alpine Linux or Debian Buster version found in MariaDB Dockerfile.${RESET}'"
else
  execute_command "Checking Alpine Linux and Debian Buster versions in MariaDB Dockerfile:" \
    "echo '${RED}Neither Alpine Linux nor Debian Buster version is found in MariaDB Dockerfile.${RESET}'"
fi

# Request 18: Ensure every container is built from the penultimate stable version of Alpine Linux or Debian Buster

if grep -q -r 'FROM alpine:3.' "${project_directory}/requirements/nginx/Dockerfile" || grep -q -r 'FROM debian:buster' "${project_directory}/requirements/nginx/Dockerfile"; then
  execute_command "Checking Alpine Linux and Debian Buster versions in Nginx Dockerfile:" \
    "echo '${GREEN}Correct Alpine Linux or Debian Buster version found in Nginx Dockerfile.${RESET}'"
else
  execute_command "Checking Alpine Linux and Debian Buster versions in Nginx Dockerfile:" \
    "echo '${RED}Neither Alpine Linux nor Debian Buster version is found in Nginx Dockerfile.${RESET}'"
fi

# Request 18: Ensure every container is built from the penultimate stable version of Alpine Linux or Debian Buster

if grep -q -r 'FROM alpine:3.' "${project_directory}/requirements/wordpress/Dockerfile" || grep -q -r 'FROM debian:buster' "${project_directory}/requirements/wordpress/Dockerfile"; then
  execute_command "Checking Alpine Linux and Debian Buster versions in Wordpress Dockerfile:" \
    "echo '${GREEN}Correct Alpine Linux or Debian Buster version found in Wordpress Dockerfile.${RESET}'"
else
  execute_command "Checking Alpine Linux and Debian Buster versions in Wordpress Dockerfile:" \
    "echo '${RED}Neither Alpine Linux nor Debian Buster version is found in Wordpress Dockerfile.${RESET}'"
fi

# Request 20: Ensure the Makefile sets up all services via Docker Compose without crashing

execute_command "Checking Docker Compose file for 'restart:always' (must be present to prevent crashing):" \
"check_word_in_file 'restart: always' '${project_directory}/docker-compose.yml';"

# Request 29: Ensure a TLSv1.2 or 1.3 is used

execute_command "Checking server config for 'TLSv1.2' or 'TLSv1.3' (must be present):" \
"check_word_in_file 'TLSv1.2' '${project_directory}/requirements/nginx/conf/nginx.conf'; check_word_in_file 'TLSv1.3' '${project_directory}/requirements/nginx/conf/nginx.conf'"

echo "${GREEN}Script execution complete. ${CHECK}${RESET}"
