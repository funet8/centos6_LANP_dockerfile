#!/bin/bash

#创建文件夹、复制redis配置文件
mkdir -p /data/docker/redis/
cp 6379.conf /data/docker/redis/

#构建镜像
docker build -t  funet8/centos6redis:v1 .

#启动容器
docker run -itd --name dockerRedis \
--restart always \
-p 63920:6379 \
-v /data/docker/redis/6379.conf:/etc/redis/6379.conf \
-v /data/wwwroot/:/data/wwwroot/ \
funet8/centos6redis2:v2
