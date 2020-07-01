FROM php:7.3-apache

COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf

ENV ACCEPT_EULA=Y

#  Adicionando repositorio do SQL Server, aceitando a licença e instalando :)
RUN apt-get update \
    && apt-get install -y \
        wget \
        gnupg \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list \
        > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get install -y --no-install-recommends \
        locales \
        apt-transport-https \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        unixodbc-dev \
        msodbcsql17 \
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
        xdebug.remote_log = /var/www/html/xdebug.log \n\
        xdebug.remote_enable=on \n\
        xdebug.remote_handler=dbgp \n\
        xdebug.remote_port=9000 \n\
        xdebug.remote_autostart=on \n\
        xdebug.remote_connect_back=on \n\
        xdebug.idekey=docker \n\
        xdebug.remote_log=/var/www/html/xdebug.log \n\
        xdebug.default_enable=on \n\
    " >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "\n\
        display_errors=0 \n\ 
    " >> /usr/local/etc/php/conf.d/errors.ini

RUN curl -sS https://getcomposer.org/installer \
    | php -- --install-dir=/usr/local/bin --filename=composer

RUN a2enmod rewrite && service apache2 restart