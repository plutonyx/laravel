#!/bin/bash

/usr/sbin/cron
service nginx start
tail -f /var/log/nginx/access.log &
tail -f /var/log/nginx/error.log &
service php7.1-fpm start

cd /data
composer self-update
php artisan cache:clear
chmod -R 777 storage
composer dump-autoload

while true; do sleep 1d; done
# nginx -g daemon off;
