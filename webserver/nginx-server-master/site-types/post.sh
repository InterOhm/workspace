#!/usr/bin/env bash

service=apache2

if (( $(ps -ef | grep -v grep | grep $service | wc -l) > 0 ))
then
sudo service $service stop
fi

sudo service nginx restart
sudo service php7.2-fpm restart
sudo service php7.3-fpm restart
sudo service php7.1-fpm restart
sudo service php7.0-fpm restart
sudo service php5.6-fpm restart

pause