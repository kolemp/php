SHELL = /bin/bash
TAG = "kolemp/php-dev:$(PHP_VERSION)"

build:
	@if [ "$(PHP_VERSION)" == "" ]; then echo "PHP_VERSION is required"; exit 1; fi;
	docker run --rm -e PHP_VERSION=$(PHP_VERSION) -v /`pwd`:/data kolemp/twig-renderer /data/Dockerfile.twig > ./Dockerfile
	docker build -t $(TAG) .
