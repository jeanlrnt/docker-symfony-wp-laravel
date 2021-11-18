include .env
export

SHELL = /bin/sh

CURRENT_UID := $(shell id -u)

SUPPORTED_COMMANDS := newSF newWP newPHP newLR remove dump rename
SUPPORTS_MAKE_ARGS := $(findstring $(firstword $(MAKECMDGOALS)), $(SUPPORTED_COMMANDS))
ifneq "$(SUPPORTS_MAKE_ARGS)" ""
  NOM := $(wordlist 2,2,$(MAKECMDGOALS))
  NOM2 := $(wordlist 3,3,$(MAKECMDGOALS))
  $(eval $(NOM):;@:)
  $(eval $(NOM2):;@:)
endif

OS := $(shell uname)

export CURRENT_UID

DK := USERID=$(CURRENT_UID) $(DKC)

CURRENT_TIME := $(shell date "+%Y%m%d%H%M")

.PHONY: rename build preNew postNew newSF newPHP newWP newLR up down cleanAll help removeSF removePHP removeWP check_clean bash dump list updatePhp

.DEFAULT_GOAL := help

build: ## Construit les conteneurs
	@$(DK) build

list: ## Liste tous les projets existants
	@echo "---Projets Symfony---"
	@grep -rnw --include=\*.conf 'virtualhosts' -e 'Symfony' | cut -d/ -f2 | cut -d. -f1
	@echo "---Projets Wordpress---"
	@grep -rnw --include=\*.conf 'virtualhosts' -e 'Wordpress' | cut -d/ -f2 | cut -d. -f1
	@echo "---Projets Php---"
	@grep -rnw --include=\*.conf 'virtualhosts' -e 'PHP' | cut -d/ -f2 | cut -d. -f1

rename: ## Renomme un projet (Symfony, WP, Php) et sa BD : make rename ancien_nom nouveau_nom
ifneq ($(and $(NOM),$(NOM2)),)
	@make up
	@echo "Renommage de la base de données"
	@$(DK) exec db mysqldump -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) -R $(NOM) > /tmp/$(NOM)-dump.sql
	@$(DK) exec db mysqladmin -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) create $(NOM2)
	@cat /tmp/$(NOM)-dump.sql | $(DK) exec -T db mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) $(NOM2)
	@$(DK) exec db mysqladmin -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) drop $(NOM)
	@echo "Renommage du dossier du projet"
	@mv $(APP_PATH)/$(NOM) $(APP_PATH)/$(NOM2)
	@echo "Renommage du virtualhost"
	@mv virtualhosts/$(NOM).conf virtualhosts/$(NOM2).conf
	@sed -i 's/$(NOM)/$(NOM2)/' virtualhosts/$(NOM2).conf
	@echo "Pensez à modifier l'accès à la base de données dans votre code pour $(NOM2)"
else 
	@echo "il faut ajouter l'ancien nom du projet et le nouveau nom du projet à la commande"
endif

preNew:
	@make up
	@sleep 5
	@echo "création de la base de donnée"
	@$(DK) exec db mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) -e "CREATE DATABASE $(NOM)"

postNew:
	@make up
	@printf "Pour aller voir votre site :\t\t\033[1m\e[92mhttp://%b.localhost:8000\033[m\e[0m\tEnjoy !!!\n" $(NOM)

newSF: ## Crée un nouveau projet Symfony : make newSF mon_projet_SF
ifdef NOM
	@make preNew
	@echo "création du projet symfony $(NOM)"
	@$(DK) exec php composer create-project symfony/skeleton $(NOM)
	@echo "configuration de la base de données via .env.local"
	@echo "DATABASE_URL=mysql://root:root@db:3306/$(NOM)?serverVersion=mariadb-10.4.14" > $(APP_PATH)/$(NOM)/.env.local
	@make down
	@echo "création du virtualhost"
	@sed -E 's/xxxxxx/$(NOM)/' ./virtualhosts/symfony.conf.sample >  ./virtualhosts/$(NOM).conf
	@make postNew
else 
	@echo "il faut ajouter le nom du projet à la commande"
endif

newPHP: ## Crée un nouveau projet PHP : make newPHP mon_projet_PHP
ifdef NOM
	@make preNew
	@echo "création du projet php $(NOM)"
	@mkdir $(APP_PATH)/$(NOM)
	@touch $(APP_PATH)/$(NOM)/index.php
	@make down
	@echo "création du virtualhost"
	@sed -E 's/xxxxxx/$(NOM)/' ./virtualhosts/php.conf.sample >  ./virtualhosts/$(NOM).conf
	@make postNew
