#!/bin/bash

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
  id -u docker > /dev/null 2>&1 || adduser --disabled-password  --gecos "" --home /home/docker --shell /bin/sh --uid $USER_ID docker &>/dev/null
  if [ "$1" != "bash" ] && [ "$1" != "php-fpm$PHP_VERSION" ]; then
      gosu docker "$@"
  else
      exec "$@"
  fi
fi
