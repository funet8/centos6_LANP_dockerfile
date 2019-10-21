#!/bin/bash

docker build -t  funet8/phpfpm73 .

#启动容器
docker run -itd --name phpfpm73 \
--restart always -p 7300:7300 \
-v /data/docker/phpfpm73/php-fpm.conf:/etc/php-fpm.conf \
-v /data/docker/phpfpm73/php.ini:/etc/php.ini  \
-v /data/wwwroot/:/data/wwwroot/ \
funet8/phpfpm73

docker run -itd --name test registry.cn-shenzhen.aliyuncs.com/funet8/centos7.2-base:v1