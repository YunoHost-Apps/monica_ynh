#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

# dependencies used by the app
pkg_dependencies="redis-server"

YNH_PHP_VERSION="7.3"

extra_php_dependencies="php${YNH_PHP_VERSION}-cli php${YNH_PHP_VERSION}-json php${YNH_PHP_VERSION}-opcache php${YNH_PHP_VERSION}-mysql php${YNH_PHP_VERSION}-mbstring php${YNH_PHP_VERSION}-zip php${YNH_PHP_VERSION}-bcmath php${YNH_PHP_VERSION}-intl php${YNH_PHP_VERSION}-xml php${YNH_PHP_VERSION}-curl php${YNH_PHP_VERSION}-gd php${YNH_PHP_VERSION}-gmp php${YNH_PHP_VERSION}-redis"

#=================================================
# PERSONAL HELPERS
#=================================================

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
