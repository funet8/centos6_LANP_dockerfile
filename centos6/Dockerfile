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

VOLUME ["/data"]

#nginx配置文件
RUN cp -p /etc/nginx/nginx.conf  /etc/nginx/nginx.conf.bak && \
	rm -rf /etc/nginx/nginx.conf	&& \
	ln -s /data/conf/nginx.conf /etc/nginx/
ADD nginx.conf /data/conf/nginx.conf

RUN cp -p /etc/nginx/conf.d/default.conf  /etc/nginx/conf.d/default.conf.bak && \
	rm -rf /etc/nginx/conf.d/default.conf	
ADD nginx_main.conf /data/conf/sites-available/nginx_main.conf

##httpd配置文件
RUN cp -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak && \
  mv /etc/httpd/conf/httpd.conf /data/conf/ && \
  ln -s /data/conf/httpd.conf /etc/httpd/conf/

RUN sed -i 's/Listen 80/Listen 8080/g' /etc/httpd/conf/httpd.conf
  

##php配置文件
RUN cp -p /etc/php.ini /etc/php.ini.bak && \
  mv /etc/php.ini /data/conf/ && \
  ln -s /data/conf/php.ini /etc/  



#重启nginx和httpd
#ENTRYPOINT ["/etc/init.d/nginx","reload"]
#ENTRYPOINT ["/etc/init.d/httpd","reload"]

EXPOSE 80 443 22
