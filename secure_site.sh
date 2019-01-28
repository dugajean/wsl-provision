#!/bin/bash

if [ $(id -u) != "0" ]; then
    sudo "$0" "$@"
    exit $?
fi

source wsl_functions.sh

# Define vars
SITE_DOMAIN=$1

# Prepare inputs
if [ -z "$1" ]; then
    read -p 'Enter the website domain: ' SITE_DOMAIN
fi

SITE_CONF_PATH=/etc/apache2/sites-available/"$SITE_DOMAIN".conf

# Validate website path
wsl_website_exists $SITE_CONF_PATH

# See if already have a certificate
if [ -f /etc/ssl/private/"$SITE_DOMAIN"-selfsigned.key ]; then
    wsl_error "SSL certificate for ${SITE_DOMAIN} already exists."
fi

# Start SSL cert generation
echo "Generating SSL certificate..."

openssl req -x509 -nodes -days 5000 -newkey rsa:2048 -keyout /etc/ssl/private/"$SITE_DOMAIN"-selfsigned.key -out /etc/ssl/certs/"$SITE_DOMAIN"-selfsigned.crt \
    -subj "/C=EU/ST=Kosovo/L=Prishtina/O=Dukagjin Surdulli, Inc./OU=Agency/CN=${SITE_DOMAIN}/emailAddress=webmaster@${SITE_DOMAIN}" > /dev/null 2>&1

if [ ! -f /etc/apache2/conf-available/ssl-params.conf ]; then
    cat > /etc/apache2/conf-available/ssl-params.conf <<EOL
SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH
SSLProtocol All -SSLv2 -SSLv3 -TLSv1 -TLSv1.1
SSLHonorCipherOrder On
Header always set X-Frame-Options DENY
Header always set X-Content-Type-Options nosniff
SSLCompression off
SSLUseStapling on
SSLStaplingCache "shmcb:logs/stapling-cache(150000)"
SSLSessionTickets Off
EOL
fi

SITE_CONF_FILE=$(cat $SITE_CONF_PATH)
SITE_CONF_SSLD=$(echo "$SITE_CONF_FILE" | perl -0pe "s|</Directory>|</Directory>

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/${SITE_DOMAIN}-selfsigned.crt
    SSLCertificateKeyFile /etc/ssl/private/${SITE_DOMAIN}-selfsigned.key

    <FilesMatch \"\\.(cgi\|shtml\|phtml\|php)\$\">
        SSLOptions +StdEnvVars
    </FilesMatch>
    <Directory /usr/lib/cgi-bin>
        SSLOptions +StdEnvVars
    </Directory>|")
SITE_CONF_SSLD=$(echo "$SITE_CONF_SSLD" | perl -pe "s|\*\:80|\*\:443|")

(echo ""; echo "$SITE_CONF_SSLD") >> $SITE_CONF_PATH

# Output success
wsl_success "Website has been secured with SSL certificate."