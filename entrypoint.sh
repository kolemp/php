#!/bin/bash

create_user () {
  echo "docker UID: $1"
  id -u docker > /dev/null 2>&1 || adduser --disabled-password  --gecos "" --home /home/docker --shell /bin/sh --uid $1 docker
}

if [ "$XDEBUG_ENABLE" == "1" ]; then
  sed -i "s/^;\+//g" "/etc/php/$PHP_VERSION/fpm/conf.d/20-xdebug.ini"
  sed -i "s/^;\+//g" "/etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini"
else
  sed -i "s/^/;/g" "/etc/php/$PHP_VERSION/fpm/conf.d/20-xdebug.ini"
  sed -i "s/^/;/g" "/etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini"
fi

if [ "$USER_ID" == "" ]; then
  echo "Variable USER_ID not set! Running as root!"
  create_user 1000
  exec "$@"
else
  create_user $USER_ID
  if [ "$1" != "bash" ] && [ "$1" != "php-fpm$PHP_VERSION" ]; then
      gosu docker "$@"
  else
      exec "$@"
  fi
fi
