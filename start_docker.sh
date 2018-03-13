#!/bin/bash

set -x

IMAGE_NAME='hogwarts'
BUILD_IMAGE=true
MIGRATE_DATABASE=false
SEED_DATABASE=false

APACHE_SERVERNAME=hogwarts.lan

APP_ENV=local # TODO Change
APP_DEBUG=true # TODO Change
APP_KEY=
DB_DATABASE=


while [[ ! -z $1 ]]; do
    case $1 in
	'--build')
	    BUILD_IMAGE=true
	    ;;
	*)
	    DB_DATABASE="$1"
	    ;;
    esac
    shift
done

if [[ -z $DB_DATABASE ]]; then
    DB_DATABASE=hogwarts.db
    DB_DATABASE=$(realpath $DB_DATABASE)
    if [ ! -f $DB_DATABASE ]; then
	echo "$DB_DATABASE doest not exist, create and seed it!"
	exit 1
    fi
    echo "Default db file to $DB_DATABASE"
fi

if [[ -z $(docker images -q $IMAGE_NAME 2> /dev/null) || $BUILD_IMAGE ]]; then
    docker build -t "$IMAGE_NAME" . || exit 1
fi


docker run -i -d -p 44080:80 \
       -v /etc/localtime:/etc/localtime:ro \
       -v "$DB_DATABASE:/var/lib/db/hogwarts.db" \
       -e APACHE_SERVERNAME="$APACHE_SERVERNAME" \
       -e APP_ENV="$APP_ENV" \
       -e APP_DEBUG="$APP_DEBUG" \
       -e APP_KEY="$APP_KEY" \
       -e DB_DATABASE=/var/lib/db/hogwarts.db \
       -e SEED_DATABASE="$SEED_DATABASE" \
       -e ADMIN_PASSWORD=secret \
       "$IMAGE_NAME"
