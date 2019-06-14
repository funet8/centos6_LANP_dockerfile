#!/bin/bash

###########################################################
#名字：	run-aliyun-PHPFPM7.sh
#功能：	创建PHPFPM7
#作者：	star
#邮件:	funet8@163.com
#公有仓库不需要登录

###下载配置文件
mkdir -p /data/docker/phpfpm7/
cd /data/docker/phpfpm7/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_7_intall_php/docker_conf/phpfpm7/php-fpm.conf
#wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_7_intall_php/docker_conf/phpfpm7/php.ini

docker run -itd --name PHP_FPM7 \
-p 7000:9000 \
--restart always \
-v /data/wwwroot/web:/data/wwwroot/web \
-v /data/docker/phpfpm7/php-fpm.conf:/etc/php-fpm.conf \
-v /etc/localtime:/etc/localtime \
registry.cn-shenzhen.aliyuncs.com/funet8/php-fpm-7.1

#会报错
#-v /data/docker/phpfpm5/php.ini:/etc/php.ini \

##保存并重启iptables
service iptables save
systemctl restart iptables.service

##删除docker
#rm -rf /data/docker/phpfpm7
#docker rm -f PHP_FPM7
#docker logs -f PHP_FPM7


