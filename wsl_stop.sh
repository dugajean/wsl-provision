#!/bin/bash

if [ $(id -u) != "0" ]
then
    sudo "$0" "$@"
    exit $?
fi

source wsl_functions.sh

echo "Turning off Apache"
service apache2 stop > /dev/null

echo "Turning off PHP-FPM(s)"
service php7.3-fpm stop > /dev/null
service php7.2-fpm stop > /dev/null
service php7.1-fpm stop > /dev/null
service php7.0-fpm stop > /dev/null

echo "Turning off MySQL"
service mysql stop > /dev/null

echo "Turning off Redis"
service redis-server stop > /dev/null

CHECK=$'\u2713'
colored_echo "GREEN" ""
colored_echo "GREEN" "[${CHECK}] Done!"