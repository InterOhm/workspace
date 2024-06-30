#!/usr/bin/env bash

source $DIR/site-types/base.sh

block="server {
    listen $defaultPort;
    listen $sslPort ssl http2;
    server_name .$domain;
    root \"$rootpath\";

    index index.php index.html index.htm;

    charset utf-8;

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { allow all; access_log off; log_not_found off; }

    location ~ /.*\.(jpg|jpeg|png|js|css)$ {
        try_files \$uri =404;
    }

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    if (!-e \$request_filename) {
        # Add trailing slash to */wp-admin requests.
        rewrite /wp-admin$ \$scheme://\$host\$uri/ permanent;

        # WordPress in a subdirectory rewrite rules
        rewrite ^/([_0-9a-zA-Z-]+/)?(wp-.*|xmlrpc.php) /wp/\$2 break;
    }

    location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
        include fastcgi_params;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_pass unix:/var/run/php/php$phpVer-fpm.sock;
        fastcgi_intercept_errors on;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
    }

    access_log off;
    error_log  /var/log/nginx/$domain-error.log error;

    sendfile off;

    client_max_body_size 100m;

    location ~ /\.ht {
        deny all;
    }

    ssl_certificate     /etc/nginx/ssl/$domain.crt;
    ssl_certificate_key /etc/nginx/ssl/$domain.key;
}
"

echo "$block" > "/etc/nginx/sites-available/$domain"
ln -fs "/etc/nginx/sites-available/$domain" "/etc/nginx/sites-enabled/$domain"


# Additional constants to define in wp-config.php
wpConfigSearchStr="\$table_prefix = 'wp_';"
wpConfigReplaceStr="\$table_prefix = 'wp_';\\n\
\\n\
// Define the default HOME/SITEURL constants and set them to our root domain\\n\
if ( ! defined( 'WP_HOME' ) ) {\\n\
	define( 'WP_HOME', 'http://$domain' );\\n\
}\\n\
if ( ! defined( 'WP_SITEURL' ) ) {\\n\
	define( 'WP_SITEURL', WP_HOME );\\n\
}\\n\
\\n\
if ( ! defined( 'WP_CONTENT_DIR' ) ) {\\n\
	define( 'WP_CONTENT_DIR', __DIR__ . '/wp-content' );\\n\
}\\n\
if ( ! defined( 'WP_CONTENT_URL' ) ) {\\n\
	define( 'WP_CONTENT_URL', WP_HOME . '/wp-content' );\\n\
}\\n\
"


# If wp-cli is installed, try and update it
if [ -f /usr/local/bin/wp ]
then
    wp cli update --stable --yes
fi

read -p "Enter DB Username [homestead]: " mysql_user
read -p "Enter DB Password [secret]: " mysql_pass

db_user=${mysql_user:-homestead}
db_pass=${mysql_pass:-secret}

# If WP is not installed then download it
if [ -d "$rootpath/wp" ]
then
    echo "WordPress is already installed."
else
    sudo -i -u $SUDO_USER -- mkdir "$rootpath/wp"
    sudo -i -u $SUDO_USER -- wp core download --path="$rootpath/wp" --version=latest
    sudo -i -u $SUDO_USER -- cp -R $rootpath/wp/wp-content $rootpath/wp-content
    sudo -i -u $SUDO_USER -- cp $rootpath/wp/index.php $rootpath/index.php
    sudo -i -u $SUDO_USER -- sed -i "s|/wp-blog-header|/wp/wp-blog-header|g" $rootpath/index.php
    sudo -i -u $SUDO_USER -- echo "path: $rootpath/wp/" > $rootpath/wp-cli.yml
    sudo -i -u $SUDO_USER -- wp config create --path=$rootpath/wp/ --dbname=${domain/./_} --dbuser=$db_user --dbpass=$db_pass --dbcollate=utf8_general_ci
    sudo -i -u $SUDO_USER -- mv $rootpath/wp/wp-config.php $rootpath/wp-config.php
    sudo -i -u $SUDO_USER -- sed -i 's|'"$wpConfigSearchStr"'|'"$wpConfigReplaceStr"'|g' $rootpath/wp-config.php
    sudo -i -u $SUDO_USER -- sed -i "s|define( 'ABSPATH', dirname( __FILE__ ) . '/' );|define( 'ABSPATH', __DIR__ . '/wp/' );|g" $rootpath/wp-config.php

    echo "WordPress has been downloaded and config file has been generated, install it manually."
fi

source $DIR/site-types/post.sh

return