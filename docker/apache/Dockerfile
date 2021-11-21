FROM httpd:2.4
ARG UID

LABEL maintainer="Jean LAURENT <jeanz.laurent@gmail.com>"

RUN echo "Include conf/sites/*.conf" >> /usr/local/apache2/conf/httpd.conf

RUN sed -i '/LoadModule proxy_module/s/^#//g' /usr/local/apache2/conf/httpd.conf \
    && sed -i '/LoadModule proxy_fcgi_module/s/^#//g' /usr/local/apache2/conf/httpd.conf \
    && sed -i '/LoadModule rewrite_module modules/s/^#//g' /usr/local/apache2/conf/httpd.conf \
    && sed -i 's/User daemon/User www-data/g' /usr/local/apache2/conf/httpd.conf \
    && sed -i 's/Group daemon/Group www-data/g' /usr/local/apache2/conf/httpd.conf

RUN sed -i \
        -e 's/^#\(Include .*httpd-ssl.conf\)/\1/' \
        -e 's/^#\(LoadModule .*mod_ssl.so\)/\1/' \
        -e 's/^#\(LoadModule .*mod_socache_shmcb.so\)/\1/' \
        conf/httpd.conf

COPY ./server.crt /usr/local/apache2/conf/server.crt
COPY ./server.key /usr/local/apache2/conf/server.key

RUN usermod -u ${UID} www-data

EXPOSE 443
EXPOSE 80