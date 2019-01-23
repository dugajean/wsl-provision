#!/bin/bash

if [ $(id -u) != "0" ]
then
    sudo "$0" "$@"
    exit $?
fi

source wsl_functions.sh

read -p 'Enter the website domain: ' SITE_DOMAIN
read -p 'Specify the new PHP version this site should run on (7.0, 7.1, 7.2, 7.3): ' SITE_PHP_VERSION

SITE_CONF_PATH=/etc/apache2/sites-available/"$SITE_DOMAIN".conf

# Validate website path
if [ ! -f $SITE_CONF_PATH ]
then 
    echo ""
    colored_echo "RED" "[!] Requested website does not exist." >&2
    exit 1
fi

# Validate PHP version
PHP_VERSIONS=(7.0 7.1 7.2 7.3)
if ! printf '%s\n' ${PHP_VERSIONS[@]} | grep -q -P "^"$SITE_PHP_VERSION"$"; then
    echo ""
    colored_echo "RED" "[!] Invalid PHP version specified. Please choose from these options: 7.0, 7.1, 7.2, 7.3" >&2
    exit 1
fi

SITE_CONF_FILE=$(cat $SITE_CONF_PATH)

# Perform the replacement
echo "$SITE_CONF_FILE" | perl -pe "s/php[0-9.]+/php$SITE_PHP_VERSION/g" > $SITE_CONF_PATH

CHECK=$'\u2713'
echo ""
colored_echo "GREEN" "[${CHECK}] PHP version successfully changed for $SITE_DOMAIN!"