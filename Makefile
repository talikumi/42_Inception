DATA_DIR = /home/ntozzi.42.fr/data
HOSTS_FILE = /etc/hosts
HOSTS_ENTRY = "127.0.0.1 ntozzi.42.fr"
COMPOSE_FILE = ./srcs/docker-compose.yml
SU = sudo

# Color codes

MAG="\e[95m"
YELLOW="\e[33m"
GREEN="\e[92m"
CHECK="✔"
RE="\e[0m"

all: setup docker-up

# Check if the user doesn't have the required privileges

ifneq ($(shell id -u), 0)
	$(error Please run this Makefile with sudo privileges)
endif

# Create data directories and append the new entry to the hosts file

setup:
	@echo $(MAG)"Setting up utilities..."$(RE)
	@$(SU) mkdir -p $(DATA_DIR)/wordpress
	@$(SU) mkdir -p $(DATA_DIR)/db 
	@echo $(GREEN)"Success!" $(CHECK) $(RE)
	@if ! grep -Pq $(HOSTS_ENTRY) $(HOSTS_FILE); then \
		$(SU) sh -c 'echo $(HOSTS_ENTRY) >> $(HOSTS_FILE)'; \
		echo "Added host entry to $(HOSTS_FILE)"; \
	else \
		echo $(YELLOW)"Host entry already exists in $(HOSTS_FILE)" $(RE); \
	fi

# Start Docker containers

docker-up:
	@echo $(MAG)"Starting containers (it may take up to several minutes)..."$(RE)
	@docker build -t nginx ./srcs/requirements/nginx/
	@docker build -t wordpress ./srcs/requirements/wordpress/
	@docker build -t mariadb ./srcs/requirements/mariadb/
	@docker compose -f $(COMPOSE_FILE) up #-d
	@echo $(GREEN)"Success!" $(CHECK) $(RE)


clean: docker-down docker-prune

# Stop Docker containers

docker-down:
	@echo $(MAG)"Stopping containers & deleting Docker resources..."$(RE)
	@docker compose -f $(COMPOSE_FILE) down --volumes --remove-orphans

# Remove unused Docker resources

docker-prune:
	@docker image prune -af
	@docker volume prune -af
	@docker system prune -af

# Remove data and volumes (even if still running)

fclean: clean
	@$(SU) rm -rf $(DATA_DIR)
	@$(docker volume rm $(docker volume ls -q))
	@echo $(GREEN)"Success!" $(CHECK) $(RE)


re: fclean all

.PHONY: all setup docker-up clean docker-down docker-prune fclean