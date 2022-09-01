#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

YNH_PHP_VERSION="7.4"

YNH_COMPOSER_VERSION="2.2.5"

php_dependencies="php${YNH_PHP_VERSION}-bcmath php${YNH_PHP_VERSION}-cli php${YNH_PHP_VERSION}-curl php${YNH_PHP_VERSION}-dom php${YNH_PHP_VERSION}-gd php${YNH_PHP_VERSION}-gmp php${YNH_PHP_VERSION}-iconv php${YNH_PHP_VERSION}-intl php${YNH_PHP_VERSION}-json php${YNH_PHP_VERSION}-mbstring php${YNH_PHP_VERSION}-mysql php${YNH_PHP_VERSION}-mysqli php${YNH_PHP_VERSION}-opcache php${YNH_PHP_VERSION}-redis php${YNH_PHP_VERSION}-xml php${YNH_PHP_VERSION}-zip"

# dependencies used by the app (must be on a single line)
pkg_dependencies="$php_dependencies"

NODEJS_VERSION=16

#=================================================
# PERSONAL HELPERS
#=================================================

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
