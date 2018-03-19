#!/bin/bash

set -eux

SITE=hogwarts
KEYSDIR=./keys
KEY=$KEYSDIR/$SITE.key
CERT=$KEYSDIR/$SITE.cert

if [ ! -d $KEYSDIR ]; then
	mkdir $KEYSDIR
fi

if [ ! -f $KEY ]; then
	openssl req -x509 -newkey rsa:4096 -subj "/CN=hogwarts/O=Private/L=Nuage/C=FR" -nodes -keyout $KEY -out $CERT -days 3650
fi

