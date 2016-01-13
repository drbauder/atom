FROM php:5.6-fpm

ENV DEBIAN_FRONTEND noninteractive

# TODO:
# - ffmpeg in jessie (http://superuser.com/a/865744)
# - missing php extensions
# - check out https://github.com/helderco/docker-php

RUN apt-get update \
    && apt-get install -y \
        libcurl4-openssl-dev \
        libmcrypt-dev \
        libxml2-dev \
        libxslt1-dev \
        zlib1g-dev \
        imagemagick \
        ghostscript \
        poppler-utils \
        nodejs \
        npm \
        make \
    && rm -r /var/lib/apt/lists/*

# Failed: ldap (libldap...), simplexml, spl, readline (libreadline-dev, libedit-dev)
# Check if really needed: iconv, xml, xmlreader, xmlwriter, spl, simplexml
RUN docker-php-ext-install \
        curl \
        gettext \
        iconv \
        json \
        mbstring \
        mcrypt \
        mysqli \
        opcache \
        pdo \
        pdo_mysql \
        xml \
        xmlreader \
        xmlwriter \
        xsl \
        zip

# APCu
RUN curl -L https://pecl.php.net/get/apcu-4.0.10.tgz >> /usr/src/php/ext/apcu.tgz \
    && tar -xf /usr/src/php/ext/apcu.tgz -C /usr/src/php/ext/ \
    && rm /usr/src/php/ext/apcu.tgz \
    && docker-php-ext-install apcu-4.0.10

RUN mkdir /atom
ADD . /atom/src

RUN npm install -g "less@<2.0.0"
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN cd /atom/src/plugins/arDominionPlugin && make
RUN cd /atom/src/plugins/arArchivesCanadaPlugin && make

WORKDIR /atom/src
ENTRYPOINT ["/atom/src/init/docker-init.sh"]
