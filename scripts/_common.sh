#
# Common variables
#

# monica git version
VERSION="c94da55a"

# Remote URL to fetch monica source tarball
MONICA_SOURCE_URL="https://github.com/monicahq/monica/archive/${VERSION}.tar.gz"

# App package root directory should be the parent folder
PKGDIR=$(cd ../; pwd)

#
# Common helpers
#

# Download and extract monica sources to the given directory
# usage: extract_monica_to DESTDIR
extract_monica() {
  local DESTDIR=$1

  # retrieve and extract monica tarball
  rc_tarball="${DESTDIR}/monica.tar.gz"
  wget -q -O "$rc_tarball" "$MONICA_SOURCE_URL" \
    || ynh_die "Unable to download monica tarball"
  tar xf "$rc_tarball" -C "$DESTDIR" --strip-components 1 \
    || ynh_die "Unable to extract monica tarball"
  sudo rm "$rc_tarball"
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

# Execute a composer command from a given directory
# usage: composer_exec AS_USER WORKDIR COMMAND [ARG ...]
exec_composer() {
  local WORKDIR=$1
  shift 1

  COMPOSER_HOME="${WORKDIR}/.composer" \
    /usr/bin/php7.0 "${WORKDIR}/composer.phar" $@ \
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
        /usr/bin/php7.0 -- --quiet --install-dir="$DESTDIR" \
    || ynh_die "Unable to install Composer"

  # update dependencies to create composer.lock
  exec_composer "$DESTDIR" install --no-dev --prefer-dist \
    || ynh_die "Unable to update monica core dependencies"
}

#=================================================
# NODEJS
#=================================================

sudo_path () {
	sudo env "PATH=$PATH" $@
}

# INFOS
# nvm utilise la variable PATH pour stocker le path de la version de node à utiliser.
# C'est ainsi qu'il change de version
# En attendant une généralisation de root, il est possible d'utiliser sudo aevc le helper temporaire sudo_path
# Il permet d'utiliser sudo en gardant le $PATH modifié
# ynh_install_nodejs installe la version de nodejs demandée en argument, avec nvm
# ynh_use_nodejs active une version de nodejs dans le script courant
# 3 variables sont mises à disposition, et 2 sont stockées dans la config de l'app
# - nodejs_path: Le chemin absolu de cette version de node
# Utilisé pour des appels directs à npm ou node.
# - nodejs_version: Simplement le numéro de version de nodejs pour cette application
# - nodejs_use_version: Un alias pour charger une version de node dans le shell courant.
# Utilisé pour démarrer un service ou un script qui utilise node ou npm
# Dans ce cas, c'est $PATH qui contient le chemin de la version de node. Il doit être propagé sur les autres shell si nécessaire.

nvm_install_dir="/opt/nvm"
ynh_use_nodejs () {
	nodejs_path=$(ynh_app_setting_get $app nodejs_path)
	nodejs_version=$(ynh_app_setting_get $app nodejs_version)

	# And store the command to use a specific version of node. Equal to `nvm use version`
	nodejs_use_version="source $nvm_install_dir/nvm.sh; nvm use \"$nodejs_version\""

	# Desactive set -u for this script.
	set +u
	eval $nodejs_use_version
	set -u
}

ynh_install_nodejs () {
	local nodejs_version="$1"
	local nvm_install_script="https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh"

	local nvm_exec="source $nvm_install_dir/nvm.sh; nvm"

	sudo mkdir -p "$nvm_install_dir"

	# If nvm is not previously setup, install it
	"$nvm_exec --version" > /dev/null 2>&1 || \
	( cd "$nvm_install_dir"
	echo "Installation of NVM"
	sudo wget --no-verbose "$nvm_install_script" -O- | sudo NVM_DIR="$nvm_install_dir" bash > /dev/null)

	# Install the requested version of nodejs
	sudo su -c "$nvm_exec install \"$nodejs_version\" > /dev/null"

	# Store the ID of this app and the version of node requested for it
	echo "$YNH_APP_ID:$nodejs_version" | sudo tee --append "$nvm_install_dir/ynh_app_version"

	# Get the absolute path of this version of node
	nodejs_path="$(dirname "$(sudo su -c "$nvm_exec which \"$nodejs_version\"")")"

	# Store nodejs_path and nodejs_version into the config of this app
	ynh_app_setting_set $app nodejs_path $nodejs_path
	ynh_app_setting_set $app nodejs_version $nodejs_version

	ynh_use_nodejs
}

ynh_remove_nodejs () {
	nodejs_version=$(ynh_app_setting_get $app nodejs_version)

	# Remove the line for this app
	sudo sed --in-place "/$YNH_APP_ID:$nodejs_version/d" "$nvm_install_dir/ynh_app_version"

	# If none another app uses this version of nodejs, remove it.
	if ! grep --quiet "$nodejs_version" "$nvm_install_dir/ynh_app_version"
	then
		sudo su -c "source $nvm_install_dir/nvm.sh; nvm deactivate; nvm uninstall \"$nodejs_version\" > /dev/null"
	fi

	# If none another app uses nvm, remove nvm and clean the root's bashrc file
	if [ ! -s "$nvm_install_dir/ynh_app_version" ]
	then
		ynh_secure_remove "$nvm_install_dir"
		sudo sed --in-place "/NVM_DIR/d" /root/.bashrc
	fi
}

ynh_install_php7 () {
  sudo echo 'deb https://packages.dotdeb.org jessie all' > /etc/apt/sources.list.d/dotdeb.list
  curl http://www.dotdeb.org/dotdeb.gpg | sudo apt-key add -
  ynh_package_update
  ynh_package_install apt-transport-https --no-install-recommends
  ynh_package_install php7.0 php7.0-fpm php7.0-mysql php7.0-xml php7.0-intl php7.0-mbstring --no-install-recommends
  sudo update-alternatives --install /usr/bin/php php /usr/bin/php5 70
}

ynh_remove_php7 () {
  sudo rm -f /etc/apt/sources.list.d/dotdeb.list
  sudo apt-key del 4096R/89DF5277
  ynh_package_update
  ynh_package_remove php7.0 php7.0-fpm php7.0-mysql php7.0-xml php7.0-intl php7.0-mbstring
}

