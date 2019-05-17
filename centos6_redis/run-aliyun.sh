#!/bin/bash

#创建文件夹、复制nginx配置文件
mkdir -p /data/docker/redis/
cd /data/docker/redis/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_redis/6379.conf 

#构建镜像
#docker build -t  funet8/centos6redis:v1 .

#启动容器
docker run -itd --name DockerRedis1 \
--restart always \
-p 63920:6379 \
-v /data/docker/redis/6379.conf:/etc/redis/6379.conf \
-v /data/wwwroot/:/data/wwwroot/ \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-redis:v2
