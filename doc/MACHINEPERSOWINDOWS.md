## Version de Windows
- Vous avez un windows en version récente (min 2004), cela ira. Bien que je vous conseille d'installer linux.

## Prérequis

1. Avoir au moins la version 2004 de windows
2. Installer dans les fonctionnsalités windows
   - Plateforme d'ordinateur virtuel
   - Sous-système Windows pour Linux
3. Installer WSL2 via https://aka.ms/wsl2kernel
4. Passer toutes les nouvelles installations en wsl2

```sh
# dans un powershell
wsl --set-default-version 2
```

6. Installer la distribution **debian** via le store
7. Lancer debian et installer git vim et make

```sh
sudo apt update
sudo apt upgrade
sudo apt install git vim make
```

8. Modifier la config de docker dans debian (~/.docker/config.json)
   
```sh
# credsSTore doit être vide
credsStore:""
...

```

9.  Avoir [Docker Desktop](https://www.docker.com/products/docker-desktop)
10. Dans Docker-Desktop, activer dans les paramètres l'integration de wsl pour debian. Cela permettra d'avoir les commandes docker dans debian

11. Avoir Phpstorm. Votre statut d'étudiant vous donne droit à une licence gratuite de la suite.
12. Installer les plugins symfony, wordpress et .env pour Phpstorm


## Installation

1. Placez vous dans la machine **debian**
2. Dupliquer le projet :
    ```bash
    git clone https://github.com/jeanlrnt/docker-symfony-wp-laravel.git devPhp
    # on se place dans le bon dossier
    cd devPhp
    ```

3. Construire et exécuter les conteneurs (Cela peut prendre un peu de temps)

    ```bash
    $ make build
    $ make up
    ```

4. **Installer Symfony**
    1. Toujours sous **debian**, on installe symfony en version minimale grâce au Makefile.
        
        ```bash
        $ make newSF nom_de_mon_projet
        ```
        - cela va créer le projet via composer, un virtualhost ainsi qu'une base de données dédiée

    2.  On installe les composants nécessaires à nos applications également avec Composer

        ```bash
        $ make bash
        $ cd nom_de_mon_projet
        $ composer require --dev profiler maker
        $ composer require annotations twig orm form validator
        ```
    
    3. Sous **windows** avec votre editeur de texte favori
       - Modifiez le fichier C:\Windows\System32\drivers\etc\hosts en ajoutant à la dernière ligne :
          >  127.0.01    nom_de_mon_projet.localhost

    4. Sous **windows**, ouvrir le dossier symfony du projet dans phpStorm. Il va reconnaître automatiquement le WSL et le termnianl sera par défaut sous debian ;)

5. **Installer Laravel**
    1. Toujours sous **debian**, on installe laravel en version minimale grâce au Makefile.
        
        ```bash
        $ make newLR nom_de_mon_projet
        ```
        - cela va créer le projet via composer, un virtualhost ainsi qu'une base de données dédiée

    2.  On installe les composants nécessaires à nos applications également avec Composer

        ```bash
        $ make bash
        $ cd nom_de_mon_projet
        $ composer update
        ```
    
    3. Sous **windows** avec votre editeur de texte favori
       - Modifiez le fichier C:\Windows\System32\drivers\etc\hosts en ajoutant à la dernière ligne :
          >  127.0.01    nom_de_mon_projet.localhost

    4. Sous **windows**, ouvrir le dossier laravel du projet dans phpStorm. Il va reconnaître automatiquement le WSL et le termnianl sera par défaut sous debian ;)
   
6. **Installer Wordpress**
   1.  Toujours sous **debian**, on installe wordpress grâce au Makefile.
        
        ```bash
        $ make newWP nom_de_mon_projet
        ```
        - cela va créer le projet via composer, un virtualhost ainsi qu'une base de données dédiée

   2. Sous **windows** avec votre editeur de texte favori
       - Modifiez le fichier C:\Windows\System32\drivers\etc\hosts en ajoutant à la dernière ligne :
          >  127.0.01    nom_de_mon_projet.localhost
    
   3. Sous **windows**, ouvrir le dossier wordpress du projet dans phpStorm. Il va reconnaître automatiquement le WSL et le termnianl sera par défaut sous debian ;)
      - modifier **.env** 
        1. en recopiant les informations de https://roots.io/salts.html dans la partie concernée (AUTH_KEY, SECURE_AUTH_KEY, ...)
        2. en précisant le suffixe des tables : décommentez la variable DB_PREFIX et mettez le préfixe de votre choix.

6. C'est parti :-)

## Je commence à travailler sur un projet

Vous avez juste à exécuter `make up`, puis:

* Ouvrez votre projet avec phpStorm
* Ouvrez votre navigateur [nom_de_mon_projet.localhost:8000](http://nom_de_mon_projet.localhost:8000)
* Logs du serveur web : logs/apache2

## Je finis de travailler sur le projet
Vous avez juste à exécuter `make down`.

## Comment cela fonctionne ?

Vous pouvez aller regarder le fichier `docker-compose.yml`, avec les images `docker-compose` correspondantes:

* `db`: le container mariadb 10.4,
* `php`: php-fpm en version 8.0,
* `apache`: le serveur web apache2 sur le port 8000,

## Commandes utiles

```bash
# On rentre dans un conteneur en bash
$ make bash

# Commandes symfony
$ make bash
$ cd nom_de_mon_projet
$ sf make:controller
$ sf make:entity
$ composer req composant_utile
...

# Supprimer tous les conteneurs (en cas de gros plantage, à utiliser en dernier recours)
$ make cleanAll
```

## FAQ
* Je ne comprends rien, que faire ?
Allez voir votre prof !

* Xdebug?
Xdebug est déjà configuré
Il faut ajouter le module Xdebug helper pour Firefox ou pour Chrome
Il faut également configurer Phpstorm en se connectant au port  `9001` avec l'id `PHPSTORM`. Vous pouvez suivre ce [lien](https://blog.eleven-labs.com/fr/debug-run-phpunit-tests-using-docker-remote-interpreters-with-phpstorm/). Le dépôt que vous utilisez est déjà paramétré. Utilisez docker-compose à la place de docker dans le "Remote" de l'interpréteur PHP.
