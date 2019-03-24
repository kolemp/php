#!/bin/bash

if [ -e /shared_web ] && [ ! $(ls -A /shared_web) ] ; then
    cp -r /data/application/web/* /shared_web/
fi

exec "$@"