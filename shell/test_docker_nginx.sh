#!/bin/bash
DOCKER_nginx=nginx

docker exec -it $DOCKER_nginx /bin/bash -c 'nginx -t'
