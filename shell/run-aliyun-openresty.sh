#!/bin/bash

###########################################################
#名字：	run-aliyun-openresty.sh
#功能：	创建openresty
#作者：	star
#邮件:	funet8@163.com
#公有仓库不需要登录

DOCKER_openresty="openresty"


###下载配置文件
mkdir -p /data/docker/openresty/conf.d/waf/rule-config
chmod 777 -R /data/wwwroot/log/
cd /data/docker/openresty/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/nginx.conf
cd /data/docker/openresty/conf.d/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/nginx_main.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Apache_PHP5.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Backup_PHP5.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Backup_PHP7.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Static_File.conf
#4.下载waf策略
cd /data/docker/openresty/conf.d/waf/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/access.lua
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/config.lua
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/init.lua
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/lib.lua
cd /data/docker/openresty/conf.d/waf/rule-config
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/args.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/blackip.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/cookie.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/post.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/url.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/useragent.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/whiteip.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/whiteurl.rule

#启动容器
docker run -itd --name="openresty" \
--restart always \
-p 80:80 \
-p 443:443 \
-v /data/docker/openresty/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf:ro \
-v /data/docker/openresty/conf.d:/etc/nginx/conf.d \
-v /data/wwwroot/:/data/wwwroot/ \
-v /etc/localtime:/etc/localtime \
registry.cn-shenzhen.aliyuncs.com/funet8/openresty



##检查docker-nginx的脚本
echo "
docker exec -it $DOCKER_openresty /bin/bash -c 'nginx -t'
">>/root/test_docker_conf.sh

##重启docker-nginx的脚本
echo "
docker restart $DOCKER_openresty
" >> /root/update_docker_web.sh


##保存并重启iptables
service iptables save
systemctl restart iptables.service

##删除docker
#rm -rf /data/docker/openresty /root/test_docker_conf.sh /root/update_docker_web.sh
#docker rm -f ${DOCKER_openresty}



