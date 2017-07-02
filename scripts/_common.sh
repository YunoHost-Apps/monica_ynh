#
# Common variables
#

# monica git version
VERSION="v0.2.1"

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
  sudo wget -q -O "$rc_tarball" "$MONICA_SOURCE_URL" \
    || ynh_die "Unable to download monica tarball"
  sudo tar xf "$rc_tarball" -C "$DESTDIR" --strip-components 1 \
    || ynh_die "Unable to extract monica tarball"
  sudo rm "$rc_tarball"
}

# Remove a file or a directory securely
#
# usage: ynh_secure_remove path_to_remove
# | arg: path_to_remove - File or directory to remove
ynh_secure_remove () {
	path_to_remove=$1
	forbidden_path=" \
	/var/www \
	/home/yunohost.app"

	if [[ "$forbidden_path" =~ "$path_to_remove" \
		# Match all paths or subpaths in $forbidden_path
		|| "$path_to_remove" =~ ^/[[:alnum:]]+$ \
		# Match all first level paths from / (Like /var, /root, etc...)
		|| "${path_to_remove:${#path_to_remove}-1}" = "/" ]]
		# Match if the path finishes by /. Because it seems there is an empty variable
	then
		echo "Avoid deleting $path_to_remove." >&2
	else
		if [ -e "$path_to_remove" ]
		then
			sudo rm -R "$path_to_remove"
		else
			echo "$path_to_remove wasn't deleted because it doesn't exist." >&2
		fi
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
    sudo /usr/bin/php7.0 "${WORKDIR}/composer.phar" $@ \
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
        sudo /usr/bin/php7.0 -- --quiet --install-dir="$DESTDIR" \
    || ynh_die "Unable to install Composer"

  # update dependencies to create composer.lock
  exec_composer "$DESTDIR" install --no-dev --prefer-dist \
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

  architecture=$(uname -m)
  if [ $architecture == "armv7l" ]; then
    # arm package
    echo "deb http://repozytorium.mati75.eu/raspbian jessie-backports main contrib non-free" | sudo tee "/etc/apt/sources.list.d/php7.list"
    sudo gpg --keyserver pgpkeys.mit.edu --recv-key CCD91D6111A06851
    sudo gpg --armor --export CCD91D6111A06851 | sudo apt-key add -
  else
    # x86 package
    echo "deb https://packages.dotdeb.org jessie all" | sudo tee "/etc/apt/sources.list.d/php7.list"
    curl http://www.dotdeb.org/dotdeb.gpg | sudo apt-key add -
  fi

  ynh_package_update
  ynh_package_install php7.0 --no-install-recommends
  sudo update-alternatives --install /usr/bin/php php /usr/bin/php5 70
}

ynh_remove_php7 () {
  sudo rm -f /etc/apt/sources.list.d/php7.list
  sudo apt-key del 4096R/89DF5277
  sudo apt-key del 2048R/11A06851
  ynh_package_remove php7.0 php7.0-fpm php7.0-mysql php7.0-xml php7.0-intl php7.0-mbstring
}

