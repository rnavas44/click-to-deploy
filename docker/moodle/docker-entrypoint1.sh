#!/bin/bash

set -e

# Enable bash debug if DEBUG_DOCKER_ENTERYPOINT exists
if [[ "${DEBUG_DOCKER_ENTRYPOINT}" = "true" ]]; then
    echo "!!! WARNING: DEBUG_DOCKER_ENTRYPOINT is enabled!"
    echo "!!! WARNING: Use only for debugging. Do not use in production!"
    set -x
    env
fi



/usr/local/bin/php /var/www/html/admin/cli/install.php \
--non-interactive \
--agree-license \
--lang=en \
--wwwroot=http://$(curl ifconfig.me):8080 \
--dataroot=/var/www/moodledata \
--dbtype=pgsql \
--dbhost=db \
--dbname=moodle \
--dbuser=moodle \
--dbpass=password \
--dbport=5432 \
--prefix=mdl_ \
--fullname=”Moodle\ Website” \
--shortname=Site \
--adminuser=admin \
--adminpass=password \
--adminemail=example@example.com \
--upgradekey=””

chown -R www-data:www-data /var/www/moodledata

exec "$@"
