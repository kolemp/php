# CHANGELOG.md

## 2021-04-12

Features:
  - add sqlite3 extension required by latest symfony

## 2019-03-21

Features:

  - add PHP 7.3
  - use gosu [from debian repo](https://github.com/tianon/gosu/blob/master/INSTALL.md#from-debian) (yay!)
  - add prod images definitions
  - add `PHP_FPM_LISTEN_MODE` variable required to use when talking to nginx via socket on k8s
  
## 2019-01-27

Features:

  - switch from native Docker builds to [CircleCI](https://circleci.com/)
  - add tagging images with build dates so users can refer to specific image
  - add changelog

Fixes:

  - add config file for xdebug so it will work out of the box