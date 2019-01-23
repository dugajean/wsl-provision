#!/bin/bash

if [ $(id -u) != "0" ]
then
    sudo "$0" "$@"
    exit $?
fi

echo "Turning on Apache"
service apache2 start > /dev/null

echo "Turning on PHP-FPM(s)"
service php7.3-fpm start > /dev/null
service php7.2-fpm start > /dev/null
service php7.1-fpm start > /dev/null
service php7.0-fpm start > /dev/null

echo "Turning on MySQL"
service mysql start > /dev/null

echo "Turning on Redis"
service redis-server start > /dev/null

echo "Turning on Cron"
service cron start > /dev/null

CHECK=$'\u2713'
echo ""
echo "[${CHECK}] Done!"