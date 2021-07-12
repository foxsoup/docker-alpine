#!/usr/bin/with-contenv /bin/bash

echo "Clearing & warming cache"
sudo -u nginx -E /var/www/app/bin/console cache:clear
sudo -u nginx -E /var/www/app/bin/console cache:warm
