FROM debian:stretch-slim

RUN apt-get update \
    && apt-get install -y apt-transport-https lsb-release ca-certificates wget curl \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    apt-get install -y --force-yes php7.0 php7.0-soap php7.0-fpm  \
        php7.0-mysql php7.0-apcu php7.0-gd php7.0-imagick php7.0-curl php7.0-common \
        php7.0-intl php7.0-memcached php7.0-dom php7.0-bcmath php7.0-zip \
        php7.0-mbstring php7.0-ldap php7.0-gmp php7.0-xdebug gnupg && \
        rm -rf /var/lib/apt/lists/* && \
        mkdir -p /run/php/ && \
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
	rm -rf /var/lib/apt/lists/*;

RUN set -ex; \
# verify the signature. This is in separate step due to its often failures (servers issues?).
	export GNUPGHOME="$(mktemp -d)"; \
	export GPG_KEYS=B42F6819007F00F88E364FD4036A9C25BF357DD4; \
	( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
      || gpg --keyserver keyserver.ubuntu.com --recv-keys "$GPG_KEYS" \
      || gpg --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys "$GPG_KEYS" \
      || gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$GPG_KEYS" \
      || gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEYS" ) && \
	gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
	rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc; \
	\
	chmod +x /usr/local/bin/gosu; \
# verify that the binary works
	gosu nobody true;

#######################################################################################################

RUN apt-get update && apt-get install -y openssl git && apt-get purge -y --auto-remove

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod 700 /usr/local/bin/entrypoint && chown root:root /usr/local/bin/entrypoint

ENV APP_ENV 'dev'
ENV PHP_VERSION '7.0'

RUN \
  sed -i "s/^memory_limit = .*/memory_limit = \"\${PHP_CLI_MEMORY_LIMIT}\"/g" "/etc/php/$PHP_VERSION/cli/php.ini"; \
  \
  sed -i "s/^;\?access\.log = .*/access.log = \/proc\/self\/fd\/2/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^;\?error_log = .*/error_log = \/proc\/self\/fd\/2/g" "/etc/php/$PHP_VERSION/fpm/php-fpm.conf"; \
  sed -i "s/^;\?catch_workers_output = .*/catch_workers_output = yes/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^;\?clear_env = .*/clear_env = no/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  \
  sed -i "s/^memory_limit = .*/memory_limit = \"\${PHP_FPM_MEMORY_LIMIT}\"/g" "/etc/php/$PHP_VERSION/fpm/php.ini"; \
  sed -i "s/max_execution_time = 30/max_execution_time = \"\${PHP_FPM_MAX_EXEC_TIME}\"/g" "/etc/php/$PHP_VERSION/fpm/php.ini"; \
  sed -i "s/^user = .*/user = \"\${PHP_FPM_USER}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^group = .*/group = \"\${PHP_FPM_GROUP}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^listen = .*/listen = \"\${PHP_FPM_LISTEN}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^pm\.max_children = .*/pm.max_children = \"\${PHP_FPM_PM_MAX_CHILDREN}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^pm\.start_servers = .*/pm.start_servers = \"\${PHP_FPM_PM_START_SERVERS}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^pm\.min_spare_servers = .*/pm.min_spare_servers = \"\${PHP_FPM_PM_MIN_SPARE_SERVERS}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^pm\.max_spare_servers = .*/pm.max_spare_servers = \"\${PHP_FPM_PM_MAX_SPARE_SERVERS}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf"; \
  sed -i "s/^;\?request_terminate_timeout = .*/request_terminate_timeout = \"\${PHP_FPM_REQUEST_TERMINATE_TIMEOUT}\"/g" "/etc/php/$PHP_VERSION/fpm/pool.d/www.conf";

ENV PHP_CLI_MEMORY_LIMIT '128M'

ENV PHP_FPM_MEMORY_LIMIT '128M'
ENV PHP_FPM_USER 'docker'
ENV PHP_FPM_GROUP 'docker'
ENV PHP_FPM_LISTEN '0.0.0.0:9000'
ENV PHP_FPM_PM_MAX_CHILDREN '5'
ENV PHP_FPM_PM_START_SERVERS '2'
ENV PHP_FPM_PM_MIN_SPARE_SERVERS '1'
ENV PHP_FPM_PM_MAX_SPARE_SERVERS '3'
ENV PHP_FPM_REQUEST_TERMINATE_TIMEOUT '0'
ENV PHP_FPM_MAX_EXEC_TIME '30'

WORKDIR /data/application

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["php-fpm7.0", "-F"]

EXPOSE 9000
