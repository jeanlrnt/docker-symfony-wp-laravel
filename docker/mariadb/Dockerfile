FROM mariadb:10.4
ARG UID

LABEL maintainer="Jean LAURENT <jeanz.laurent@gmail.com>"

RUN usermod -u ${UID} mysql; groupmod -g ${UID} mysql;

RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
