FROM php:7.2-cli

ENV POSTFIX_MAILNAME hiqdev.com

# PHP-FPM options
ENV PHP_MAX_EXECUTION_TIME 3000
ENV PHP_MAX_INPUT_VARS 20000
ENV PHP_ERROR_REPORTING="E_ALL & ~E_NOTICE"
ENV PHP_POST_MAX_SIZE 60M
ENV PHP_UPLOAD_MAX_FILESIZE 25M
ENV PHP_SESS_GC_MAXLIFETIME 2592000

RUN apt-get update

# INTL
# PHP_CPPFLAGS are used by the docker-php-ext-* scripts
ENV PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++11"
RUN curl -sS -o /tmp/icu.tar.gz -L http://download.icu-project.org/files/icu4c/61.1/icu4c-61_1-src.tgz && \
    tar -zxf /tmp/icu.tar.gz -C /tmp && \
    cd /tmp/icu/source && \
    ./configure --prefix=/usr/local && \
    make && make install && \
    docker-php-ext-configure intl --with-icu-dir=/usr/local && \
    docker-php-ext-install intl

# GD, Imagick
RUN apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmagickwand-dev \
        imagemagick \
        ghostscript \
        libghc-postgresql-libpq-dev

RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    docker-php-ext-install pdo && \
    docker-php-ext-install pdo_pgsql && \
    docker-php-ext-install pgsql && \
    docker-php-ext-install sockets && \
    pecl install imagick && \
    docker-php-ext-enable imagick

# Other extensions: ZIP, BCmath, imap, mailparse
RUN apt-get install -y libc-client-dev libkrb5-dev \
    && pecl install mailparse \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install zip bcmath imap \
    && docker-php-ext-enable mailparse

# Config
RUN { \
    echo "log_errors = On"; \
    echo "max_execution_time = $PHP_MAX_EXECUTION_TIME"; \
    echo "max_input_vars = $PHP_MAX_INPUT_VARS"; \
    echo "error_reporting = $PHP_ERROR_REPORTING"; \
    echo "post_max_size = $PHP_POST_MAX_SIZE"; \
    echo "upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE"; \
    echo "session.gc_maxlifetime = $PHP_SESS_GC_MAXLIFETIME"; \
} | tee -a /usr/local/etc/php/php.ini

# Mailing
RUN echo "postfix postfix/mailname string $POSTFIX_MAILNAME" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections && \
    apt-get install -y --no-install-recommends postfix

# CEANUP
RUN rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:1.6 /usr/bin/composer /usr/bin/composer

RUN mkdir /app
WORKDIR /app
