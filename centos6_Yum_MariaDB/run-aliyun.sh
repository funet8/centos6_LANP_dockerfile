#!/bin/bash

#解压配置文件和数据库目录
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_MariaDB/mysql_docker.tar.gz && tar -zxf mysql_docker.tar.gz -C /data/docker/

#使用阿里云镜像
#docker run -itd --name centos6base  registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-mariadb:v1

#运行docker
docker run -itd --name centos6MariaDBv1 \
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
