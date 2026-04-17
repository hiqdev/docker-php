VERSION = 8.5

builds = fpm-alpine cli-alpine

all: $(builds) push_$(builds)

$(builds):
	echo "🔧 Building PHP image for $@"
	docker build -t hiqdev/php:$(VERSION)-$@ $@
	docker push hiqdev/php:$(VERSION)-$@

.PHONY: all $(builds) push_$(builds)
