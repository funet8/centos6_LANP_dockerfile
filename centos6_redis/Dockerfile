#
# MAINTAINER        star <funet8@163.com>
# DOCKER-VERSION    
#
# Dockerizing CentOS6: Dockerfile for building CentOS images
# redis

#/etc/redis/6379.conf  ---redis配置文件
#port 6379
#daemonize yes  			# 使Redis以守护进程模式运行
#dir /data/docker/redis/  	# 设置持久化文件存放的位置

#FROM 		daocloud.io/centos:6.9
#FROM 		funet8/centos:6.9 .
FROM 		registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:v1
MAINTAINER star  <funet8@163.com>

ENV TZ "Asia/Shanghai"
ENV TERM xterm

#1.安装redis
RUN yum -y install tcl gcc gcc-c++ libstdc++-devel && \
	mkdir -p /home/data/software/ && \
	cd /home/data/software/	&& \
	wget http://download.redis.io/releases/redis-stable.tar.gz && \
	tar -zxf redis-stable.tar.gz && \
	cd redis-stable	&& \
	make	&& \
	cd src && make test && \
	make install
#2.配置redis
RUN cp /home/data/software/redis-stable/utils/redis_init_script /etc/init.d/redis && \
	mkdir -p /data/docker/redis/
	
ADD 6379.conf /etc/redis/6379.conf
	
	
EXPOSE 6379
ADD supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]



