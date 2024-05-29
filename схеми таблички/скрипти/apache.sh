#!/bin/bash

if ! dpkg -s apache2 > /dev/null 2>&1;
then
	echo " Apache2 wasn't installed. Installing! "
	sudo apt-get update
	sudo apt-get install -y apache2
fi

cd /etc/apache2/sites-available

echo "<VirtualHost *:80>
	ServerName $1
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/$1
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > $1.conf

mkdir /var/www/$1

echo "<!DOCTYPE HTML>
<HTML>
	<head></head>
	<body>
		<h1>Welcome to $1</h1>
	</body>
</HTML>" > /var/www/$1/index.html

sudo a2ensite $1.conf
sudo systemctl reload apache2
