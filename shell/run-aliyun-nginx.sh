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
DOCKER_name="nginx"


###构建nginx-docker
mkdir -p /data/docker/nginx_conf/conf.d/
cd /data/docker/nginx_conf/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/nginx.conf
cd /data/docker/nginx_conf/conf.d/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/nginx_main.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/nginx_main.conf
#启动容器
docker run -itd --name ${DOCKER_name} \
--restart always \
-p 80:80 -p 443:443 \
-v /data/docker/nginx_conf/nginx.conf:/etc/nginx/nginx.conf \
-v /data/docker/nginx_conf/conf.d/:/etc/nginx/conf.d/ \
-v /data/wwwroot/log/:/var/log/nginx/  \
-v /data/wwwroot/:/data/wwwroot/ \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-nginx:v1

##检查docker-nginx的脚本
echo "
#!/bin/bash
DOCKER_name=nginx
docker exec -it $DOCKER_name /bin/bash -c 'nginx -t'
">/root/test_docker_nginx.sh

##重启docker-nginx的脚本
echo "
#!/bin/bash
DOCKER_name=nginx
docker restart $DOCKER_name
" > /root/update_docker_nginx.sh

