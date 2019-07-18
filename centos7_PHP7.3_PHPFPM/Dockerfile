#
# MAINTAINER        star <funet8@163.com>
# DOCKER-VERSION    1.6.1
#
# Dockerizing CentOS7: Dockerfile for building CentOS images
# centos7-php7.3
#FROM	registry.cn-shenzhen.aliyuncs.com/funet8/centos7.2-base:v1
FROM	docker.io/0702/centos7 
MAINTAINER star  <funet8@163.com>

ENV TZ "Asia/Shanghai"
ENV TERM xterm

#新建用户和用户组
RUN groupadd www && useradd -g www www

#安装依赖包
RUN   yum -y update
RUN   yum install -y libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel
RUN  yum install -y gcc gcc-c++

#升级libzip-devel版本
RUN yum remove -y libzip
COPY php-ext/libzip-1.2.0.tar.gz /tmp/
RUN tar zxf /tmp/libzip-1.2.0.tar.gz -C /tmp/ && cd /tmp/libzip-1.2.0 &&  ./configure && make && make install && make test

RUN echo '/usr/local/lib64'>>/etc/ld.so.conf
RUN echo '/usr/lib'>>/etc/ld.so.conf
RUN echo '/usr/lib64'>>/etc/ld.so.conf
RUN ldconfig -v
RUN cp /usr/local/lib/libzip/include/zipconf.h /usr/local/include/zipconf.h

#编译安装php7.3
COPY php-ext/php-7.3.7.tar.gz /tmp/

RUN tar zxf /tmp/php-7.3.7.tar.gz -C /tmp/ && cd /tmp/php-7.3.7 && ./configure --prefix=/usr/local/php --with-config-file-path=/etc --enable-fpm --with-fpm-user=www --with-fpm-group=www --enable-inline-optimization --disable-debug --disable-rpath --enable-shared --enable-soap --with-libxml-dir --with-xmlrpc --with-openssl --with-mcrypt --with-mhash --with-pcre-regex --with-sqlite3 --with-zlib --enable-bcmath --with-iconv --with-bz2 --enable-calendar --with-curl --with-cdb --enable-dom --enable-exif --enable-fileinfo --enable-filter --with-pcre-dir --enable-ftp --with-gd --with-openssl-dir --with-jpeg-dir --with-png-dir --with-zlib-dir --with-freetype-dir --enable-gd-native-ttf --enable-gd-jis-conv --with-gettext --with-gmp --with-mhash --enable-json --enable-mbstring --enable-mbregex --enable-mbregex-backtrack --with-libmbfl --with-onig --enable-pdo --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-zlib-dir --with-pdo-sqlite --with-readline --enable-session --enable-shmop --enable-simplexml --enable-sockets --enable-sysvmsg --enable-sysvsem --enable-sysvshm --enable-wddx --with-libxml-dir --with-xsl --enable-zip --enable-mysqlnd-compression-support --with-pear --enable-opcache && make && make install

#配置环境变量
RUN echo 'export PATH=$PATH:/usr/local/php/bin'>>/etc/profile
RUN source /etc/profile
RUN php -v

#安装SSL库
COPY php-ext/openssl-1.0.1j.tar.gz /tmp/
RUN tar zxf /tmp/openssl-1.0.1j.tar.gz -C /tmp/  && cd /tmp/openssl-1.0.1j/ && ./config && make && make install

#安装memcache扩展
RUN  yum install -y libmemcached libmemcached-devel
COPY php-ext/libmemcached-1.0.16.tar.gz /tmp/
RUN tar zxf /tmp/libmemcached-1.0.16.tar.gz -C /tmp/  && cd /tmp/libmemcached-1.0.16 && ./configure -prefix=/usr/local/libmemcached -with-memcached && make && make install && cd /tmp/php7.3-software/php-memcached/ && /usr/local/php/bin/phpize && ./configure -enable-memcached -with-php-config=/usr/local/php/bin/php-config -with-zlib-dir -with-libmemcached-dir=/usr/local/libmemcached -prefix=/usr/local/phpmemcached  --disable-memcached-sasl && make  -j4 && make install

#安装phpredis扩展
COPY php-ext/phpredis.tar.gz /tmp/
RUN tar zxf /tmp/phpredis.tar.gz -C /tmp/ && cd /tmp/phpredis && /usr/local/php/bin/phpize && ./configure --with-php-config=/usr/local/php/bin/php-config && make && make install

RUN systemctl restart php-fpm

#开机启动	
RUN systemctl enable php-fpm.service
RUN systemctl restart php-fpm.service
RUN ln /usr/local/php/sbin/php-fpm /usr/local/sbin

#删除压缩包
RUN rm -rf /tmp/*
	
#添加php.ini和httpd.conf	
ADD conf/php.ini /etc/php.ini
ADD conf/php-fpm.conf /etc/php-fpm.conf
ADD conf/php-fpm.service /usr/lib/systemd/system/php-fpm.service


#允许www使用sudo
RUN echo "www    ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers 

EXPOSE 7300
ADD supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]



