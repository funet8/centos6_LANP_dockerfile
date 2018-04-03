#!/bin/bash

#mkdir -p /data/docker/httpd/conf.d/
#cp httpd.conf php.ini /data/docker/httpd/
#cp apache_main.conf /data/docker/httpd/conf.d/

wget http://www.funet8.com/img/linux/apache_docker.tar.gz && tar -zxf apache_docker.tar.gz -C /data/docker/

#docker build -t  funet8/centos6_httpd_php56:v1 .

#启动容器
docker run -itd --name centos6_httpd_php56 \
--link=centos6MariaDBv1:centos6MariaDBv1 \
--restart always \
-p 8080:8080 \
-v /data/docker/httpd/httpd.conf:/etc/httpd/conf/httpd.conf \
-v /data/docker/httpd/php.ini:/etc/php.ini  \
-v /data/docker/httpd/conf.d/:/etc/httpd/conf.d/  \
-v /data/wwwroot/:/data/wwwroot/ \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-httpd-php:v5.6
