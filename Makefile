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
COMMANDCOLOR = "\e[36m"
ENDCOLOR = "\e[0m"

.PHONY: rename build preNew postNew newSF newPHP newWP newLR up down cleanAll help removeSF removePHP removeWP removeLR check_clean bash dump list updatePhp

.DEFAULT_GOAL := help

build: ## Construit les conteneurs
	@$(DK) build

list: ## Liste tous les projets existants
	@echo $(ENDCOLOR)"---Projets Symfony---"$(COMMANDCOLOR)
	@grep -rnw --include=\*.conf 'virtualhosts' -e 'Symfony' | cut -d/ -f2 | cut -d. -f1
	@echo $(ENDCOLOR)"---Projets Wordpress---"$(COMMANDCOLOR)
	@grep -rnw --include=\*.conf 'virtualhosts' -e 'Wordpress' | cut -d/ -f2 | cut -d. -f1
	@echo $(ENDCOLOR)"---Projets Php---"$(COMMANDCOLOR)
	@grep -rnw --include=\*.conf 'virtualhosts' -e 'PHP' | cut -d/ -f2 | cut -d. -f1
	@echo $(ENDCOLOR)"---Projets Laravel---"$(COMMANDCOLOR)
	@grep -rnw --include=\*.conf 'virtualhosts' -e 'Laravel' | cut -d/ -f2 | cut -d. -f1

rename: ## Renomme un projet (Symfony, WP, Php, Laravel) et sa BD : make rename ancien_nom nouveau_nom
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
	@echo "Il faut ajouter l'ancien nom du projet et le nouveau nom du projet à la commande"
	@echo "  -> "$(COMMANDCOLOR)"make rename ancien_nom nouveau_nom"$(ENDCOLOR)
endif

preNew:
	@make up
	@sleep 5
	@echo "Création de la base de donnée"
	@$(DK) exec db mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) -e "CREATE DATABASE $(NOM)"

postNew:
	@make up
	@printf "Pour aller voir votre site :\t\t\033[1m\e[92mhttp://%b.localhost:8000\033[m\e[0m\tEnjoy !!!\n" $(NOM)

newSF: ## Crée un nouveau projet Symfony : make newSF mon_projet_SF
ifdef NOM
	@make preNew
	@echo "Création du projet symfony $(NOM)"
	@$(DK) exec php composer create-project symfony/skeleton:"^5.4" $(NOM)
	@echo "Configuration de la base de données via "$(COMMANDCOLOR)".env.local"$(ENDCOLOR)
	@echo "DATABASE_URL=mysql://root:root@db:3306/$(NOM)?serverVersion=mariadb-10.4.14" > $(APP_PATH)/$(NOM)/.env.local
	@make down
	@echo "Création du virtualhost"
	@sed -E 's/xxxxxx/$(NOM)/' ./virtualhosts/symfony.conf.sample >  ./virtualhosts/$(NOM).conf
	@make postNew
else
	@echo "Il faut ajouter le nom du projet à la commande"
	@echo "  -> "$(COMMANDCOLOR)"make newSF mon_projet_SF"$(ENDCOLOR)
endif

newPHP: ## Crée un nouveau projet PHP : make newPHP mon_projet_PHP
ifdef NOM
	@make preNew
	@echo "Création du projet php "$(COMMANDCOLOR)"$(NOM)"$(ENDCOLOR)
	@mkdir $(APP_PATH)/$(NOM)
	@touch $(APP_PATH)/$(NOM)/index.php
	@make down
	@echo "Création du virtualhost"
	@sed -E 's/xxxxxx/$(NOM)/' ./virtualhosts/php.conf.sample >  ./virtualhosts/$(NOM).conf
	@make postNew
else
	@echo "Il faut ajouter le nom du projet à la commande"
	@echo "  -> "$(COMMANDCOLOR)"make newPHP mon_projet_PHP"$(ENDCOLOR)
endif

