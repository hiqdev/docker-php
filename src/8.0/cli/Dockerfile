FROM php:8.0-cli-bullseye

ENV POSTFIX_MAILNAME hiqdev.com
ENV ICU_RELEASE=71.1
ENV XDEBUG_RELEASE=3.1.2
ENV MEMCACHED_RELEASE=3.1.5

# PHP-FPM options
ENV PHP_MAX_EXECUTION_TIME 3000
ENV PHP_MAX_INPUT_VARS 20000
ENV PHP_ERROR_REPORTING="E_ALL & ~E_NOTICE"
ENV PHP_POST_MAX_SIZE 60M
ENV PHP_UPLOAD_MAX_FILESIZE 25M
ENV PHP_SESS_GC_MAXLIFETIME 2592000

# INTL
# PHP_CPPFLAGS are used by the docker-php-ext-* scripts
ENV CXXFLAGS "-std=c++11"
ENV PHP_CPPFLAGS="$PHP_CPPFLAGS $CXXFLAGS"
RUN curl -sS -o /tmp/icu.tar.gz -L https://github.com/unicode-org/icu/releases/download/release-$(echo $ICU_RELEASE | tr '.' '-')/icu4c-$(echo $ICU_RELEASE | tr '.' '_')-src.tgz && \
    tar -zxf /tmp/icu.tar.gz -C /tmp && \
    cd /tmp/icu/source && \
    ./configure --prefix=/usr/local && \
    make && make install && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl && \
    rm -rf /tmp/icu /tmp/icu.tar.gz

# GD, Imagick, SSH2
RUN apt-get update && apt-get install -y --no-install-recommends \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libmagickwand-dev \
        imagemagick \
        ghostscript \
        ssh \
        libssh2-1-dev \
        libssh2-1 \
        autoconf \
        dnsutils \
        gnupg2 \
        lsb-release \
        libghc-postgresql-libpq-dev && \
    export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd && \
    docker-php-ext-install pdo && \
    docker-php-ext-install pdo_pgsql && \
    docker-php-ext-install pgsql && \
    docker-php-ext-install sockets && \

    # Imagick is not ready to be compiled for PHP 8: https://github.com/Imagick/imagick/issues/358
    mkdir -p /usr/src/php/ext/imagick && \
    curl -fsSL https://github.com/Imagick/imagick/archive/448c1cd0d58ba2838b9b6dff71c9b7e70a401b90.tar.gz | tar xvz -C /usr/src/php/ext/imagick --strip 1 && \
    docker-php-ext-install imagick && \

    pecl install ssh2-1.3.1 && \
    docker-php-ext-enable imagick && \
    docker-php-ext-enable ssh2 && \
    apt-get remove -y libfreetype6-dev libpng-dev libmagickwand-dev libjpeg62-turbo-dev ghc libssh2-1-dev && \
    rm -rf /var/lib/apt/lists/*

# Other extensions: ZIP, BCmath, imap, mailparse
RUN apt-get update && apt-get install -y libc-client-dev libkrb5-dev libzip-dev libgmp3-dev librdkafka-dev \
    && pecl install mailparse rdkafka \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install zip bcmath imap pcntl soap sockets gmp \
    && docker-php-ext-enable mailparse rdkafka \
    && apt-get remove -y libc-client-dev libkrb5-dev libzip-dev \
    && rm -rf /var/lib/apt/lists/*

# Config
RUN { \
    echo "log_errors = On"; \
    echo "max_execution_time = $PHP_MAX_EXECUTION_TIME"; \
    echo "max_input_vars = $PHP_MAX_INPUT_VARS"; \
    echo "error_reporting = $PHP_ERROR_REPORTING"; \
    echo "post_max_size = $PHP_POST_MAX_SIZE"; \
    echo "upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE"; \
    echo "session.gc_maxlifetime = $PHP_SESS_GC_MAXLIFETIME"; \
    echo "mail.add_x_header = Off"; \
} | tee -a /usr/local/etc/php/php.ini

# Mailing
RUN echo "postfix postfix/mailname string $POSTFIX_MAILNAME" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections && \
    apt-get update && apt-get install -y --no-install-recommends postfix && \
    rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# PostgreSQL client
RUN apt-get update && \
    apt-get install -y --no-install-recommends gnupg2 && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get install -y --no-install-recommends postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Install Memcached
RUN apt-get update \
    && apt-get install -y --no-install-recommends libmemcached-dev zlib1g-dev \
    && pecl install memcached-$MEMCACHED_RELEASE \
    && docker-php-ext-enable memcached \
    && apt-get remove -y zlib1g-dev \
    && rm -r /var/lib/apt/lists/*


RUN mkdir /app
WORKDIR /app
