#!/bin/bash

PHP_VERSION="7.2"

if [ "$XDEBUG_ENABLE" == "1" ]; then
  sed -i "s/^;\+//g" "/etc/php/$PHP_VERSION/fpm/conf.d/20-xdebug.ini"
  sed -i "s/^;\+//g" "/etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini"
else
  sed -i "s/^/;/g" "/etc/php/$PHP_VERSION/fpm/conf.d/20-xdebug.ini"
  sed -i "s/^/;/g" "/etc/php/$PHP_VERSION/cli/conf.d/20-xdebug.ini"
fi


if [ "$USER_ID" == "" ]; then
  echo "Variable USER_ID not set! Running as root!"
  exec "$@"
else
  if [ "$1" == "php" ] || [ "$1" == "php-fpm" ] || [ "$1" == "composer" ]; then
      id -u docker > /dev/null 2>&1 || adduser --disabled-password  --gecos "" --home /home/docker --shell /bin/sh --uid $USER_ID docker &>/dev/null
      gosu docker "$@"
  else
      exec "$@"
  fi
fi
