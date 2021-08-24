FROM php:7.3-apache

COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf

RUN apt-get update && apt-get install -y wget gnupg

RUN wget http://ftp.br.debian.org/debian/pool/main/g/glibc/multiarch-support_2.24-11+deb9u4_amd64.deb \
    && dpkg -i multiarch-support_2.24-11+deb9u4_amd64.deb

RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev

# RUN ACCEPT_EULA=Y apt-get install -y mssql-tools \
#     && echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc \
#     && source ~/.bashrc

RUN apt-get install -y --no-install-recommends \
        locales \
        apt-transport-https \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssl \
    && sed -i -E 's/(CipherString\s*=\s*DEFAULT@SECLEVEL=)2/\11/' /etc/ssl/openssl.cnf \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
        git \
        cron \
        nano \
        vim \
        libicu-dev \
        libzip-dev \
        libmemcached-dev \
        libz-dev \
        libpq-dev \
        libjpeg-dev \
        libpng-dev \
        libfreetype6-dev \
        libssl-dev \
        libmcrypt-dev \
        libonig-dev \
        libxml2-dev \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd \
        --with-freetype-dir=/usr \
        --with-jpeg-dir=/usr \
    && docker-php-ext-configure pdo_mysql --with-pdo-mysql \
    && docker-php-ext-configure pdo_pgsql --with-pdo-pgsql \
    && docker-php-ext-configure soap --enable-soap \
    && docker-php-ext-configure intl --enable-intl \
    && docker-php-ext-install \
        -j$(nproc) gd \
        pdo_mysql \
        pdo_pgsql \
        soap \
        intl \
        zip \
    && pecl install xdebug \
    && echo "\n\
        zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so) \n\
        xdebug.mode=debug \n\
    " >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "\n\
        display_errors=0 \n\ 
    " >> /usr/local/etc/php/conf.d/errors.ini

RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

RUN apt-get autoremove && apt-get autoclean

RUN a2enmod rewrite && service apache2 restart