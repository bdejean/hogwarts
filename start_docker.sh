#!/bin/bash

set -x

IMAGE_NAME='hogwarts'
HTTP_PORT=44080
BUILD_IMAGE=true
MIGRATE_DATABASE=false
CREATE_DB=false

APACHE_SERVERNAME=hogwarts.lan

APP_ENV=local # TODO Change
APP_DEBUG=true # TODO Change
APP_KEY=
DB_DIR=
DB_NAME=


while [[ ! -z $1 ]]; do
    case $1 in
	'--build')
	    BUILD_IMAGE=true
	    ;;
	'--create-db')
	    CREATE_DB=true
	    ;;
	'--db-dir')
	    shift
	    DB_DIR="$1"
	    ;;
	'--db-name')
	    shift
	    DB_NAME="$1"
	    ;;
    esac
    shift
done

DB_DIR_REAL=$(realpath $DB_DIR)
echo "Expaning $DB_DIR to $DB_DIR_REAL"
DB_DIR=$DB_DIR_REAL

if [[ -z $DB_DIR ]]; then
    if [ ! -d $DB_DIR ]; then
	echo "$DB_DIR doest not exist, create it!"
	exit 1
    fi
    if [ ! -f $DB_DIR/$DB_NAME ]; then
	echo "$DB_NAME doest not exist, use --create first!"
	exit 1
    fi
fi

if [[ $(stat -c '%a' $DB_DIR/$DB_NAME) != *777 ]]; then
	echo "$DB_DIR/$DB_NAME needs to be world-writable for docker"
fi

if [[ -z $(docker images -q $IMAGE_NAME 2> /dev/null) || $BUILD_IMAGE ]]; then
    docker build -t "$IMAGE_NAME" . || exit 1
fi

if [ $CREATE_DB = 'true' ]; then

    if [ "z$ADMIN_EMAIL" = "z" ]; then
	echo 'Please set env var ADMIN_EMAIL'
	exit 1
    fi

    if [ "z$ADMIN_PASSWORD" = "z" ]; then
	echo 'Please set env var ADMIN_PASSWORD'
	exit 1
    fi

    [ ! -d $DB_DIR ] && mkdir -m 777 $DB_DIR

    docker run -i -p $HTTP_PORT:80 \
	   -v /etc/localtime:/etc/localtime:ro \
	   -v "$DB_DIR:/var/lib/db" \
	   -e APACHE_SERVERNAME="$APACHE_SERVERNAME" \
	   -e APP_ENV="$APP_ENV" \
	   -e APP_DEBUG="$APP_DEBUG" \
	   -e APP_KEY="$APP_KEY" \
	   -e DB_DATABASE=/var/lib/db/$DB_NAME \
	   -e ADMIN_EMAIL="$ADMIN_EMAIL" \
	   -e ADMIN_PASSWORD="$ADMIN_PASSWORD" \
	   "$IMAGE_NAME" \
	   /bin/sh -c 'touch $DB_DATABASE \
	   	      && cd $APACHE_DOCUMENTROOT && php artisan migrate && php artisan db:seed \
		      && ls -l $DB_DATABASE && echo $DB_DATABASE created and seeded'
else
    docker run -i -d -p $HTTP_PORT:80 \
	   -v /etc/localtime:/etc/localtime:ro \
	   -v "$DB_DIR:/var/lib/db" \
	   -e APACHE_SERVERNAME="$APACHE_SERVERNAME" \
	   -e APP_ENV="$APP_ENV" \
	   -e APP_DEBUG="$APP_DEBUG" \
	   -e APP_KEY="$APP_KEY" \
	   -e DB_DATABASE=/var/lib/db/$DB_NAME \
	   "$IMAGE_NAME"
fi

