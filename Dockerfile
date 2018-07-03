FROM debian:stretch-slim

RUN apt-get update \
    && apt-get install -y apt-transport-https lsb-release ca-certificates wget curl \
    && wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
    && echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y --force-yes php7.2 php7.2-soap php7.2-fpm  \
        php7.2-mysql php7.2-apcu php7.2-gd php7.2-imagick php7.2-curl php7.2-common \
        php7.2-intl php7.2-memcached php7.2-dom php7.2-bcmath php7.2-zip \
        php7.2-mbstring php7.2-ldap php7.2-gmp php7.2-xdebug gnupg && \
        rm -rf /var/lib/apt/lists/* && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# GOSU ################################################################################################
ENV GOSU_VERSION 1.10
RUN set -ex; \
	\
	fetchDeps=' \
		ca-certificates \
		wget \
	'; \
	apt-get update; \
	apt-get install -y --no-install-recommends $fetchDeps; \
	rm -rf /var/lib/apt/lists/*; \
	\
	dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
	wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
	\
# verify the signature
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu nobody true; \
	\
	rm -rf /var/lib/apt/lists/*;

#######################################################################################################

RUN cat /etc/apt/sources.list.d/php.list
RUN apt-get update && apt-get install -y openssl git && apt-get purge -y --auto-remove
RUN ls -la /usr/bin
RUN composer global require hirak/prestissimo; composer config --global sort-packages true

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod 700 /usr/local/bin/entrypoint && chown root:root /usr/local/bin/entrypoint

ENV APP_ENV 'dev'

WORKDIR /data/application

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["php-fpm", "-F"]

EXPOSE 9000
