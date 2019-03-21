SHELL = /bin/bash
TAG = "kolemp/php-dev:$(PHP_VERSION)"

build:
	@if [ "$(PHP_VERSION)" == "" ]; then echo "PHP_VERSION is required"; exit 1; fi;
	@if [ "$(APP_ENV)" == "" ]; then echo "APP_ENV is required"; exit 1; fi;
	docker run --rm -e PHP_VERSION=$(PHP_VERSION) -e APP_ENV=$(APP_ENV) -v /`pwd`:/data kolemp/twig-renderer /data/Dockerfile-$(APP_ENV).twig > ./Dockerfile
	docker build -t $(TAG) .
