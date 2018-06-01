#!/bin/bash


###########################################################
###构建mysql-docker
#解压配置文件和数据库目录
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_MariaDB/mysql_docker.tar.gz && tar -zxf mysql_docker.tar.gz -C /data/docker/
     
#使用阿里云镜像
#docker run -itd --name centos6base  registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-mariadb:v1

#运行docker
docker run -itd --name centos6mysql \
--restart always \
-p 61950:3306 \
-v /data/docker/mysql_conf/my.cnf:/etc/my.conf  \
-v /data/docker/mysql_conf/mysql_slowQuery.log:/var/log/mysql/mysql_slowQuery.log \
-v /data/docker/mysql_docker:/var/lib/mysql \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-mariadb:v1

#mysql用户密码
#dbuser_lxx
#Yxa7dvKh94JhYY303bb
#远程链接
# mysql -u dbuser_lxx -h ${宿主机IP} -P61950 -p

# mysql -u dbuser_lxx -h ${dockerIP} -P3306 -p

###########################################################
###########################################################
###########################################################

###构建apache-docker
mkdir -p /data/docker/httpd/conf.d/
cd /data/docker/httpd/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Apache_php5.6/httpd.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Apache_php5.6/php.ini

cd /data/docker/httpd/conf.d/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Apache_php5.6/apache_main.conf

#启动容器 --link链接mysql容器
docker run -itd --name centos6_httpd_php56 \
--link=centos6mysql:centos6mysql \
--restart always \
-p 8080:8080 \
-v /data/docker/httpd/httpd.conf:/etc/httpd/conf/httpd.conf \
-v /data/docker/httpd/php.ini:/etc/php.ini  \
-v /data/docker/httpd/conf.d/:/etc/httpd/conf.d/  \
-v /data/wwwroot/:/data/wwwroot/ \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-httpd-php:v5.7

###########################################################
###########################################################
###########################################################

###构建nginx-docker
mkdir -p /data/docker/nginx_conf/conf.d/
cd /data/docker/nginx_conf/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/nginx.conf
cd /data/docker/nginx_conf/conf.d/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/nginx_main.conf

#启动容器
docker run -itd --name dockernginx \
--link=centos6mysql:centos6mysql \
--link=centos6_httpd_php56:centos6_httpd_php56 \
--restart always \
-p 80:80 -p 443:443 \
-v /data/docker/nginx_conf/nginx.conf:/etc/nginx/nginx.conf \
-v /data/docker/nginx_conf/conf.d/:/etc/nginx/conf.d/ \
-v /data/wwwroot/log/:/var/log/nginx/  \
-v /data/wwwroot/:/data/wwwroot/ \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-nginx:v1



