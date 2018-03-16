#!/bin/bash

DB=$1
BACKUP_DIR=$2

TIMESTAMP=$(date +"%Y-%m-%d-%HH%M")

cp -nvp $DB ${BACKUP_DIR}/${DB##*/}.${TIMESTAMP}

