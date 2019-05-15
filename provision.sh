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
chsh -s $(which zsh)

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

# Install and configure PHP versions
PHP_OVERRIDES="upload_max_filesize = 2500M
post_max_size = 2500M
display_errors = 1
error_reporting = E_ALL
memory_limit = 256M
phar.readonly = 0
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1"

for VERSION in 7.3 7.2 7.1 7.0
do
    apt-get install -y php"$VERSION" php"$VERSION"-fpm php"$VERSION"-curl \
        php"$VERSION"-mysql php"$VERSION"-xml php"$VERSION"-zip php"$VERSION"-gd \
        php"$VERSION"-mbstring php"$VERSION"-bcmath php"$VERSION"-intl php"$VERSION"-dev

    echo > /etc/php/"$VERSION"/fpm/conf.d/99-overrides.ini "$PHP_OVERRIDES"

    a2enconf php"$VERSION"-fpm
done

# Install xdebug
apt-get install -y php-xdebug

service apache2 reload
service php7.3-fpm reload
service php7.2-fpm reload
service php7.1-fpm reload
service php7.0-fpm reload

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
