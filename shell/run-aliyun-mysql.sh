#!/bin/bash

###########################################################
#名字：	run-aliyun-mysql.sh
#功能：	自动创建基于CENTOS6的mysql
#作者：	star
#邮件:	funet8@163.com
#必须登录阿里云docker仓库！！！！

###########################################################
##使用私有阿里云docker仓库
#1.登录
# docker login --username=funet8@163.com registry.cn-shenzhen.aliyuncs.com
# 输入密码
###########################################################
###########################################################
###构建mysql-docker
#解压配置文件和数据库目录
###########################################################

wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_MariaDB/mysql_docker.tar.gz && tar -zxf mysql_docker.tar.gz -C /data/docker/
###########################################################
#使用阿里云镜像
#docker run -itd --name centos6base  registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-mariadb:v1
#运行docker
###########################################################
docker run -itd --name centos6mysql \
--restart always \
-p 61950:3306 \
-v /data/docker/mysql_conf/my.cnf:/etc/my.conf  \
-v /data/docker/mysql_conf/mysql_slowQuery.log:/var/log/mysql/mysql_slowQuery.log \
-v /data/docker/mysql_docker:/var/lib/mysql \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-mariadb:v1
###########################################################
#mysql用户密码-建议修改密码
#dbuser_lxx
#Yxa7dvKh94JhYY303bb
#远程链接
# mysql -u dbuser_lxx -h ${宿主机IP} -P61950 -p
# mysql -u dbuser_lxx -h ${dockerIP} -P3306 -p
###########################################################

