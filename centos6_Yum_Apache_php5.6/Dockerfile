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

#安装httpd,php和其他
RUN yum -y install httpd php-mysql php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-mcrypt php-bcmath php-mhash libmcrypt

#安装php5.6
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-6.rpm

ADD remi.repo /etc/yum.repos.d/remi.repo
RUN yum --enablerepo=remi,remi-php56 install -y php-fpm php-common php-devel php-mysqlnd php-mbstring php-mcrypt
RUN chmod 777 /var/lib/php/session -R

#安装phpreids扩展

#安装memcached
RUN yum install -y libmemcached
COPY php-ext/memcache-3.0.8.tgz /tmp/
RUN tar zxf /tmp/memcache-3.0.8.tgz -C /tmp/ && \
	cd /tmp/memcache-3.0.8 && \
	/usr/bin/phpize && \
	./configure --enable-memcache --with-php-config=/usr/bin/php-config --with-zlib-dir && \
	make && make install && \
	make test

#安装redis扩展
COPY php-ext/phpredis.tar.gz /tmp/
RUN tar zxf /tmp/phpredis.tar.gz -C /tmp/ && \
	cd /tmp/phpredis &&\
	/usr/bin/phpize &&\
	./configure && \
	make && make install &&\
	make test

#删除压缩包
RUN rm -rf /tmp/memcache* /tmp/phpredis*
	
#添加php.ini和httpd.conf	
ADD httpd.conf /etc/httpd/conf/httpd.conf
ADD php.ini /etc/php.ini
ADD apache_main.conf /etc/httpd/conf.d/apache_main.conf

RUN groupadd www && \ 
useradd -g www www

#允许www使用sudo
RUN echo "www    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers 

EXPOSE 8080
ADD supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]



