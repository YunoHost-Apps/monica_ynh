#!/bin/bash

source helpers/ynh_add_extra_apt_repos__3
source helpers/ynh_install_php__3
source helpers/ynh_composer__2

# =============================================================================
#                     YUNOHOST 2.7 FORTHCOMING HELPERS
# =============================================================================

# Create a dedicated php-fpm config
#
# usage: ynh_add_fpm_config
ynh_add_fpm7.2_config () {
  ynh_add_fpm_config --phpversion="7.2"
}

#
# Composer helpers
#

# Install and initialize Composer in the given directory
# usage: init_composer
init_composer() {
  ynh_install_composer --phpversion="7.2" --workdir="$final_path"

  # update dependencies to create composer.lock
  ynh_composer_exec --phpversion="7.2" --workdir="$final_path" --commands="install --no-dev --prefer-dist" \
    || ynh_die "Unable to update monica core dependencies"
}

#
# PHP7 helpers
#
pkg_dependencies="php7.2-cli php7.2-json php7.2-opcache php7.2-mysql php7.2-mbstring php7.2-zip php7.2-bcmath php7.2-intl php7.2-xml php7.2-curl php7.2-gd php7.2-gmp"

ynh_install_php7.2 () {
  ynh_install_php --phpversion="7.2" --package="$pkg_dependencies"
}
