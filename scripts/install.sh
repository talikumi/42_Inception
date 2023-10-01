#!/bin/bash

MAG="\e[95m"
YELLOW="\e[33m"
GREEN="\e[92m"
CHECK="✔"
RE="\e[0m"

# Update system

echo "${MAG}Updating packages...${RE}"
sudo apt-get update -qq
#sudo apt upgrade -y -qq
echo "${GREEN}Success! ${CHECK}${RE}"

# Install utilities

echo "${MAG}Installing dependencies...${RE}"
sudo apt-get install -y -qq \
    ca-certificates \
    curl \
    gnupg \
    vim \
    make \
    git 
echo "${GREEN}Success! ${CHECK}${RE}"

# Generate SSH key

echo "${MAG}Generating your key...${RE}"
ssh-keygen -t rsa -f /home/ntozzi/.ssh/id_rsa 
echo "${GREEN}Success! ${CHECK}${RE}"

# Install Docker Engine

echo "${MAG}Installing Docker engine...${RE}"
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose

echo "${MAG}Installing Docker compose...${RE}"
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "${GREEN}Success! ${CHECK}${RE}"

# Configure Docker privileges

echo "${MAG}Configuring Docker privileges & restarting...${RE}"
sudo usermod -aG docker $USER
sudo systemctl restart docker
echo "${GREEN}Success! ${CHECK}${RE}"

# Final clean up

rm get-docker.sh

# Verify installations

echo ""
echo "------------------------------------------------------------------------------"
echo ""
echo "${MAG}Additional commands to ensure your packages are correctly installed:${RE}"
echo ""

# Check Docker and Docker Compose version

echo "Check Docker and Docker Compose version:"
echo "${GREEN}docker --version${RE} or ${GREEN}docker-compose --version${RE}"
echo ""

# Test Docker by running a sample image with and without sudo privileges

echo "You can also test Docker by running a sample image with and without sudo privileges:"
echo "${GREEN}(sudo) docker run hello-world${RE}"
echo ""

# Provide a warning about membership changes

echo "${YELLOW}WARNING: you may need to log out and back in or reboot for membership changes to take effect.${RE}"
echo ""