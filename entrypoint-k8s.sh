#!/bin/bash

if [ -e /shared_web ] && [ -z "$(ls -A /shared_web)" ] ; then
    cp -r /data/application/web/* /shared_web/
fi

exec "$@"