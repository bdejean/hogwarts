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
DB_PATH=
DB_DIR=
DB_NAME=

function usage()
{
    echo "Usage: $0 --db /path/to/db.db [--build] [--create-db]" >/dev/stderr
    exit 1
}


while [[ ! -z $1 ]]; do
    case $1 in
	'--build')
	    BUILD_IMAGE=true
	    ;;
	'--create-db')
	    CREATE_DB=true
	    ;;
	'--db')
	    shift
	    DB_PATH="$1"
	    ;;
    esac
    shift
done


if [[ -z $DB_PATH ]]; then
    usage
fi

DB_NAME=$(basename $DB_PATH)
DB_DIR=$(dirname $DB_PATH)

DB_DIR_REAL=$(realpath $DB_DIR)
echo "Expaning $DB_DIR to $DB_DIR_REAL"
DB_DIR=$DB_DIR_REAL

if [[ $CREATE_DB != "true" && ! -f $DB_PATH ]]; then
    echo "$DB_PATH doest not exist, use --create first!" >/dev/stderr
    usage
fi

if [[ $(stat -c '%a' $DB_PATH) != *777 ]]; then
	echo "$DB_PTATHneeds to be world-writable for docker"
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

