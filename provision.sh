#!/bin/bash

if [ $(id -u) != "0" ]
then
    sudo "$0" "$@"
    exit $?
fi

# Update the packages
apt update && sudo apt upgrade

# Install base packages
apt-get install zsh wget curl git apache2 mysql-server libapache2-mod-fcgid

# Install oh-my-zsh and prep aliases
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
cat ./alias >> ~/.zshrc

# Copy SSH dir from mounted C drive
cp -r /mnt/c/Users/Lenovo/.ssh ~/.ssh

# Apache config
service apache2 start

echo "AcceptFilter http none
AcceptFilter https none" >> /etc/apache2/apache2.conf

a2enmod rewrite
a2enmod actions fcgid alias proxy_fcgi
service apache2 restart

# MySQL config
usermod -d /var/lib/mysql mysql
service mysql start

# Install PHP versions
add-apt-repository ppa:ondrej/php
add-apt-repository ppa:ondrej/apache2
apt-get update

apt-get install php7.3 php7.3-fpm php7.3-curl php7.3-mysql php7.3-xml php7.3-zip php7.3-gd php7.3-mbstring php7.3-dev
apt-get install php7.2 php7.2-fpm php7.2-curl php7.2-mysql php7.2-xml php7.2-zip php7.2-gd php7.2-mbstring php7.2-dev
apt-get install php7.1 php7.1-fpm php7.1-curl php7.1-mysql php7.1-xml php7.1-zip php7.1-gd php7.1-mbstring php7.1-dev
apt-get install php7.0 php7.0-fpm php7.0-curl php7.0-mysql php7.0-xml php7.0-zip php7.0-gd php7.0-mbstring php7.0-dev

service apache2 restart

# Install Composer
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv ./composer.phar /usr/local/bin/composer

# Make scripts available
mv ./new_site.sh /usr/local/bin/ns
mv ./wsl_start.sh /usr/local/bin/wsl_start
mv ./wsl_stop.sh /usr/local/bin/wsl_stop