#!/usr/bin/with-contenv /bin/bash

# If there are any local env var files (e.g. dumped from Symfony Secrets), load
# them into real env vars for the scope of this script file.
if [ -f /var/www/app/.env.$APP_ENV.local ]
then
    export $(xargs < /var/www/app/.env.$APP_ENV.local)
fi

# if in dev environment
# and a database host is given
# and an initialdb file exists (is readable), backup and reset database
if [ "$APP_ENV" == "dev" -a -n "$APP_DATABASE_HOST" -a -r /var/www/app/data/initialdb.sql ]
then
    echo "Waiting for database"
    while ! nc -z $APP_DATABASE_HOST 3306; do sleep 1; done

    echo "Loading test database"
    mysqldump -h $APP_DATABASE_HOST -u $APP_DATABASE_USER -p$APP_DATABASE_PASSWORD $APP_DATABASE_NAME > /var/www/app/data/db-previous.sql
    mysqladmin -h $APP_DATABASE_HOST -u $APP_DATABASE_USER -p$APP_DATABASE_PASSWORD -f drop $APP_DATABASE_NAME
    mysqladmin -h $APP_DATABASE_HOST -u $APP_DATABASE_USER -p$APP_DATABASE_PASSWORD create $APP_DATABASE_NAME
    mysql -h $APP_DATABASE_HOST -u $APP_DATABASE_USER -p$APP_DATABASE_PASSWORD $APP_DATABASE_NAME < /var/www/app/data/initialdb.sql
fi
