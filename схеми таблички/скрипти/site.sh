#!/bin/bash

user=$(whoami)

if [ "$user"=!"root" ];
then
	sudo bash /home/$user/dns.sh $1 $2
	sudo bash /home/$user/apache.sh $1
else
	echo "You are root now. For using script you can exit as a root, using comand 'exit' and call script again."
fi