else 
	@echo "il faut ajouter le nom du projet à la commande"
endif

newLR: ## Crée un nouveau projet Laravel : make newLR mon_projet_Laravel
ifdef NOM
	@make preNew
	@echo "création du projet Laravel $(NOM)"
	@$(DK) exec php composer create-project laravel/laravel $(NOM)
	@echo "configuration de la base de données via .env.local"
	@echo "DATABASE_URL=mysql://root:root@db:3306/$(NOM)?serverVersion=mariadb-10.4.14" > $(APP_PATH)/$(NOM)/.env.local
	@make down
	@echo "création du virtualhost"
	@sed -E 's/xxxxxx/$(NOM)/' ./virtualhosts/laravel.conf.sample >  ./virtualhosts/$(NOM).conf
	@make postNew
else
	@echo "il faut ajouter le nom du projet à la commande"
endif


newWP: ## Crée un nouveau projet Wordpress : make newWP mon_projet_WP
ifdef NOM
	@make preNew
	@echo "création du projet wordpress $(NOM)"
	@$(DK) exec php composer create-project roots/bedrock $(NOM)
	@echo "création du virtualhost"
	@sed -E 's/xxxxxx/$(NOM)/' ./virtualhosts/wordpress.conf.sample >  ./virtualhosts/$(NOM).conf
	@echo "modification du .env"
	@$(DK) exec php sed -i '1,3 s/^/#/' $(NOM)/.env
	@$(DK) exec php sed -i '14 s/^/#/' $(NOM)/.env
	@$(DK) exec php sed -i -e "8iDATABASE_URL=mysql://root:root@db:3306/$(NOM)"  $(NOM)/.env
	@$(DK) exec php sed -i -e "14iWP_HOME=http://$(NOM).localhost:8000"  $(NOM)/.env
	@make down
	@make postNew
else 
	@echo "il faut ajouter le nom du projet à la commande"
endif

up: ## Démarre les serveurs
ifeq ($(OS),Darwin)
	@docker volume create --name=app-sync
	@$(DK) -f docker-compose-macos.yml up -d
	@USERID=$(CURRENT_UID) docker-sync start
else
	@$(DK) up -d
endif

down: ## Arrête les serveurs
ifeq ($(OS),Darwin)
	@$(DK) down
	@USERID=$(CURRENT_UID) docker-sync stop
else
	@$(DK) down
endif

cleanAll: check_clean ## Supprime tous les conteneurs
	@echo "Attention, action irréversible !!!"
	@echo "Faites make down puis lancer la commande suivante éventuellement avec sudo"
	@echo "docker system prune --volumes -a"

remove: ## Supprime un projet PHP, Symfony ou Wordpress : make remove nom_du_projet
ifdef NOM
	@make check_clean
	@make up
	@sleep 5
	@echo "suppression de la base de données"
	@$(DK) exec db mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) -e "DROP DATABASE $(NOM)"
	@make down
	@echo "suppression du projet $(NOM)"
	@rm -rf $(APP_PATH)/$(NOM)
	@echo "suppression du virtualhost"
	@rm -f  ./virtualhosts/$(NOM).conf
	@make up
else 
	@echo "il faut ajouter le nom du projet à la commande" 
endif

dump: ## Sauvegarde la base associée au projet : make dump nom_du_projet
ifdef NOM
	@make up
	@$(DK) exec db mysqldump -p$(MYSQL_PASSWORD) $(NOM) > $(NOM)-$(CURRENT_TIME).sql
	@echo "Sauvegarde de la BD du projet $(NOM) réalisée dans le fichier $(NOM)-$(CURRENT_TIME).sql"
else 
	@echo "il faut ajouter le nom du projet à la commande"
endif

bash: ## Entre en bash dans le conteneur php
	@$(DK) exec php bash

updatePhp: ## Mets à jour composer et le binaire symfony dans le conteneur php
	@make down
	@$(DK) build --no-cache php
	@make up

check_clean:
	@( read -p "Êtes vous sûr ? Vous allez tout supprimer [o/N]: " sure && case "$$sure" in [oO]) true;; *) false;; esac )

help: ## Affiche cette aide
	@grep --no-filename -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
