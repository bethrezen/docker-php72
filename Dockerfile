FROM php:7.2-apache
MAINTAINER Alexander Kozhevnikov <b37hr3z3n@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

RUN echo ${TIMEZONE} > /etc/timezone && \
    dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update -yqq
RUN apt-get install -yqq git libmcrypt-dev libpq-dev libcurl4-gnutls-dev libicu-dev libvpx-dev libjpeg-dev libpng-dev libxpm-dev zlib1g-dev libfreetype6-dev libxml2-dev libexpat1-dev libbz2-dev libgmp3-dev libldap2-dev unixodbc-dev libsqlite3-dev
# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) mbstring pdo_mysql curl json intl gd xml zip bz2 opcache
COPY ./.bashrc /root/.bashrc
COPY ./apache.conf /etc/apache2/sites-available/000-default.conf
COPY ./php.ini /usr/local/etc/php/conf.d/
RUN echo "LogFormat \"%a %l %u %t \\\"%r\\\" %>s %O \\\"%{User-Agent}i\\\"\" mainlog" >> /etc/apache2/apache2.conf
RUN a2enmod rewrite remoteip
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer global require hirak/prestissimo --prefer-dist --no-interaction
RUN docker-php-ext-install mysqli && docker-php-ext-enable mysqli


COPY ./remoteip.conf /etc/apache2/conf-enabled/000-remote-ip-docker.conf

RUN apt-get update && \
    apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev mc && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd