#!/bin/bash
#创建文件夹、复制nginx配置文件

mkdir -p /data/docker/nginx_conf/conf.d/
cd /data/docker/nginx_conf/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/nginx.conf
cd /data/docker/nginx_conf/conf.d/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/nginx_main.conf

#启动容器
docker run -itd --name DockerNginx \
--link=centos6MariaDBv1:centos6MariaDBv1 \
--link=centos6_httpd_php56:centos6_httpd_php56 \
--restart always \
-p 80:80 -p 443:443 \
-v /data/docker/nginx_conf/nginx.conf:/etc/nginx/nginx.conf \
-v /data/docker/nginx_conf/conf.d/:/etc/nginx/conf.d/ \
-v /data/wwwroot/log/:/var/log/nginx/  \
-v /data/wwwroot/:/data/wwwroot/ \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-nginx:v1
