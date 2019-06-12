#!/bin/bash
DOCKER_httpd=centos6_httpd_php56

docker exec -it $DOCKER_httpd /bin/bash -c 'httpd -t'
