#!/bin/bash

export NETWORK_NAME="moodle-net"

function run() {

  run_deps

  docker run -it \
    -e DEBUG_DOCKER_ENTRYPOINT='true' \
    -e MOODLE_HOST_URL='' \
    -e MOODLE_LANGUAGE='' \
    -e MOODLE_DATA_ROOT='' \
    -e MOODLE_DATA_ROOT_PERMISSION='' \
    -e MOODLE_ADMIN_USER='' \
    -e MOODLE_ADMIN_EMAIL='example@example.com' \
    -e MOODLE_ADMIN_PASSWORD='password' \
    -e MOODLE_DB_SKIP='' \
    -e MOODLE_DB_HOST='' \
    -e MOODLE_DB_PORT='' \
    -e MOODLE_DB_USERNAME='' \
    -e MOODLE_DB_PASSWORD='' \
    -e MOODLE_DB_NAME='' \
    -e MOODLE_DB_SOCKET='' \
    -e MOODLE_DB_PREFIX='' \
    -e MOODLE_SITE_FULLNAME='Moodle Website' \
    -e MOODLE_SITE_SHORTNAME='Site' \
    -e MOODLE_SITE_SUMMARY='' \
    -e MOODLE_UPGRADE_KEY='' \
    --network "${NETWORK_NAME}" \
    --name web \
    -p 8080:80 \
    --entrypoint /bin/bash moodle
    #moodle
    #moodle:official
}

function run_deps() {
  docker network create -d bridge "${NETWORK_NAME}"

  docker run  \
    --network "${NETWORK_NAME}" \
    --name db \
    -e "POSTGRES_USER=moodle" \
    -e "POSTGRES_PASSWORD=password" \
    -e "POSTGRES_DB=moodle" \
    -d \
    postgres:11
}

function stop_all () {
  echo -e "\nSTOPPING CONTAINERS"
  docker stop $(docker ps -q) 2>/dev/null || echo "No containers running"

  echo -e "\n\nDELETING CONTAINTERS"
  docker rm -f $(docker ps -aq) 2>/dev/null || echo "No containers to delete"

  echo -e "\nDELETING VOLUMES"
  docker volume prune -f

  echo -e "\nDELETING NETWORKS"
  docker network prune -f
}

function del_images () {
  echo -e "\nDELETING IMAGES"
  docker rmi $(docker images -aq)
}

function purge_all () {
  stop_all
  del_images
}
