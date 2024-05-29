#!bin/bash

sudo apt-get purge -y bind9
sudo apt-get purge -y apache2

sudo rm -r /etc/bind
sudo rm -r /etc/apache2
sudo rm -r /var/www

