FROM jeanlrnt/php:latest
ARG UID

LABEL maintainer="Jean LAURENT <jeanz.laurent@gmail.com>"

RUN touch /usr/local/etc/php/conf.d/max.ini && echo "max_execution_time = 120;" >> /usr/local/etc/php/conf.d/max.ini

# Add user
RUN useradd -mu ${UID} monuser

COPY completion.sh /etc/bash_completion.d/console

RUN echo 'alias sf="php bin/console"' >> /home/monuser/.bashrc
RUN echo 'source /etc/bash_completion.d/console' >> /home/monuser/.bashrc

WORKDIR /var/www/docker/
