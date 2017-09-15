#!/bin/bash

# =============================================================================
#                     YUNOHOST 2.7 FORTHCOMING HELPERS
# =============================================================================

# Create a dedicated nginx config
#
# usage: ynh_add_nginx_config
ynh_add_nginx_config () {
	finalnginxconf="/etc/nginx/conf.d/$domain.d/$app.conf"
	ynh_backup_if_checksum_is_different "$finalnginxconf"
	sudo cp ../conf/nginx.conf "$finalnginxconf"

	# To avoid a break by set -u, use a void substitution ${var:-}. If the variable is not set, it's simply set with an empty variable.
	# Substitute in a nginx config file only if the variable is not empty
	if test -n "${path_url:-}"; then
		ynh_replace_string "__PATH__" "$path_url" "$finalnginxconf"
	fi
	if test -n "${domain:-}"; then
		ynh_replace_string "__DOMAIN__" "$domain" "$finalnginxconf"
	fi
	if test -n "${port:-}"; then
		ynh_replace_string "__PORT__" "$port" "$finalnginxconf"
	fi
	if test -n "${app:-}"; then
		ynh_replace_string "__NAME__" "$app" "$finalnginxconf"
	fi
	if test -n "${final_path:-}"; then
		ynh_replace_string "__FINALPATH__" "$final_path" "$finalnginxconf"
	fi
	ynh_store_file_checksum "$finalnginxconf"

	sudo systemctl reload nginx
}

# Remove the dedicated nginx config
#
# usage: ynh_remove_nginx_config
ynh_remove_nginx_config () {
	ynh_secure_remove "/etc/nginx/conf.d/$domain.d/$app.conf"
	sudo systemctl reload nginx
}

# Create a dedicated php-fpm config
#
# usage: ynh_add_fpm_config
ynh_add_fpm_config () {
	finalphpconf="/etc/php5/fpm/pool.d/$app.conf"
	ynh_backup_if_checksum_is_different "$finalphpconf"
	sudo cp ../conf/php-fpm.conf "$finalphpconf"
	ynh_replace_string "__NAMETOCHANGE__" "$app" "$finalphpconf"
	ynh_replace_string "__FINALPATH__" "$final_path" "$finalphpconf"
	ynh_replace_string "__USER__" "$app" "$finalphpconf"
	sudo chown root: "$finalphpconf"
	ynh_store_file_checksum "$finalphpconf"

	if [ -e "../conf/php-fpm.ini" ]
	then
		finalphpini="/etc/php5/fpm/conf.d/20-$app.ini"
		ynh_backup_if_checksum_is_different "$finalphpini"
		sudo cp ../conf/php-fpm.ini "$finalphpini"
		sudo chown root: "$finalphpini"
		ynh_store_file_checksum "$finalphpini"
	fi

	sudo systemctl reload php5-fpm
}

# Remove the dedicated php-fpm config
#
# usage: ynh_remove_fpm_config
ynh_remove_fpm_config () {
	ynh_secure_remove "/etc/php5/fpm/pool.d/$app.conf"
	ynh_secure_remove "/etc/php5/fpm/conf.d/20-$app.ini" 2>&1
	sudo systemctl reload php5-fpm
}

# Create a dedicated systemd config
#
# usage: ynh_add_systemd_config
ynh_add_systemd_config () {
	finalsystemdconf="/etc/systemd/system/$app.service"
	ynh_backup_if_checksum_is_different "$finalsystemdconf"
	sudo cp ../conf/systemd.service "$finalsystemdconf"

	# To avoid a break by set -u, use a void substitution ${var:-}. If the variable is not set, it's simply set with an empty variable.
	# Substitute in a nginx config file only if the variable is not empty
	if test -n "${final_path:-}"; then
		ynh_replace_string "__FINALPATH__" "$final_path" "$finalsystemdconf"
	fi
	if test -n "${app:-}"; then
		ynh_replace_string "__APP__" "$app" "$finalsystemdconf"
	fi
	ynh_store_file_checksum "$finalsystemdconf"

	sudo chown root: "$finalsystemdconf"
	sudo systemctl enable $app
	sudo systemctl daemon-reload
}

# Remove the dedicated systemd config
#
# usage: ynh_remove_systemd_config
ynh_remove_systemd_config () {
	finalsystemdconf="/etc/systemd/system/$app.service"
	if [ -e "$finalsystemdconf" ]; then
		sudo systemctl stop $app
		sudo systemctl disable $app
		ynh_secure_remove "$finalsystemdconf"
	fi
}

# Execute a command as another user
# usage: exec_as USER COMMAND [ARG ...]
exec_as() {
  local USER=$1
  shift 1

  if [[ $USER = $(whoami) ]]; then
    eval $@
  else
    # use sudo twice to be root and be allowed to use another user
    sudo sudo -u "$USER" $@
  fi
}

#
# Composer helpers
#

# Execute a composer command from a given directory
# usage: composer_exec AS_USER WORKDIR COMMAND [ARG ...]
exec_composer() {
  local WORKDIR=$1
  shift 1

  COMPOSER_HOME="${WORKDIR}/.composer" \
    sudo /usr/bin/php7.1 "${WORKDIR}/composer.phar" $@ \
      -d "${WORKDIR}" --quiet --no-interaction
}

