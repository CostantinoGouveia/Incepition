COMPOSE = docker compose -f srcs/docker-compose.yml

all:
	@mkdir -p ~/data/mariadb ~/data/wordpress
	@$(COMPOSE) up --build -d

down:
	@$(COMPOSE) down

clean:
	@$(COMPOSE) down

fclean: clean
	@$(COMPOSE) down --volumes --rmi all
	@docker system prune -a -f
	@sudo rm -rf ~/data

re: fclean all

logs:
	@$(COMPOSE) logs -f

ps:
	@$(COMPOSE) ps

volumes:
	docker volume ls

networks:
	docker network ls

.PHONY: all down clean fclean re logs ps
