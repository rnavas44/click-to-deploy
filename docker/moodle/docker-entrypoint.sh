#!/bin/bash

<< comment
${MOODLE_UPGRADE_KEY} * need to include
${MOODLE_DB_SOCKET} * need to include
${MOODLE_DB_PREFIX} * need to include
comment

set -e

# Enable bash debug if DEBUG_DOCKER_ENTERYPOINT is true
if [[ "${DEBUG_DOCKER_ENTRYPOINT}" = "true" ]]; then
    echo "!!! WARNING: DEBUG_DOCKER_ENTRYPOINT is enabled!"
    echo "!!! WARNING: Use only for debugging. Do not use in production!"
    set -x
    env
fi



MOODLE_HOST_URL=$(curl -s ifconfig.me):8080 # TODO Check this part

if [[ -z ${MOODLE_DATA_ROOT_PERMISSION} ]]; then
  MOODLE_DATA_ROOT_PERMISSION='2777'
fi


# Sets moodle default and installation language to english if not present
if [[ -z ${MOODLE_LANGUAGE} ]]; then
  MOODLE_LANGUAGE='en'
fi

# Sets moodle data folder to its default value if not present
if [[ -z ${MOODLE_DATA_ROOT} ]]; then
  MOODLE_DATA_ROOT='/var/www/moodledata'
fi



# Sets moodle admin user to its default value it not present
if [[ -z ${MOODLE_ADMIN_USER} ]]; then
  MOODLE_ADMIN_USER='admin'
fi

# Returns an error if the moodle admin email is not set
if [[ -z ${MOODLE_ADMIN_EMAIL} ]]; then
  echo >&2 "error: missing required MOODLE_ADMIN_EMAIL environment variable"
  echo >&2 "  Did you forget to -e MOODLE_ADMIN_EMAIL=... ?"
  echo >&2
  echo >&2 "  (Also of interest might be MOODLE_ADMIN_PASSWORD.)"
  exit 1
fi

# Returns an error if the moodle admin password is not set
if [[ -z ${MOODLE_ADMIN_PASSWORD} ]]; then
  echo >&2 "error: missing required MOODLE_ADMIN_PASSWORD environment variable"
  echo >&2 "  Did you forget to -e MOODLE_ADMIN_PASSWORD=... ?"
  exit 1
fi



# Site settings
if [[ -z ${MOODLE_SITE_FULLNAME} ]]; then
  echo >&2 "error: missing required MOODLE_SITE_FULLNAME environment variable"
  echo >&2 "  Did you forget to -e MOODLE_SITE_FULLNAME=... ?"
  echo >&2
  echo >&2 "  (Also of interest might be MOODLE_SITE_SHORTNAME and MOODLE_SITE_SUMMARY.)"
  exit 1
fi

if [[ -z ${MOODLE_SITE_SHORTNAME} ]]; then
  echo >&2 "error: missing required MOODLE_SITE_SHORTNAME environment variable"
  echo >&2 "  Did you forget to -e MOODLE_SITE_SHORTNAME=... ?"
  echo >&2
  echo >&2 "  (Also of interest might be MOODLE_SITE_SUMMARY.)"
  exit 1
fi

# TODO check how to continue flow when MOODLE_SITE_SUMMARY unset
if [[ -z ${MOODLE_SITE_SUMMARY} ]]; then
  echo >&2 "error: missing optional MOODLE_SITE_SUMMARY environment variable"
  echo >&2 "  Did you forget to -e MOODLE_SITE_SUMMARY=... ?"
fi




# POSTGRESQL DATABASE SECTION.    NOTE: there's an option to skip db installation --skip-database

# Installs DB if MOODLE_DB_SKIP=false otherwise it stops the installation before installing the DB
if [[ "${MOODLE_DB_SKIP}" = "true" ]]; then
  # TODO execute install without DB
  /usr/local/bin/php /var/www/html/admin/cli/install.php \
    --agree-license \
    --non-interactive \ 
    --allow-unstable \
    --wwwroot=${MOODLE_HOST_URL} \
    --lang=${MOODLE_LANGUAGE} \
    --dataroot=${MOODLE_DATA_ROOT} \
    --chmod=${MOODLE_DATA_ROOT_PERMISSION} \
    --adminuser=${MOODLE_ADMIN_USER} \
    --adminemail=${MOODLE_ADMIN_EMAIL} \
    --adminpass=${MOODLE_ADMIN_PASSWORD} \
    --fullname=\"${MOODLE_SITE_FULLNAME}\" \
    --shortname=${MOODLE_SITE_SHORTNAME} \
    --summary=\"${MOODLE_SITE_SUMMARY}\" \
    --skip-database
    
  # Checks for DB necessary data
  else
    echo "Entering..."
    if [[ -n ${POSTGRES_USER} ]]; then
      : ${MOODLE_DB_USERNAME:=${POSTGRES_USER}}
    else
      MOODLE_DB_USERNAME='moodle'
    fi
      
    if [[ -n ${POSTGRES_PASSWORD} ]]; then
      : ${MOODLE_DB_PASSWORD:=${POSTGRES_PASSWORD}}
    else
      MOODLE_DB_PASSWORD='password' # Random generated password      
    fi

    if [[ -n ${POSTGRES_DB} ]]; then
      : ${MOODLE_DB_NAME:=${POSTGRES_DB}}
    else
      MOODLE_DB_NAME='moodle'
    fi
  
    if [[ -z ${MOODLE_DB_PREFIX} ]]; then
      MOODLE_DB_PREFIX='mdl_'
    fi
      
    MOODLE_DB_HOST='db'
    MOODLE_DB_PORT=5432
    
    
    /usr/local/bin/php /var/www/html/admin/cli/install.php \
    --agree-license \
    --non-interactive \
    --allow-unstable \
    --wwwroot=${MOODLE_HOST_URL} \
    --lang=${MOODLE_LANGUAGE} \
    --dataroot=${MOODLE_DATA_ROOT} \
    --chmod=${MOODLE_DATA_ROOT_PERMISSION} \
    --adminuser=${MOODLE_ADMIN_USER} \
    --adminemail=${MOODLE_ADMIN_EMAIL} \
    --adminpass=${MOODLE_ADMIN_PASSWORD} \
    --fullname=\"${MOODLE_SITE_FULLNAME}\" \
    --shortname=${MOODLE_SITE_SHORTNAME} \
    --summary="\""${MOODLE_SITE_SUMMARY}"\"" \
    --dbtype=pgsql \
    --dbhost=${MOODLE_DB_HOST} \
    --dbname=${MOODLE_DB_NAME} \
    --dbuser=${MOODLE_DB_USERNAME} \
    --dbpass=${MOODLE_DB_PASSWORD} \
    --dbport=${MOODLE_DB_PORT} \
    #--dbsocket=${MOODLE_DB_SOCKET}
    #--prefix=${MOODLE_DB_PREFIX}
fi

chown -R www-data:www-data /var/www/moodledata

exec "$@"
