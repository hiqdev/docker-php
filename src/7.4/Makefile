VERSION = 7.4

builds = fpm cli cli-dev fpm-alpine

all: $(builds) push_$(builds)

$(builds):
	echo "🔧 Building PHP image for $@"
	docker build -t hiqdev/php:$(VERSION)-$@ --cache-from hiqdev/php:$(VERSION)-$@ $@
	docker push hiqdev/php:$(VERSION)-$@

.PHONY: all $(builds) push_$(builds)
