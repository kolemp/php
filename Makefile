SHELL = /bin/bash
TAG = "kolemp/php-dev:$(PHP_VERSION)"

ifeq ($(APP_ENV), prod)
TAG = "kolemp/php:$(PHP_VERSION)"
endif

ensure:
	@if [ "$(PHP_VERSION)" == "" ]; then echo "PHP_VERSION is required"; exit 1; fi;

build: ensure
	@if [ "$(APP_ENV)" == "" ]; then echo "APP_ENV is required"; exit 1; fi;
	docker run --rm -e PHP_VERSION=$(PHP_VERSION) -e APP_ENV=$(APP_ENV) -v /`pwd`:/data kolemp/twig-renderer /data/Dockerfile-$(APP_ENV).twig > ./Dockerfile
	docker build -t $(TAG) .

test: ensure
	GOSS_VARS=vars.yaml GOSS_OPTS="--retry-timeout=30s" dgoss run -e PHP_VERSION kolemp/php:$(PHP_VERSION)
	GOSS_VARS=vars.yaml GOSS_OPTS="--retry-timeout=30s" dgoss run -e PHP_VERSION kolemp/php-dev:$(PHP_VERSION)
	GOSS_VARS=vars.yaml GOSS_OPTS="--retry-timeout=30s" dgoss run -e PHP_VERSION -e XDEBUG_ENABLE='1' -e USER_ID="1000" kolemp/php:$(PHP_VERSION)
	GOSS_VARS=vars.yaml GOSS_OPTS="--retry-timeout=30s" dgoss run -e PHP_VERSION -e XDEBUG_ENABLE='1' -e USER_ID="1000" kolemp/php-dev:$(PHP_VERSION)
