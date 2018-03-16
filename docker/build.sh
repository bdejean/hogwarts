#!/bin/sh

set -x

IMAGE=hogwarts
VERSION=$(git log -1 --pretty=%h)
if ! git diff-index --quiet HEAD --; then
	VERSION=${VERSION}-wip-$(date '+%s')
fi

if docker build -t $IMAGE:$VERSION . ; then
	docker tag $IMAGE:$VERSION $IMAGE:latest
fi

