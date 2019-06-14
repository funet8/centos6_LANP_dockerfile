#!/bin/bash

###########################################################
#名字：	run-aliyun-PHPFPM5.sh
#功能：	创建PHPFPM5
#作者：	star
#邮件:	funet8@163.com
#公有仓库不需要登录

###下载配置文件
mkdir -p /data/docker/phpfpm5/
cd /data/docker/phpfpm5/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_7_intall_php/docker_conf/phpfpm5/php-fpm.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_7_intall_php/docker_conf/phpfpm5/php.ini


docker run -itd --name PHP_FPM5 \
-p 5600:9000 \
--restart always \
-v /data/wwwroot/web:/data/wwwroot/web \
-v /data/docker/phpfpm5/php-fpm.conf:/etc/php-fpm.conf \
-v /data/docker/phpfpm5/php.ini:/etc/php.ini \
-v /etc/localtime:/etc/localtime \
registry.cn-shenzhen.aliyuncs.com/funet8/php-fpm-5.6


##保存并重启iptables
service iptables save
systemctl restart iptables.service

##删除docker
#rm -rf /data/docker/phpfpm5
#docker rm -f PHP_FPM5
#docker log -f PHP_FPM5


