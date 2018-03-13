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
DB_DIR=
DB_FILE=hogwarts.db


while [[ ! -z $1 ]]; do
    case $1 in
	'--build')
	    BUILD_IMAGE=true
	    ;;
	*)
	    DB_DIR="$1"
	    ;;
    esac
    shift
done

if [[ -z $DB_DIR ]]; then
    DB_DIR=db
    DB_DIR=$(realpath $DB_DIR)
    if [ ! -d $DB_DIR ]; then
	echo "$DB_DIR doest not exist, create it!"
	exit 1
    fi
    if [ ! -f $DB_DIR/$DB_FILE ]; then
	echo "$DB_FILE doest not exist, create and seed it!"
	exit 1
    fi
    echo "Default db dir to $DB_DIR"
fi

if [[ -z $(docker images -q $IMAGE_NAME 2> /dev/null) || $BUILD_IMAGE ]]; then
    docker build -t "$IMAGE_NAME" . || exit 1
fi


docker run -i -d -p 44080:80 \
       -v /etc/localtime:/etc/localtime:ro \
       -v "$DB_DIR:/var/lib/db" \
       -e APACHE_SERVERNAME="$APACHE_SERVERNAME" \
       -e APP_ENV="$APP_ENV" \
       -e APP_DEBUG="$APP_DEBUG" \
       -e APP_KEY="$APP_KEY" \
       -e DB_DATABASE=/var/lib/db/$DB_FILE \
       -e SEED_DATABASE="$SEED_DATABASE" \
       -e ADMIN_PASSWORD=secret \
       "$IMAGE_NAME"
