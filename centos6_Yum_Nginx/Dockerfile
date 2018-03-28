#
# MAINTAINER        star <funet8@163.com>
# DOCKER-VERSION    1.6.1
#
# Dockerizing CentOS6: Dockerfile for building CentOS images
# LNAP

#FROM 		daocloud.io/centos:6.9
#FROM 		funet8/centos:6.9 .
FROM 		registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:v1
MAINTAINER star  <funet8@163.com>

ENV TZ "Asia/Shanghai"
ENV TERM xterm

#安装nginx
RUN rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm && \
	yum -y install nginx
	
RUN groupadd www && \ 
useradd -g www www

#允许www使用sudo
RUN echo "www    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers 

#指定运行容器时的用户名或 UID，后续的 RUN 也会使用指定用户
#USER www
EXPOSE 80 443
ADD supervisord.conf /etc/supervisord.conf
ADD nginx.conf /etc/nginx/nginx.conf
ADD nginx_main.conf /etc/nginx/conf.d/nginx_main.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]



