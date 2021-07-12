#!/usr/bin/with-contenv /bin/bash

if [ $APP_ENV != "prod" ] && [ $APP_ENV != "uat" ]
then
    echo "Non-production environment, disabling optimisations"
    rm /usr/local/etc/php/conf.d/production.ini
    exit
fi

echo "Production environment, configuring preload optimisations"
# Symfony 4.4 preload config
if [ -s /var/www/app/var/cache/prod/srcApp_KernelProdContainer.preload.php ]
then
    echo opcache.preload=/var/www/app/var/cache/prod/srcApp_KernelProdContainer.preload.php >> /usr/local/etc/php/conf.d/production.ini
    echo opcache.preload_user=nginx >> /usr/local/etc/php/conf.d/production.ini
fi

# Symfony 5.x preload config
if [ -s /var/www/app/config/preload.php ]
then
    echo opcache.preload=/var/www/app/config/preload.php >> /usr/local/etc/php/conf.d/production.ini
    echo opcache.preload_user=nginx >> /usr/local/etc/php/conf.d/production.ini
fi
