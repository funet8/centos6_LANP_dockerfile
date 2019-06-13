#!/bin/bash

###########################################################
#名字：	run-aliyun-apache.sh
#功能：	自动创建基于CENTOS6的apache
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
DOCKER_httpd="centos6_httpd_php56"

###构建apache-docker
mkdir -p /data/docker/httpd/conf.d/
cd /data/docker/httpd/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Apache_php5.6/httpd.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Apache_php5.6/php.ini
cd /data/docker/httpd/conf.d/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Apache_php5.6/apache_main.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Apache_php5.6/php.conf
###########################################################
#启动容器 --link链接mysql容器
###########################################################
docker run -itd --name ${DOCKER_httpd} \
--restart always \
-p 8080:8080 \
-v /data/docker/httpd/httpd.conf:/etc/httpd/conf/httpd.conf \
-v /data/docker/httpd/php.ini:/etc/php.ini  \
-v /data/docker/httpd/conf.d/:/etc/httpd/conf.d/  \
-v /data/wwwroot/:/data/wwwroot/ \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-httpd-php:v5.7

##检查docker-nginx的脚本
echo "
docker exec -it $DOCKER_httpd /bin/bash -c 'nginx -t'
">>/root/test_docker_conf.sh

##重启docker-nginx的脚本
echo "
docker restart $DOCKER_httpd
" >> /root/update_docker_web.sh

##保存并重启iptables
service iptables save
systemctl restart iptables.service

##删除docker
#rm -rf /data/docker/httpd
#docker rm -f ${DOCKER_httpd}




###权限问题的总结
#在宿主上查看www用户的ID
## cat /etc/passwd |grep www
#www:x:1001:1001::/home/www:/sbin/nologin
#进入docker虚拟机
## usermod -u 1001 www
## groupmod -g 1001 www
#将所需要的目录更改权限
#chown www.www -R /data/web/dir/