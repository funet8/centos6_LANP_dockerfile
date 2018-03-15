#
# MAINTAINER        star <funet8@163.com>
# DOCKER-VERSION    1.6.1
#
# Dockerizing CentOS6: Dockerfile for building CentOS images
# LNAP

FROM 		daocloud.io/centos:6.9
MAINTAINER star  <funet8@163.com>

ENV TZ "Asia/Shanghai"
ENV TERM xterm

ADD aliyun-centos6-mirror.repo /etc/yum.repos.d/CentOS-Base.repo
ADD aliyun-centos6-epel.repo /etc/yum.repos.d/epel.repo

RUN yum install -y curl wget tar bzip2 unzip vim-enhanced passwd sudo yum-utils hostname net-tools rsync man && \
    yum install -y gcc gcc-c++ git make automake cmake patch logrotate python-devel libpng-devel libjpeg-devel && \
    yum install -y --enablerepo=epel pwgen python-pip && \
    yum clean all
	
#卸载nginx httpd php
RUN yum -y remove nginx httpd* php*

#安装nginx
RUN rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm && \
	yum -y install nginx
#安装httpd,php和其他
RUN yum -y install httpd php php-mysql php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-mcrypt php-bcmath php-mhash libmcrypt

RUN groupadd www && \ 
useradd -g www www

#允许www使用sudo
RUN echo "www    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers 

#指定运行容器时的用户名或 UID，后续的 RUN 也会使用指定用户
#USER www

EXPOSE 80 443 8080

#安装supervisor并且add配置文件
RUN pip install supervisor
ADD supervisord.conf /etc/supervisord.conf

RUN mkdir -p /etc/supervisor.conf.d && \
    mkdir -p /var/log/supervisor

ADD supervisord.conf /etc/supervisord.conf	
ADD	supervisor_nginx.conf /etc/supervisor.conf.d/supervisor_nginx.conf
ADD	supervisor_apache.conf /etc/supervisor.conf.d/supervisor_apache.conf

CMD ["/usr/bin/supervisord -c /etc/supervisord.conf"]



