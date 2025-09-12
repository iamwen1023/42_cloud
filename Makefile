NAME			=	inception
COMPOSE_FILE	=	srcs/docker-compose.yml
FLAGS			=	-f ${COMPOSE_FILE} \
					-p ${NAME}

all: build

build:
	@mkdir -p /home/wlo/data/database
	@mkdir -p /home/wlo/data/wordpress
	@docker compose ${FLAGS} build
	@docker compose ${FLAGS} up -d 
	@echo - docker services are up 

start:
	@docker compose ${FLAGS} start > /dev/null
	@echo docker services have been started

stop:
	@docker stop $$(docker ps -qa)
	@echo docker services have been stopped

status:
	@docker compose ${FLAGS} ps

clean:
	docker compose ${FLAGS} down
	@sudo rm -rf /home/wlo/data  > /dev/null
	docker volume rm $$(docker volume ls -q)
	@echo - docker volumes files have been deleted

# fclean: clean
# 	@docker stop $$(docker ps -qa);\
# 	docker rm $$(docker ps -qa);\
# 	docker rmi -f $$(docker images -qa);\
# 	docker volume rm $$(docker volume ls -q);\
# 	docker network rm $$(docker network ls -q);

fclean : clean
				docker system prune --all --force --volumes
				docker network prune --force
				docker volume prune --force
				docker image prune --force
re: stop fclean all

.PHONY: all start stop status fclean clean re