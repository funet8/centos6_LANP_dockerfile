#!/bin/bash
mkdir -p /data/docker/httpd/conf.d/
cp httpd.conf php.ini /data/docker/httpd/
cp apache_main.conf /data/docker/httpd/conf.d/
cp php.conf /data/docker/httpd/conf.d/

docker build -t  funet8/centos6_httpd_php56:v1 .

#启动容器
docker run -itd --name centos6_httpd_php56 \
--restart always -p 8080:8080 \
-v /data/docker/httpd/httpd.conf:/etc/httpd/conf/httpd.conf \
-v /data/docker/httpd/php.ini:/etc/php.ini  \
-v /data/docker/httpd/conf.d/:/etc/httpd/conf.d/  \
-v /data/wwwroot/:/data/wwwroot/ \
funet8/centos6_httpd_php56:v1
