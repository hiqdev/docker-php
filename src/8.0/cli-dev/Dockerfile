FROM hiqdev/php:8.0-cli

RUN mkdir -p /tmp/blackfire \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/client/linux_static/amd64 | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire

# Xdebug
RUN pecl install "xdebug-$XDEBUG_RELEASE" && \
    docker-php-ext-enable xdebug

RUN { \
        echo "xdebug.profiler_enable=0"; \
        echo "xdebug.remote_autostart=0"; \
        echo "xdebug.remote_enable=1"; \
        echo "xdebug.max_nesting_level=500"; \
    } | tee -a /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates openssh-client && \
    rm -rf /var/lib/apt/lists/*
