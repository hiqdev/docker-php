FROM php:7.0-fpm

ENV POSTFIX_MAILNAME hiqdev.com
ENV ICU_RELEASE 69.1

# PHP-FPM options
ENV FPM_MAX_CHILDREN 300
ENV FPM_START_SERVERS 50
ENV FPM_MIN_SPARE_SERVERS 20
ENV FPM_MAX_SPARE_SERVERS 50
ENV FPM_MAX_REQUESTS 10000
ENV FPM_PROCESS_MAX 512

ENV PHP_MAX_EXECUTION_TIME 3000
ENV PHP_MAX_INPUT_VARS 20000
ENV PHP_ERROR_REPORTING="E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE"
ENV PHP_POST_MAX_SIZE 60M
ENV PHP_UPLOAD_MAX_FILESIZE 25M
ENV PHP_SESS_GC_MAXLIFETIME 2592000

RUN apt-get update

# INTL
RUN export CPPFLAGS="$CPPFLAGS -DU_USING_ICU_NAMESPACE=1" CC="gcc -DTRUE=1 -DFALSE=0" CXX="g++ -DTRUE=1 -DFALSE=0" && \
    curl -sS -o /tmp/icu.tar.gz -L https://github.com/unicode-org/icu/releases/download/release-$(echo $ICU_RELEASE | tr '.' '-')/icu4c-$(echo $ICU_RELEASE | tr '.' '_')-src.tgz && \
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
        ghostscript

RUN export CFLAGS="$PHP_CFLAGS" CPPFLAGS="$PHP_CPPFLAGS" LDFLAGS="$PHP_LDFLAGS" && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    pecl install imagick && \
    docker-php-ext-enable imagick

# Opcache
RUN docker-php-ext-install opcache

RUN { \
    echo "opcache.enable=1"; \
    echo "opcache.memory_consumption=1024"; \
    echo "opcache.max_accelerated_files=9000"; \
    echo "opcache_revalidate_freq=120"; \
    echo "opcache.interned_strings_buffer=16"; \
} | tee -a /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

# Tune configs
RUN sed -i "s/max_children\s*=\s*[[:digit:]]\+/max_children = $FPM_MAX_CHILDREN/" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/start_servers\s*=\s*[[:digit:]]\+/start_servers = $FPM_START_SERVERS/" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/min_spare_servers\s*=\s*[[:digit:]]\+/min_spare_servers = $FPM_MIN_SPARE_SERVERS/" /usr/local/etc/php-fpm.d/www.conf
RUN sed -i "s/pm.max_spare_servers\s*=\s*[[:digit:]]\+/pm.max_spare_servers = $FPM_MAX_SPARE_SERVERS/" /usr/local/etc/php-fpm.d/www.conf

RUN { \
       echo '[www]'; \
       echo "pm.max_requests = $FPM_MAX_REQUESTS"; \
       echo 'catch_workers_output = yes'; \
       echo '[global]'; \
       echo "process.max = $FPM_PROCESS_MAX"; \
       echo 'emergency_restart_threshold = 10'; \
       echo 'emergency_restart_interval = 2s'; \
       echo 'process_control_timeout = 10s'; \
} | tee -a /usr/local/etc/php-fpm.d/www.conf

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
RUN echo "postfix postfix/mailname string $POSTFIX_MAILNAME" | debconf-set-selections
RUN echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
RUN apt-get install -y --no-install-recommends postfix

# CEANUP
RUN rm -rf /var/lib/apt/lists/*

# RUN
COPY hiqdev-docker-entrypoint /usr/local/bin
ENTRYPOINT ["hiqdev-docker-entrypoint"]
CMD ["php-fpm"]

