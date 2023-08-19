# PHP for development/production environment
This repo is suited for PHP environment (targeting symfony applications)

## Using it on production
This repository is under MIT licence so you use it on your own responsibility.
Remember that production images require periodical security scanning and updates! Please treat this repo as a template for your production one.

## PHP info

- 7.3 installed modules: apcu bcmath curl dom gd gmp imagick intl ldap mbstring memcached pdo_mysql soap xdebug zip sqlite3
- 7.2 installed modules: apcu bcmath curl dom gd gmp imagick intl ldap mbstring memcached pdo_mysql soap xdebug zip sqlite3
- 7.1 installed modules: apcu bcmath curl dom gd gmp imagick intl ldap mbstring memcached pdo_mysql soap xdebug zip sqlite3
- 7.0 installed modules: apcu bcmath curl dom gd gmp imagick intl ldap mbstring memcached pdo_mysql soap xdebug zip sqlite3

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

Detailed instructions about how to use xdebug you can find [here](docs/xdebug.md).

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

## Development

### Build locally


```
make build PHP_VERSION=7.3 APP_ENV=prod
```