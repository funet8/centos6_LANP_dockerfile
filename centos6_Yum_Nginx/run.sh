#!/bin/bash

#创建文件夹、复制nginx配置文件
mkdir -p /data/docker/nginx_conf
cp nginx.conf nginx_main.conf /data/docker/nginx_conf/

#构建镜像
docker build -t  funet8/centos_Yum_Nginx:v1 .

#启动容器
docker run -itd --name centos6nginx \
--restart always \
-p 80:80 -p 443:443 \
-v /data/docker/nginx_conf/nginx.conf:/etc/nginx/nginx.conf \
-v /data/docker/nginx_conf/nginx_main.conf:/etc/nginx/conf.d/nginx_main.conf \
-v /data/wwwroot/log/nginx/:/var/log/nginx/  \
funet8/centos_Yum_Nginx:v1
