#!/bin/bash

if ! dpkg -s bind9 > /dev/null 2>&1;
then
	echo "bind9 is not installed, installing"
	sudo apt-get update
	sudo apt-get install -y bind9
fi

ip=$(ifconfig enp0s8 | grep 'inet ' | awk '{print $2}')

name=$(echo $1 | cut -d"." -f2-)

rev_ip=$(echo $2 | awk -F\. '{ printf "%s.%s.%s.%s",$4,$3,$2,$1 }')

sed -i "s/listen-on-v6.*/listen-on { "$2"; };/g" /etc/bind/named.conf.options


if ! grep -q "zone \"$name\"" /etc/bind/named.conf.local;
then
echo "zone \"$name\" {
	type master;
	file \"/etc/bind/db.$name\";
};
" >> /etc/bind/named.conf.local
fi


if ! grep -q "zone \"$rev_ip.in-addr.arpa\"" /etc/bind/named.conf.local;
then
echo "zone \"$rev_ip.in-addr.arpa\" {
	type master;
	file \"/etc/bind/db.reverse.$name\";
};
" >> /etc/bind/named.conf.local
fi



if ! test -f /etc/bind/db.$name;
then
echo "\$TTL	604800
@	IN	SOA	ns.$name	admin.$name (
			1		; Serial
			604800		; Refresh
			86400		; Retry
			2419200		; Expire
			604800	)	; Negative Cache TTL
;
@		IN 	NS	ns.$name.
ns.$name.	IN	A	$2
$1.		IN	A	$2" > /etc/bind/db.$name
else
echo "$1.	IN	A	$2" >> /etc/bind/db.$name
fi



if ! test -f /etc/bind/db.reverse.$name;
then
echo "\$TTL	604800
@	IN	SOA	ns.$name	admin.$name (
			      1		; Serial
			 604800		; Refresh
			  86400		; Retry
			2419200		; Expire
			 604800 )	; Negative Cache TTL
;
@		IN	NS	ns.$name.
$rev_ip		IN	PTR	$1." > /etc/bind/db.reverse.$name
else
echo "$rev_ip	IN	PTR	$1." >> /etc/bind/db.reverse.$name
fi

sudo systemctl restart bind9
