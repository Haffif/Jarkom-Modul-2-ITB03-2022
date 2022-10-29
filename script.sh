#!/bin/env bash

#Variabel
HOSTNAME=`hostname`
PREFIX="10.46"
DNS="192.168.122.1"
OSTANIA_e1_IP="$PREFIX.1.1"
OSTANIA_e2_IP="$PREFIX.2.1"
OSTANIA_e3_IP="$PREFIX.3.1"
SSS_IP="$PREFIX.1.2"
GARDEN_IP="$PREFIX.1.3"
WISE_IP="$PREFIX.2.2"
BERLINT_IP="$PREFIX.3.2"
EDEN_IP="$PREFIX.3.3"

#WISE
if [[ $HOSTNAME = "WISE" ]]; then
       echo nameserver $DNS > /etc/resolv.conf

       apt update
       apt install bind9 -y
       apt install dnsutils -y

## Konfigurasi zone untuk domain baru wise.itb03.com
        echo '
zone "wise.itb03.com"{
        type master;
        notify yes;
        also-notify { 10.46.3.2; };
        allow-transfer { 10.46.3.2; };
        file "/etc/bind/wise/wise.itb03.com";
};

zone "2.46.10.in-addr.arpa" {
        type master;
        file "/etc/bind/wise/2.46.10.in-addr.arpa";
};
' > /etc/bind/named.conf.local

## buat direktori wise
        mkdir -p /etc/bind/wise

## konfigurasi db lokal untuk wise.itb03.com
## untuk web server $WISE_IP diganti IP Eden (10.46.3.3)
        echo "\
\$TTL    604800
@       IN      SOA     wise.itb03.com. root.wise.itb03.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@             IN      NS      wise.itb03.com.
@             IN      A       $WISE_IP ; IP WISE
@             IN      AAAA    ::1
www           IN      CNAME   wise.itb03.com.
eden          IN      A       $EDEN_IP ; IP Eden
www.eden      IN      CNAME   eden.wise.itb03.com.
ns1           IN      A       10.46.3.2 ; IP Berlint
operation     IN      NS      ns1
www.operation IN      CNAME   wise.itb03.com
" > /etc/bind/wise/wise.itb03.com

## konfigurasi db lokal untuk reverse dns
        echo "\
\$TTL    604800
@       IN      SOA     wise.itb03.com. root.wise.itb03.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
2.46.10.in-addr.arpa.   IN      NS      wise.itb03.com.
2                       IN      PTR     wise.itb03.com.
" > /etc/bind/wise/2.46.10.in-addr.arpa

	echo "
