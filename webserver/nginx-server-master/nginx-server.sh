#!/usr/bin/env bash

read -p "Enter your domain name and press [ENTER]: " domainName

read -p "Enter your root path and press [ENTER]: " serverRoot

read -p "Enter HTTP port number [80]: " defaultPort

read -p "Enter HTTPS port number [443]: " sslPort

domain=$domainName
rootpath=$serverRoot
defaultPort=${defaultPort:-80}
sslPort=${sslPort:-443}

# Create the Document Root directory
if [ ! -d $rootpath ]; then
	mkdir -p $rootpath 2>/dev/null
	# Assign ownership to your regular user account
	chown -R $USER:$USER $rootpath 2>/dev/null
fi

# Creating the SSL directory
if [ ! -d "/etc/nginx/ssl" ]; then
	mkdir /etc/nginx/ssl 2>/dev/null
fi

PATH_SSL="/etc/nginx/ssl"
PATH_KEY="${PATH_SSL}/${domain}.key"
PATH_CSR="${PATH_SSL}/${domain}.csr"
PATH_CRT="${PATH_SSL}/${domain}.crt"

if [ ! -f $PATH_KEY ] || [ ! -f $PATH_CSR ] || [ ! -f $PATH_CRT ]
then
  openssl genrsa -out "$PATH_KEY" 2048 2>/dev/null
  openssl req -new -key "$PATH_KEY" -out "$PATH_CSR" -subj "/CN=$domain/O=Vagrant/C=UK" 2>/dev/null
  openssl x509 -req -days 365 -in "$PATH_CSR" -signkey "$PATH_KEY" -out "$PATH_CRT" 2>/dev/null
fi

# Create the Nginx server block file:
PS3='Please enter your choice: '
options=("PHP" "HHVM")
select opt in "${options[@]}"
do
    case $opt in
        "PHP")
			block="server {
    listen $defaultPort;
    listen $sslPort ssl;
    server_name $domain;
    root \"$rootpath\";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$domain-error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;

        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }

    ssl_certificate     /etc/nginx/ssl/$domain.crt;
    ssl_certificate_key /etc/nginx/ssl/$domain.key;
}
"
			break
            ;;
        "HHVM")
			block="server {
	listen $defaultPort;
    listen $sslPort ssl;
    server_name $domain;
    root \"$rootpath\";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$domain-error.log error;

    sendfile off;

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.ht {
        deny all;
    }

    ssl_certificate     /etc/nginx/ssl/$domain.crt;
    ssl_certificate_key /etc/nginx/ssl/$domain.key;
}
"
            break
            ;;
        *) echo invalid option;;
    esac
done

echo "$block" > "/etc/nginx/sites-available/$domain"
# Link to make it available
ln -fs "/etc/nginx/sites-available/$domain" "/etc/nginx/sites-enabled/$domain"
# Test configuration and reload if successful
nginx -t && service nginx restart
service php7.0-fpm restart
service hhvm restart