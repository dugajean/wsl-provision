#!/bin/bash

if [ $(id -u) != "0" ]
then
    sudo "$0" "$@"
    exit $?
fi

read -p 'Enter the website domain: ' SITE_DOMAIN
read -p "Enter the website's relative path (including /public if applicable): " SITE_PATH
read -p 'Specify the PHP version this site should run on (7.0, 7.1, 7.2, 7.3): ' SITE_PHP_VERSION

# Validate website path
if [ ! -d /c/Users/Dugi/Code/${SITE_PATH} ]
then 
    echo ""
    echo "[!] Requested website path does not exist." >&2
    exit 1
fi

# Validate PHP version
PHP_VERSIONS=(7.0 7.1 7.2 7.3)
if ! printf '%s\n' ${PHP_VERSIONS[@]} | grep -q -P "^"$SITE_PHP_VERSION"$"; then
    echo ""
    echo "[!] Invalid PHP version specified. Please choose from these options: 7.0, 7.1, 7.2, 7.3" >&2
    exit 1
fi

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

# Enable the new site
ln -s /etc/apache2/sites-available/"$SITE_DOMAIN".conf /etc/apache2/sites-enabled/"$SITE_DOMAIN".conf

# Restart Apache
service apache2 restart > /dev/null

# Add hosts entry to Windows...
echo "
127.0.0.1  ${SITE_DOMAIN}" >> /mnt/c/Windows/System32/drivers/etc/hosts

CHECK=$'\u2713'
echo ""
echo "[${CHECK}] Website has successfully been added and enabled!"