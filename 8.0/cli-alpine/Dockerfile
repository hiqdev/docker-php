FROM php:8.0-cli-alpine

ENV POSTFIX_MAILNAME hiqdev.com
ENV ICU_RELEASE=70.1
ENV XDEBUG_RELEASE=3.1.2
ENV MEMCACHED_RELEASE=3.1.5

# PHP options
ENV PHP_MAX_EXECUTION_TIME 3000
ENV PHP_MAX_INPUT_VARS 20000
ENV PHP_ERROR_REPORTING="E_ALL & ~E_NOTICE"
ENV PHP_POST_MAX_SIZE 60M
ENV PHP_UPLOAD_MAX_FILESIZE 25M
ENV PHP_SESS_GC_MAXLIFETIME 2592000

RUN set -xe \
    && apk update \
    && apk add --no-cache --virtual .php-deps \
        imagemagick \
        ghostscript \
        make \
        libssh2 \
        icu \
        gmp-dev \
        librdkafka-dev \
        libpq-dev \
        libzip-dev \
        libxml2-dev \
        libmemcached-dev \
        imap-dev \
    && apk add --no-cache --virtual .tools \
        openssh-client \
        git \
        iproute2 \
        bind-tools \
        gnupg \
        unzip \
        bash \
        postgresql-client \
        postfix \
    && apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        zlib-dev \
        icu-dev \
        g++ \
        freetype-dev \
        libpng-dev \
        imagemagick-dev \
        libjpeg-turbo-dev \
        ghc \
        autoconf \
        krb5-dev \
        libssh2-dev \
        zlib-dev \
        patch \
    && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl && \
    docker-php-ext-enable intl && \

    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    pecl install mailparse && \
    docker-php-ext-install zip bcmath imap soap pcntl gmp && \
    docker-php-ext-enable mailparse && \

    # Imagick is not ready to be compiled for PHP 8: https://github.com/Imagick/imagick/issues/358
    mkdir -p /usr/src/php/ext/imagick && \
    curl -fsSL https://github.com/Imagick/imagick/archive/448c1cd0d58ba2838b9b6dff71c9b7e70a401b90.tar.gz | tar xvz -C /usr/src/php/ext/imagick --strip 1 && \
    docker-php-ext-install imagick && \
    docker-php-ext-enable imagick && \

    # SSH
    pecl install ssh2-1.3.1 && \
    docker-php-ext-enable ssh2 && \

    # GD
    export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd && \

    # PostgreSQL
    docker-php-ext-install pdo_pgsql pgsql && \

    # XDebug
    pecl install "xdebug-$XDEBUG_RELEASE" && \
    docker-php-ext-enable xdebug && \

    # Opcache
    docker-php-ext-install opcache \

    && pecl install rdkafka \
    && docker-php-ext-enable rdkafka \

    # Memcached
    && pecl install memcached-$MEMCACHED_RELEASE \
    && docker-php-ext-enable memcached \

    # Sockets
    && docker-php-ext-install sockets \

    # Blackfire
    && version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && architecture=$(case $(uname -m) in i386 | i686 | x86) echo "i386" ;; x86_64 | amd64) echo "amd64" ;; aarch64 | arm64 | armv8) echo "arm64" ;; *) echo "amd64" ;; esac) \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/$architecture/$version \
    && echo 123 \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get ('extension_dir');")/blackfire.so \
    && printf ";extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz \
    && echo 'Blackfire has been installed' \

    && apk add gnu-libiconv=1.15-r3 --update-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.13/community/ --allow-untrusted \

    && { find /usr/local/lib -type f -print0 | xargs -0r strip --strip-all -p 2>/dev/null || true; } \
    && apk del .build-deps \
    && rm -rf /tmp/* /usr/local/lib/php/doc/* /var/cache/apk/* \

ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

# General settings
RUN { \
        echo "memory_limit=256M"; \
    } | tee -a /usr/local/etc/php/conf.d/docker-php-general.ini \

    && { \
        echo "opcache.enable=1"; \
        echo "opcache.memory_consumption=1024"; \
        echo "opcache.max_accelerated_files=9000"; \
        echo "opcache_revalidate_freq=120"; \
        echo "opcache.interned_strings_buffer=16"; \
    } | tee -a /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini \

    # Disable XDebug by default
    && sed -i "1s/^/;/" /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && { \
        echo "xdebug.max_nesting_level=500"; \
        echo "xdebug.mode=debug"; \
        echo "xdebug.client_host=127.0.0.1"; \
        echo "xdebug.client_port=9003"; \
        echo "xdebug.start_with_request=trigger"; \
    } | tee -a /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && \
    { \
        echo "log_errors = On"; \
        echo "max_execution_time = $PHP_MAX_EXECUTION_TIME"; \
        echo "max_input_vars = $PHP_MAX_INPUT_VARS"; \
        echo "error_reporting = $PHP_ERROR_REPORTING"; \
        echo "post_max_size = $PHP_POST_MAX_SIZE"; \
        echo "upload_max_filesize = $PHP_UPLOAD_MAX_FILESIZE"; \
        echo "session.gc_maxlifetime = $PHP_SESS_GC_MAXLIFETIME"; \
        echo "mail.add_x_header = Off"; \
    } | tee -a /usr/local/etc/php/php.ini

# Composer
COPY --from=composer:2.0 /usr/bin/composer /usr/bin/composer

RUN mkdir /app
WORKDIR /app