# Install and initialize Composer in the given directory
# usage: init_composer DESTDIR [AS_USER]
init_composer() {
  local DESTDIR=$1
  local AS_USER=${2:-admin}

  # install composer
  curl -sS https://getcomposer.org/installer \
    | COMPOSER_HOME="${DESTDIR}/.composer" \
        sudo /usr/bin/php7.1 -- --quiet --install-dir="$DESTDIR" \
    || ynh_die "Unable to install Composer"

  # update dependencies to create composer.lock
  exec_composer "$DESTDIR" install --quiet --no-dev --prefer-dist \
    || ynh_die "Unable to update monica core dependencies"
}

#
# NodeJS helpers
#

sudo_path () {
	sudo env "PATH=$PATH" $@
}

# INFOS
# n (Node version management) utilise la variable PATH pour stocker le path de la version de node à utiliser.
# C'est ainsi qu'il change de version
# En attendant une généralisation de root, il est possible d'utiliser sudo avec le helper temporaire sudo_path
# Il permet d'utiliser sudo en gardant le $PATH modifié
# ynh_install_nodejs installe la version de nodejs demandée en argument, avec n
# ynh_use_nodejs active une version de nodejs dans le script courant
# 3 variables sont mises à disposition, et 2 sont stockées dans la config de l'app
# - nodejs_path: Le chemin absolu de cette version de node
# Utilisé pour des appels directs à node.
# - nodejs_version: Simplement le numéro de version de nodejs pour cette application
# - nodejs_use_version: Un alias pour charger une version de node dans le shell courant.
# Utilisé pour démarrer un service ou un script qui utilise node ou npm
# Dans ce cas, c'est $PATH qui contient le chemin de la version de node. Il doit être propagé sur les autres shell si nécessaire.

n_install_dir="/opt/node_n"
ynh_use_nodejs () {
	nodejs_version=$(ynh_app_setting_get $app nodejs_version)

	load_n_path="[[ :$PATH: == *\":$n_install_dir/bin:\"* ]] || PATH+=\":$n_install_dir/bin\""

	nodejs_use_version="n $nodejs_version"

	# "Load" a version of node
	eval $load_n_path; $nodejs_use_version
	eval $load_n_path; sudo env "PATH=$PATH" $nodejs_use_version

	# Get the absolute path of this version of node
	nodejs_path="$(n bin $nodejs_version)"

	# Make an alias for node use
	ynh_node_exec="eval $load_n_path; n use $nodejs_version"
	sudo_ynh_node_exec="eval $load_n_path; sudo env \"PATH=$PATH\" n use $nodejs_version"
}

ynh_install_nodejs () {
	# Use n, https://github.com/tj/n to manage the nodejs versions
	local nodejs_version="$1"
	local n_install_script="https://git.io/n-install"

	# Create $n_install_dir
	sudo mkdir -p "$n_install_dir"

	# Load n path in PATH
	PATH+=":$n_install_dir/bin"

	# If n is not previously setup, install it
	n --version > /dev/null 2>&1 || \
	( echo "Installation of N - Node.js version management" >&2; \
	curl -sL $n_install_script | sudo N_PREFIX="$n_install_dir" bash -s -- -y $nodejs_version )

	# Install the requested version of nodejs (except for the first installation of n, which installed the requested version of node.)
	sudo env "PATH=$PATH" n $nodejs_version

	# Use the real installed version. Sometimes slightly different
	nodejs_version=$(node --version | cut -c2-)

	# Store the ID of this app and the version of node requested for it
	echo "$YNH_APP_ID:$nodejs_version" | sudo tee --append "$n_install_dir/ynh_app_version"

	# Store nodejs_version into the config of this app
	ynh_app_setting_set $app nodejs_version $nodejs_version

	ynh_use_nodejs
}

ynh_remove_nodejs () {
	ynh_use_nodejs

	# Remove the line for this app
	sudo sed --in-place "/$YNH_APP_ID:$nodejs_version/d" "$n_install_dir/ynh_app_version"

	# If none another app uses this version of nodejs, remove it.
	if ! grep --quiet "$nodejs_version" "$n_install_dir/ynh_app_version"
	then
		n rm $nodejs_version
	fi

	# If none another app uses n, remove n
	if [ ! -s "$n_install_dir/ynh_app_version" ]
	then
		ynh_secure_remove "$n_install_dir"
		sudo sed --in-place "/N_PREFIX/d" /root/.bashrc
	fi
}

#
# PHP7 helpers
#

ynh_install_php7 () {

  ynh_package_update
  ynh_package_install apt-transport-https --no-install-recommends

  wget -q -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
  echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/php7.list

  ynh_package_update
  ynh_package_install php7.1 --no-install-recommends
  sudo update-alternatives --install /usr/bin/php php /usr/bin/php5 70
}

ynh_remove_php7 () {
  sudo rm -f /etc/apt/sources.list.d/php7.list
  sudo apt-key del 4096R/89DF5277
  sudo apt-key del 2048R/11A06851
  ynh_package_remove php7.1 php7.1-fpm php7.1-mysql php7.1-xml php7.1-intl php7.1-mbstring
}

