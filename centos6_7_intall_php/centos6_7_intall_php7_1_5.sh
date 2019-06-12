#!/bin/bash
############################################################
#名字：	centos6_7_intall_php7_1_5.sh
#功能：	自动创建基于CENTOS6的mysql+apache+nginx
#作者：	star
#邮件：	star@funet8.com
#时间：      2019/05/08
#Version 1.0
#20190508修改记录：
# shell脚本初始化
#说明：必须登录阿里云docker仓库！！！！
###########################################################


PHP_URL=http://ftp.ntu.edu.tw/php/distributions
PHP_FILE=php-7.1.5.tar.gz
PHP_FILE_DIR=php-7.1.5
PHP_PREFIX=/usr/local/php7
USER=www

function install_php {
	if [ ! -d ${PHP_PREFIX} ];then
		wget -c ${PHP_URL}/${PHP_FILE}
	tar zxf ${PHP_FILE}
	mv ${PHP_FILE_DIR} ${PHP_PREFIX}
	cd ${PHP_PREFIX}
	
	#安装依赖包
	yum –y install libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel
	
	./configure --prefix=${PHP_PREFIX} \
	--with-config-file-path=/etc \
	--enable-fpm \
	--with-fpm-user=${USER} \
	--with-fpm-group=${USER} \
	--enable-inline-optimization \
	--disable-debug \
	--disable-rpath \
	--enable-shared \
	--enable-soap \
	--with-libxml-dir \
	--with-xmlrpc \
	--with-openssl \
	--with-mcrypt \
	--with-mhash \
	--with-pcre-regex \
	--with-sqlite3 \
	--with-zlib \
	--enable-bcmath \
	--with-iconv \
	--with-bz2 \
	--enable-calendar \
	--with-curl \
	--with-cdb \
	--enable-dom \
	--enable-exif \
	--enable-fileinfo \
	--enable-filter \
	--with-pcre-dir \
	--enable-ftp \
	--with-gd \
	--with-openssl-dir \
	--with-jpeg-dir \
	--with-png-dir \
	--with-zlib-dir \
	--with-freetype-dir \
	--enable-gd-native-ttf \
	--enable-gd-jis-conv \
	--with-gettext \
	--with-gmp \
	--with-mhash \
	--enable-json \
	--enable-mbstring \
	--enable-mbregex \
	--enable-mbregex-backtrack \
	--with-libmbfl \
	--with-onig \
	--enable-pdo \
	--with-mysqli=mysqlnd \
	--with-pdo-mysql=mysqlnd \
	--with-zlib-dir \
	--with-pdo-sqlite \
	--with-readline \
	--enable-session \
	--enable-shmop \
	--enable-simplexml \
	--enable-sockets \
	--enable-sysvmsg \
	--enable-sysvsem \
	--enable-sysvshm \
	--enable-wddx \
	--with-libxml-dir \
	--with-xsl \
	--enable-zip \
	--enable-mysqlnd-compression-support \
	--with-pear \
	--enable-opcache
	if [ $? -eq 0 ];then
	 make && make install
	else
	 exit 1
	fi
	fi
	}
##配置php
function config_php {
	cp ${PHP_PREFIX}/php.ini-production /etc/php.ini
	cp ${PHP_PREFIX}/etc/php-fpm.conf.default ${PHP_PREFIX}/etc/php-fpm.conf
	cp ${PHP_PREFIX}/etc/php-fpm.d/www.conf.default ${PHP_PREFIX}/etc/php-fpm.d/www.conf
	cp ${PHP_PREFIX}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm7
	chmod +x /etc/init.d/php-fpm7
	
	useradd ${USER}
	
	
	#端口改为：5600
	#listen = 127.0.0.1:9000  listen = 0.0.0.0:5600
	#修改配置文件
	sed -i 's/listen \= 127\.0\.0\.1\:9000/listen \= 0\.0\.0\.0\:7000/g' ${PHP_PREFIX}/etc/php-fpm.d/www.conf
	
	iptables -A INPUT -p tcp --dport 7000 -j ACCEPT
	
	#开机启动	
	/etc/init.d/php-fpm start
	echo '/etc/init.d/php-fpm7 start'>> /etc/rc.local
	
	}
	
install_php
config_php