#!/bin/bash

CONFIG_DIR="/usr/local/WebRTCTestBrowser"
export config='$config'
echo "ServerName $SERVER_NAME"

echo "Generating config File from template and .env file"

echo "Apache"
cat $CONFIG_DIR/webrtctest.conf | envsubst > /etc/apache2/sites-available/webrtctest.conf

echo "Config Generation Done"

echo "Dealing with certificate files"
if [ ! -f  /etc/apache2/apache.pem ]
then
    echo "Generate self signed certificate for apache"
    openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 10000 -nodes -subj '/CN='$SERVER_NAME
    cat key.pem cert.pem > /etc/apache2/apache.pem
    rm key.pem cert.pem
fi

a2ensite webrtctest.conf && a2enmod ssl

cd $CONFIG_DIR/scripts
php make-release.php --release 1.0.0 --debug --turn-endpoint $TURN_CRED_ENDPOINT

#Start Apache
/usr/sbin/apache2ctl -DFOREGROUND
