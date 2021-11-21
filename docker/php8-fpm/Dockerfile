FROM nicolasunivlr/php:lp2021
ARG UID

LABEL maintainer="Jean LAURENT <jeanz.laurent@gmail.com>"

RUN touch /usr/local/etc/php/conf.d/max.ini && echo "max_execution_time = 120;" >> /usr/local/etc/php/conf.d/max.ini

# Update composer
RUN composer self-update

# Update symfony bin
RUN symfony self:update

# Add user
RUN useradd -mu ${UID} monuser

RUN echo 'alias sf="php bin/console"' >> /home/monuser/.bashrc

ENV http_proxy ${http_proxy}
ENV https_proxy ${http_proxy}

WORKDIR /var/www/docker/
