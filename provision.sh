#!/bin/bash

if [[ $(id -u) != "0" ]]; then
    sudo "$0" "$@"
    exit $?
fi

# Update the packages
apt update && sudo apt upgrade

# Install base packages
apt-get install zsh wget curl git unzip apache2 mysql-server libapache2-mod-fcgid nodejs npm redis

# Install oh-my-zsh and prep some stuff
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cat ./alias >> ~/.zshrc

# Happens after installing pip3
# if [ -d "$HOME/.local/bin" ] ; then
#     PATH="$HOME/.local/bin:$PATH"
# fi

# Install JS stuff
npm install -g yarn
npm install -g @vue/cli

# Copy SSH dir from mounted C drive
cp -r /c/Users/Dugi/.ssh ~/.ssh

# Apache config
service apache2 start

echo "AcceptFilter http none" >> /etc/apache2/apache2.conf
echo "AcceptFilter https none" >> /etc/apache2/apache2.conf

a2enmod rewrite
a2enmod ssl
a2enmod headers
a2enmod actions fcgid alias proxy_fcgi
service apache2 restart

# MySQL config
mysql_secure_installation
usermod -d /var/lib/mysql mysql
service mysql start

# Install PHP versions
add-apt-repository ppa:ondrej/php
add-apt-repository ppa:ondrej/apache2
apt-get update

apt-get install php7.3 php7.3-fpm php7.3-curl php7.3-mysql php7.3-xml php7.3-zip php7.3-gd php7.3-mbstring php7.3-bcmath php7.3-intl php7.3-dev 
apt-get install php7.2 php7.2-fpm php7.2-curl php7.2-mysql php7.2-xml php7.2-zip php7.2-gd php7.2-mbstring php7.2-bcmath php7.2-intl php7.2-dev
apt-get install php7.1 php7.1-fpm php7.1-curl php7.1-mysql php7.1-xml php7.1-zip php7.1-gd php7.1-mbstring php7.1-bcmath php7.1-intl php7.1-dev
apt-get install php7.0 php7.0-fpm php7.0-curl php7.0-mysql php7.0-xml php7.0-zip php7.0-gd php7.0-mbstring php7.0-bcmath php7.0-intl php7.0-dev

# Install xdebug
apt-get install php-xdebug

# Configre PHP settings
PHP_OVERRIDES="upload_max_filesize = 2500M
post_max_size = 2500M
display_errors = 1
error_reporting = E_ALL
memory_limit = 256M
phar.readonly = 0
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1"

echo > /etc/php/7.3/fpm/conf.d/99-overrides.ini "$PHP_OVERRIDES"
echo > /etc/php/7.2/fpm/conf.d/99-overrides.ini "$PHP_OVERRIDES"
echo > /etc/php/7.1/fpm/conf.d/99-overrides.ini "$PHP_OVERRIDES"
echo > /etc/php/7.0/fpm/conf.d/99-overrides.ini "$PHP_OVERRIDES"

a2enconf php7.0-fpm
a2enconf php7.1-fpm
a2enconf php7.2-fpm
a2enconf php7.3-fpm

service apache2 reload

# Install Composer
EXPECTED_SIGNATURE="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

if [[ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --quiet
RESULT=$?
rm composer-setup.php
mv ./composer.phar /usr/local/bin/composer

# Make scripts available
mv ./wsl_functions.sh /usr/local/bin/wsl_functions.sh
mv ./new_site.sh /usr/local/bin/ns
mv ./switch_php.sh /usr/local/bin/switch_php
mv ./wsl_start.sh /usr/local/bin/wsl_start
mv ./wsl_stop.sh /usr/local/bin/wsl_stop

# Start redis
service redis-server start
