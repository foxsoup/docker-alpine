#!/usr/bin/with-contenv /bin/bash

# If there are any local env var files (e.g. dumped from Symfony Secrets), load
# them into real env vars for the scope of this script file.
if [ -f /var/www/app/.env.$APP_ENV.local ]
then
    export $(xargs < /var/www/app/.env.$APP_ENV.local)
fi

# Run migrations is database is configured
if [ -n "$APP_DATABASE_HOST" ]
then
    echo "Migrating database"
    sudo -u nginx -E /var/www/app/bin/console doctrine:migrations:migrate -n
fi
