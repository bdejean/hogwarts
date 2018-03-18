#!/bin/bash


function exists_or_die {
	P=$1
	if [[ ! -e "$P" ]]; then
		echo "File or directory '$P' does not exists"
		exit 1
	fi
}


function doesnt_exist_or_die {
	P=$1
	if [[ -e "$P" ]]; then
		echo "File or directory '$P' already exists"
		exit 2
	fi
}


DB=$1
BACKUP_DIR=$2

TIMESTAMP=$(date +"%Y-%m-%d-%HH%M")

DEST_BASE=${BACKUP_DIR}/${DB##*/}.${TIMESTAMP}
DEST_DUMP=${DEST_BASE}.dump
DEST_BCK=${DEST_BASE}.bck

exists_or_die $DB
exists_or_die $BACKUP_DIR
doesnt_exist_or_die $DEST_DUMP
doesnt_exist_or_die $DEST_BCK
doesnt_exist_or_die $DEST_DUMP.gz
doesnt_exist_or_die $DEST_BCK.gz


sqlite3 $DB '.dump' > $DEST_DUMP
sqlite3 $DB ".backup $DEST_BCK"
gzip -9 $DEST_DUMP $DEST_BCK