options {
        directory \"/var/cache/bind\";
        allow-query{any;};
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
" >/etc/bind/named.conf.options

        service bind9 restart

# Berlint
elif [[ $HOSTNAME = "Berlint" ]]; then
        echo nameserver $WISE_IP > /etc/resolv.conf
        echo nameserver $DNS >> /etc/resolv.conf

        apt update
        apt install bind9 -y
        apt install dnsutils -y

        echo '
zone "wise.itb03.com" {
    type slave;
    masters { 10.46.2.2; }; // Masukan IP WISE tanpa tanda petik
    file "/var/lib/bind/wise.itb03.com";
};

zone "operation.wise.itb03.com" {
        type master;
        file "/etc/bind/operation/operation.wise.itb03.com";
};
' > /etc/bind/named.conf.local

	echo "
options {
        directory \"/var/cache/bind\";
        allow-query{any;};
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};
" > /etc/bind/named.conf.options

        mkdir -p /etc/bind/operation

	echo "\
\$TTL    604800
@       IN      SOA     operation.wise.itb03.com. root.operation.wise.itb03.com. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@          IN      NS      operation.wise.itb03.com.
@          IN      A       10.46.3.3 ; IP Eden
www        IN      CNAME   operation.wise.itb03.com.
strix      IN      A       10.46.3.3 ; IP Eden
www.strix  IN      CNAME   strix.operation.wise.itb03.com.
" > /etc/bind/operation/operation.wise.itb03.com

        service bind9 restart

# Eden
elif [[ $HOSTNAME = "Eden" ]]; then
        echo nameserver $DNS > /etc/resolv.conf

        apt update
        apt install unzip \
        apache2-utils \
        apache2 \
        php \
        libapache2-mod-php7.0 -y

        ## start apachae2
        service apache2 start

        ## wget
        apt-get install wget -y

        ## download zip
        wget -c "https://drive.google.com/uc?export=download&id=1S0XhL9ViYN7TyCj2W66BNEXQD2AAAw2e" -O wise.zip

        wget -c "https://drive.google.com/uc?export=download&id=1q9g6nM85bW5T9f5yoyXtDqonUKKCHOTV" -O eden.wise.zip

        wget -c "https://drive.google.com/uc?export=download&id=1bgd3B6VtDtVv2ouqyM8wLyZGzK5C9maT" -O strix.operation.wise.zip

        ## buat direktori wise di /var/www
        mkdir -p /var/www/wise.itb03.com
        mkdir -p /var/www/eden.wise.itb03.com
        mkdir -p /var/www/strix.operation.wise.itb03.com

        ## unzip dan masukin ke /var/www/wise.itb03.com
        unzip wise.zip 
        unzip eden.wise.zip
        unzip strix.operation.wise.zip

        mv wise/* /var/www/wise.itb03.com/
        mv eden.wise/* /var/www/eden.wise.itb03.com/
        mv strix.operation.wise/* /var/www/strix.operation.wise.itb03.com/

        rm wise.zip
        rm eden.wise.zip
        rm strix.operation.wise.zip

        rm -r wise
        rm -r eden.wise
        rm -r strix.operation.wise

        rm -r /var/www/wise.itb03.com/wise
        rm -r /var/www/eden.wise.itb03.com/eden.wise
        rm -r /var/www/strix.operation.wise.itb03.com/strix.operation.wise

        ## Nomer 14
#       echo "
# <?php
#     echo 'selamat 14';
# ?>
# " > /var/www/strix.operation.wise.itb03.com/index.php

        ## inisialisasi documentroot pada /var/www/wise.itb03.com
        echo "\
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/wise.itb03.com
        ServerName wise.itb03.com
        ServerAlias www.wise.itb03.com

        Alias "/home" "/var/www/wise.itb03.com/index.php/home"

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

        <Directory /var/www/wise.itb03.com>
                Options +FollowSymLinks -Multiviews
                AllowOverride All
        </Directory>
</VirtualHost>
" > /etc/apache2/sites-available/wise.itb03.com.conf

        echo "\
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/eden.wise.itb03.com
        ServerName eden.wise.itb03.com
        ServerAlias www.eden.wise.itb03.com

        ErrorDocument 404 /error/404.html
        ErrorDocument 500 /error/404.html
        ErrorDocument 502 /error/404.html
        ErrorDocument 503 /error/404.html
        ErrorDocument 504 /error/404.html

        <Directory /var/www/eden.wise.itb03.com/public>
                Options +Indexes
        </Directory>

        Alias "/js" "/var/www/eden.wise.itb03.com/public/js"

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

        <Directory /var/www/eden.wise.itb03.com>
                Options +FollowSymLinks -Multiviews
                AllowOverride All
        </Directory>
</VirtualHost>
" > /etc/apache2/sites-available/eden.wise.itb03.com.conf

        htpasswd -c -b /etc/apache2/.htpasswd Twilight opStrix

        echo "\
<VirtualHost *:15000 *:15500>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/strix.operation.wise.itb03.com
        ServerName strix.operation.wise.itb03.com
        ServerAlias www.strix.operation.wise.itb03.com

        <Directory \"/var/www/strix.operation.wise.itb03.com\">
                AuthType Basic
                AuthName \"Restricted Content\"
                AuthUserFile /etc/apache2/.htpasswd
                Require valid-user
        </Directory>

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/strix.operation.wise.itb03.com.conf

        echo "
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        RewriteEngine On
        RewriteCond %{HTTP_HOST} !^wise.itb03.com$
        RewriteRule /.* http://wise.itb03.com/ [R]
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/000-default.conf

        echo "
RewriteEngine On
RewriteCond %{REQUEST_URI} ^/public/images/(.*)eden(.*)
RewriteCond %{REQUEST_URI} !/public/images/eden.png
RewriteRule /.* http://eden.wise.itb03.com/public/images/eden.png [L]
" > /var/www/eden.wise.itb03.com/.htaccess

        echo "
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/eden.wise.itb03.com
        ServerName eden.wise.itb03.com
        ServerAlias www.eden.wise.itb03.com
        ErrorDocument 404 /error/404.html
        ErrorDocument 500 /error/404.html
        ErrorDocument 502 /error/404.html
        ErrorDocument 503 /error/404.html
        ErrorDocument 504 /error/404.html
        <Directory /var/www/eden.wise.itb03.com/public>
                Options +Indexes
        </Directory>
        Alias \"/js\" \"/var/www/eden.wise.itb03.com/public/js\"
        <Directory /var/www/eden.wise.itb03.com>
                Options +FollowSymLinks -Multiviews
                AllowOverride All
        </Directory>
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
        <Directory /var/www/eden.wise.itb03.com>
                Options +FollowSymLinks -Multiviews
                AllowOverride All
        </Directory>
</VirtualHost>
" > /etc/apache2/sites-available/eden.wise.itb03.com.conf

        ## a2enmod rewrite
        a2enmod rewrite

        ## /var/www/wise.itb03.com/.htaccess
        echo "\
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule (.*) /index.php/\$1 [L]
" > /var/www/wise.itb03.com/.htaccess

        echo '
Listen 80
Listen 15000
Listen 15500
<IfModule ssl_module>
        Listen 443
</IfModule>

<IfModule mod_gnutls.c>
        Listen 443
</IfModule>
' > /etc/apache2/ports.conf

        ## aktifkan konfigurasi dari wise.itb03.com
        a2ensite wise.itb03.com
        a2ensite eden.wise.itb03.com
        a2ensite strix.operation.wise.itb03.com 

        ## restart apache
        service apache2 restart

# SSS
elif [[ $HOSTNAME = "SSS" ]]; then
        echo nameserver $EDEN_IP > /etc/resolv.conf        
        echo nameserver $WISE_IP >> /etc/resolv.conf
        echo nameserver $BERLINT_IP >> /etc/resolv.conf
        echo nameserver $DNS >> /etc/resolv.conf

        apt update
        apt install dnsutils -y
        apt install lynx -y

# Garden
elif [[ $HOSTNAME = "Garden" ]]; then
        echo nameserver $EDEN_IP > /etc/resolv.conf        
        echo nameserver $WISE_IP >> /etc/resolv.conf
        echo nameserver $BERLINT_IP >> /etc/resolv.conf
        echo nameserver $DNS >> /etc/resolv.conf

        apt update
        apt install dnsutils -y
        apt install lynx -y

fi