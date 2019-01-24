#!/bin/bash

if [ $(id -u) != "0" ]; then
    sudo "$0" "$@"
    exit $?
fi

source wsl_functions.sh

read -p 'Enter the website domain: ' SITE_DOMAIN
read -p 'Specify the new PHP version this site should run on (7.0, 7.1, 7.2, 7.3): ' SITE_PHP_VERSION

SITE_CONF_PATH=/etc/apache2/sites-available/"$SITE_DOMAIN".conf

# Validate website path
wsl_website_exists $SITE_CONF_PATH

# Validate PHP version
wsl_validate_php_version $SITE_PHP_VERSION

SITE_CONF_FILE=$(cat $SITE_CONF_PATH)

# Perform the replacement
echo "$SITE_CONF_FILE" | perl -pe "s/php[0-9.]+/php$SITE_PHP_VERSION/g" > $SITE_CONF_PATH

# Output success
wsl_success "PHP version successfully changed for $SITE_DOMAIN!"