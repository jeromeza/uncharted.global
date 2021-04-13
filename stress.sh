#!/bin/bash
if [ -z "$*" ]; then echo "Please specify a http site in the format of http://domain.com/ or http://ip/" && exit 0; fi
apt install apache2-utils -y
ab -n 10000000 -c 1000 $1/
