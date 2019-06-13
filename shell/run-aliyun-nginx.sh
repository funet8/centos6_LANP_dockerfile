#!/bin/bash

###########################################################
#名字：	run-aliyun-nginx.sh
#功能：	自动创建基于CENTOS6的nginx
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
DOCKER_nginx="nginx"


###下载配置文件
mkdir -p /data/docker/nginx_conf/conf.d/
cd /data/docker/nginx_conf/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/nginx.conf
cd /data/docker/nginx_conf/conf.d/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/nginx_main.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Apache_PHP5.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Backup_PHP5.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Backup_PHP7.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Safe.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Static_File.conf

#启动容器
docker run -itd --name ${DOCKER_nginx} \
--restart always \
-p 80:80 -p 443:443 \
-v /data/docker/nginx_conf/nginx.conf:/etc/nginx/nginx.conf \
-v /data/docker/nginx_conf/conf.d/:/etc/nginx/conf.d/ \
-v /data/wwwroot/log/:/var/log/nginx/  \
-v /data/wwwroot/:/data/wwwroot/ \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-nginx:v1

##检查docker-nginx的脚本
echo "
docker exec -it $DOCKER_nginx /bin/bash -c 'nginx -t'
">>/root/test_docker_conf.sh

##重启docker-nginx的脚本
echo "
docker restart $DOCKER_nginx
" >> /root/update_docker_web.sh


##保存并重启iptables
service iptables save
systemctl restart iptables.service

##删除docker
#rm -rf /data/docker/nginx_conf /root/update_docker_web.sh /root/update_docker_web.sh
#docker rm -f ${DOCKER_nginx}



