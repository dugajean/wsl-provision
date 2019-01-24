#!/bin/bash

if [ $(id -u) != "0" ]; then
    sudo "$0" "$@"
    exit $?
fi

source wsl_functions.sh

read -p 'Enter the website domain: ' SITE_DOMAIN
read -p 'Choose whether the new website should be secure [y/N]: ' SITE_SECURE
read -p "Enter the website's relative path (including /public if applicable): " SITE_PATH
read -p 'Specify the PHP version this site should run on [7.0/7.1/7.2/7.3]: ' SITE_PHP_VERSION

# Validate website path
wsl_website_path_exists $SITE_PATH

# Validate PHP version
wsl_validate_php_version $SITE_PHP_VERSION

# Create the vhost
cat > /etc/apache2/sites-available/"$SITE_DOMAIN".conf <<EOL
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName ${SITE_DOMAIN}
    ServerAlias www.${SITE_DOMAIN}
    DocumentRoot /c/Users/Dugi/Code/${SITE_PATH}

    <Directory /c/Users/Dugi/Code/${SITE_PATH}>
        AllowOverride All
        Require all granted
    </Directory>

    <IfModule mod_fastcgi.c>
        AddHandler php${SITE_PHP_VERSION}-fcgi-www .php
        Action php${SITE_PHP_VERSION}-fcgi-www /php${SITE_PHP_VERSION}-fcgi-www
        Alias /php${SITE_PHP_VERSION}-fcgi-www /usr/lib/cgi-bin/php${SITE_PHP_VERSION}-fcgi-www
        FastCgiExternalServer /usr/lib/cgi-bin/php${SITE_PHP_VERSION}-fcgi-www -socket /run/php/php${SITE_PHP_VERSION}-fpm.sock -idle-timeout 1800 -pass-header Authorization
        <Directory "/usr/lib/cgi-bin">
            Require all granted
        </Directory>
    </IfModule>

    <IfModule mod_fastcgi.c>
        <FilesMatch ".+\.ph(p[345]?|t|tml)$">
            SetHandler php${SITE_PHP_VERSION}-fcgi-www
        </FilesMatch>
    </IfModule>

    ErrorLog \${APACHE_LOG_DIR}/${SITE_DOMAIN}-error.log
    CustomLog \${APACHE_LOG_DIR}/${SITE_DOMAIN}-access.log combined
</VirtualHost>
EOL

if [[ $SITE_SECURE =~ ^[Yy]$ ]]; then
    secure_site $SITE_DOMAIN
fi

# Enable the new site
ln -s /etc/apache2/sites-available/"$SITE_DOMAIN".conf /etc/apache2/sites-enabled/"$SITE_DOMAIN".conf > /dev/null 2>&1

# Restart Apache
service apache2 restart > /dev/null 2>&1

# Add hosts entry to Windows...
(echo "127.0.0.1  ${SITE_DOMAIN}"; echo "") >> /c/Windows/System32/drivers/etc/hosts

wsl_success "Website has successfully been added and enabled!"