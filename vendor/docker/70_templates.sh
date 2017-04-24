#!/bin/sh
dockerize -template /home/app/vendor/docker/nginx.conf.tmpl:/etc/nginx/nginx.conf
