#!/bin/bash
docker build -t  funet8/centos_lnap:6.9.1 .

#启动容器
#docker run -itd --name centos6lnap --restart always -p 80:80 -p 443:443 -v /data/:/data/ -v /data/conf/nginx.conf:/etc/nginx/nginx.conf -v /data/conf/httpd.conf:/etc/httpd/conf/httpd.conf -v /data/conf/php.ini:/etc/php.ini  funet8/centos_lnap:6.9.1

#进入容器
#docker exec -it centos6lnap /bin/bash

#删除容器和镜像
#
#docker rm -f centos6lnap
#docker rmi funet8/centos_lnap:6.9.1