newLR: ## Crée un nouveau projet Laravel : make newLR mon_projet_Laravel
ifdef NOM
	@make preNew
	@echo "Création du projet Laravel $(NOM)"
	@$(DK) exec php composer create-project laravel/laravel $(NOM)
	@echo "Configuration de la base de données"
	@echo "DB_CONNECTION=mysql\nDB_HOST=db\nDB_PORT=3306\nDB_DATABASE=$(NOM)\nDB_USERNAME=root\nDB_PASSWORD=root" > $(APP_PATH)/$(NOM)/.env.local
	@make down
	@echo "Création du virtualhost"
	@sed -E 's/xxxxxx/$(NOM)/' ./virtualhosts/laravel.conf.sample >  ./virtualhosts/$(NOM).conf
	@make postNew
else
	@echo "Il faut ajouter le nom du projet à la commande"
	@echo "  -> "$(COMMANDCOLOR)"make newLR mon_projet_Laravel"$(ENDCOLOR)
endif


newWP: ## Crée un nouveau projet Wordpress : make newWP mon_projet_WP
ifdef NOM
	@make preNew
	@echo "Création du projet wordpress $(NOM)"
	@$(DK) exec php composer create-project roots/bedrock $(NOM)
	@echo "Création du virtualhost"
	@sed -E 's/xxxxxx/$(NOM)/' ./virtualhosts/wordpress.conf.sample >  ./virtualhosts/$(NOM).conf
	@echo "Modification du "$(COMMANDCOLOR)".env"$(ENDCOLOR)
	@$(DK) exec php sed -i '1,3 s/^/#/' $(NOM)/.env
	@$(DK) exec php sed -i '14 s/^/#/' $(NOM)/.env
	@$(DK) exec php sed -i -e "8iDATABASE_URL=mysql://root:root@db:3306/$(NOM)"  $(NOM)/.env
	@$(DK) exec php sed -i -e "14iWP_HOME=http://$(NOM).localhost:8000"  $(NOM)/.env
	@make down
	@make postNew
else
	@echo "Il faut ajouter le nom du projet à la commande"
	@echo "  -> "$(COMMANDCOLOR)"make newWP mon_projet_WP"$(ENDCOLOR)
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
	@echo "Faites "$(COMMANDCOLOR)"make down"$(ENDCOLOR)" puis lancer la commande suivante éventuellement avec sudo"
	@echo $(COMMANDCOLOR)"docker system prune --volumes -a"$(ENDCOLOR)

remove: ## Supprime un projet PHP, Symfony ou Wordpress : make remove nom_du_projet
ifdef NOM
	@make check_clean
	@make up
	@sleep 5
	@echo "Suppression de la base de données"
	@$(DK) exec db mysql -u$(MYSQL_USER) -p$(MYSQL_PASSWORD) -e "DROP DATABASE $(NOM)"
	@make down
	@echo "Suppression du projet $(NOM)"
	@rm -rf $(APP_PATH)/$(NOM)
	@echo "Suppression du virtualhost"
	@rm -f  ./virtualhosts/$(NOM).conf
	@make up
else
	@echo "Il faut ajouter le nom du projet à la commande"
	@echo "  -> "$(COMMANDCOLOR)"make remove nom_du_projet"$(ENDCOLOR)
endif

dump: ## Sauvegarde la base associée au projet : make dump nom_du_projet
ifdef NOM
	@make up
	@if [ ! -d "./dumps" ]; then mkdir dumps; fi
	@$(DK) exec db mysqldump -p$(MYSQL_PASSWORD) $(NOM) > ./dumps/$(NOM)-$(CURRENT_TIME).sql
	@echo "Sauvegarde de la BD du projet "$(COMMANDCOLOR)"$(NOM)"$(ENDCOLOR)" réalisée dans le fichier "$(COMMANDCOLOR)"dumps/$(NOM)-$(CURRENT_TIME).sql"$(ENDCOLOR)
else
	@echo "Le nom du projet est manquant dans la commande :"
	@echo "  -> "$(COMMANDCOLOR)"make dump nom_du_projet"$(ENDCOLOR)
	@echo "Pour lister les projets disponibles :"
	@echo "  -> "$(COMMANDCOLOR)"make list"$(ENDCOLOR)
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
	@grep --no-filename -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'
