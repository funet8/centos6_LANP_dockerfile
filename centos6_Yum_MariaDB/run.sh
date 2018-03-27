#!/bin/bash

#解压配置文件和数据库目录
tar -zxf mysql_docker.tar.gz -C /data/docker/


#构建镜像
docker build -t  funet8/centos6mariadb .

#运行docker
docker run -itd --name centos6MariaDBv1 \
--restart always \
-p 61950:3306 \
-v /data/docker/mysql_conf/my.cnf:/etc/my.conf  \
-v /data/docker/mysql_conf/mysql_slowQuery.log:/var/log/mysql/mysql_slowQuery.log \
-v /data/docker/mysql_docker:/var/lib/mysql \
funet8/centos6mariadb