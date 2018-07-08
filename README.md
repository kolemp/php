# PHP for development environment
This repo is suited for development environment

## PHP info

- 7.2 installed modules: apcu bcmath curl dom fpm gd gmp imagick intl ldap mbstring memcached mysql soap xdebug zip
- 7.0 installed modules: apcu bcmath curl dom fpm gd gmp imagick intl ldap mbstring memcached mysql soap xdebug zip

## Usage

### Setting user

By default, like most of other images, this executes all the commands as root. But we discourage you to do so. 
Instead you can pass `USER_ID` variable so all the commands (**except bash**) will be executed as user docker with given uid. 
This rule will not apply to the bash command because we want to give you a way to login as root to debug issues.

Why would you want to do it this way? There are two mayor reasons: 
- if somehow user would escape container you do not want it to have userId=0 (root)
- on linux machines all cache produced by dev containers is normally owned by root and it produces a lot of issues

```bash
# Pass your local uid to container so all files generated will have proper ownership

id -u
# > 501

docker run -e "USER_ID=$(id -u)" kolemp/php-dev php -r "echo shell_exec('id -u');"
# > 501

docker run -e "USER_ID=$(id -u)" kolemp/php-dev id -u
# > 501

docker run -e "USER_ID=$(id -u)" kolemp/php-dev bash -c 'id -u'
# > 0
```

### Using xdebug

For performance reasons xdebug is disabled by default. To enable it you need to setup `XDEBUG_ENABLE=1` environment variable:
 
```bash
docker run -e "XDEBUG_ENABLE=1" -it kolemp/php-dev php -m | grep xdebug
```

### Customisations

You can customize few core configuration variables via env. Here are the variables and their default values:

```bash
PHP_CLI_MEMORY_LIMIT='128M'

PHP_FPM_MEMORY_LIMIT='128M'
PHP_FPM_USER='docker'
PHP_FPM_GROUP='docker'
PHP_FPM_LISTEN='0.0.0.0:9000'
PHP_FPM_PM_MAX_CHILDREN='5'
PHP_FPM_PM_START_SERVERS='2'
PHP_FPM_PM_MIN_SPARE_SERVERS='1'
PHP_FPM_PM_MAX_SPARE_SERVERS='3'
PHP_FPM_REQUEST_TERMINATE_TIMEOUT='0'
```
