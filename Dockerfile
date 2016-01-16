FROM php:5.6-fpm

ENV DEBIAN_FRONTEND noninteractive

# Notes:
# - Package ffmpeg in jessie installed following http://superuser.com/a/865744
# - Borrow some ideas from https://github.com/helderco/docker-php
# - Compile themes if not done yet? In docker-init.sh...
# - Populate database if not done yet? In docker-init.sh...
# - Watching for changes during dev? [WIP] See https://github.com/docker/compose/issues/184

RUN gpg --keyserver keyring.debian.org --recv-keys 5C808C2B65558117 \
    && gpg -a --export 5C808C2B65558117 | apt-key add - \
    && echo "deb http://www.deb-multimedia.org jessie main non-free" >> /etc/apt/sources.list \
    && apt-get update \
    && apt-get install -y \
        # Needed in PHP modules
        libldap2-dev libxslt1-dev zlib1g-dev \
        # Dependencies for digital object processing
        ffmpeg imagemagick ghostscript poppler-utils \
        # Needed to compile themes
        nodejs npm make \
    && rm -r /var/lib/apt/lists/*

# Adding missing modules
# Default list: `docker run -i -t php:5.6-fpm php -m`
RUN curl -L https://pecl.php.net/get/apcu-4.0.10.tgz >> /usr/src/php/ext/apcu.tgz \
    && tar -xf /usr/src/php/ext/apcu.tgz -C /usr/src/php/ext/ \
    && rm /usr/src/php/ext/apcu.tgz \
    && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu \
    && docker-php-ext-install \
        apcu-4.0.10 \
        calendar \
        gettext \
        ldap \
        mbstring \
        mysql \
        mysqli \
        opcache \
        pdo_mysql \
        simplexml \
        sockets \
        xsl \
        zip

RUN mkdir /atom
ADD . /atom/src

RUN npm install -g "less@<2.0.0"
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN cd /atom/src/plugins/arDominionPlugin && make
RUN cd /atom/src/plugins/arArchivesCanadaPlugin && make

WORKDIR /atom/src
ENTRYPOINT ["/atom/src/init/docker-init.sh"]
