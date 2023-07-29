# Docker Symfony & WP (PHP8-FPM - Apache - MariaDB)

Cet environnement correspond à l'environnement de production du serveur lpmiaw.univ-lr.fr (Ubuntu 20.04) à savoir :

    - php 8.2
    - mariadb 10.7
    - apache 2.4

Docker-Symfony-WP vous donne tout ce que vous avez besoin pour développer des applications sous Symfony 5 et sous wordpress avec BedRocks.
C'est une architecture complète à utiliser avec docker et [docker-compose](https://docs.docker.com/compose/).

## Makefile
Ce projet possède également un Makefile permettant de réaliser les tâches courantes :
- démarrer les serveurs
- arrêter les serveurs
- créer une nouvelle application symfony
- créer une nouvelle application wordpress
- sauvegarder une base de données issue d'un projet
- ...

```sh
# pour voir toutes les possibilités
make
```

## Type de machines

1. [Machine virtuelle linux de l'Université](doc/MACHINEVIRTUELLE.md)
1. [Machine linux personnelle](doc/MACHINEPERSOLINUX.md)
1. [Machine mac personnelle](doc/MACHINEPERSOMAC.md)
1. [Machine windows personnelle](doc/MACHINEPERSOWINDOWS.md)

## Mise en production

1. [Mise en production sur le serveur LPMiaw](doc/DEPLOIEMENTSERVEURLPMIAW.md)

## Bonus

- Vous pouvez utiliser cette architecture pour héberger un projet php standard en faisant :

```sh
make newPHP nom_du_projet
```

> Attention, l'accès à la base de données dans votre code se fait par l'hôte db et non localhost.
