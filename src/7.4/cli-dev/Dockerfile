FROM hiqdev/php:7.4-cli

RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
    && mkdir -p /tmp/blackfire \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire-*.so $(php -r "echo ini_get ('extension_dir');")/blackfire.so \
    && printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > $PHP_INI_DIR/conf.d/blackfire.ini \
    && rm -rf /tmp/blackfire /tmp/blackfire-probe.tar.gz

RUN mkdir -p /tmp/blackfire \
    && curl -A "Docker" -L https://blackfire.io/api/v1/releases/client/linux_static/amd64 | tar zxp -C /tmp/blackfire \
    && mv /tmp/blackfire/blackfire /usr/bin/blackfire \
    && rm -Rf /tmp/blackfire

# Xdebug
RUN pecl install "xdebug-$XDEBUG_RELEASE" && \
    docker-php-ext-enable xdebug

RUN { \
        echo "xdebug.mode=debug"; \
        echo "xdebug.client_host=127.0.0.1"; \
        echo "xdebug.client_port=9003"; \
        echo "xdebug.start_with_request=trigger"; \
    } | tee -a /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

RUN apt-get update && \
    apt-get install -y --no-install-recommends git ca-certificates openssh-client && \
    rm -rf /var/lib/apt/lists/*
