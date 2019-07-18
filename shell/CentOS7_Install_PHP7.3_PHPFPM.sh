#!/bin/bash
###########################################################
#名字：	CentOS7_install_PHP7.3_PHPFPM.sh
#功能：	centos7下安装php7.3+phpfpm
# phpfpm端口为 7300
#作者：	star
###########################################################
#上传php7.3-software.tar.gz 到 /data/software

PHP_DIR=/usr/local/php	#php安装路径
USER=www				#php用户
PHP_PORT='7300'  		#php-fpm端口

#检查是否是root用户######################################################################
if [ $(id -u) != "0" ]; then  
    echo "Error: You must be root to run this script, please use root to run"  
    exit 1
fi

#新建用户和用户组######################################################################
groupadd $USER
useradd -g $USER $USER

#安装依赖包
yum install -y libxml2 libxml2-devel openssl openssl-devel bzip2 bzip2-devel libcurl libcurl-devel libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel gmp gmp-devel libmcrypt libmcrypt-devel readline readline-devel libxslt libxslt-devel gcc gcc-c++

#新建文件夹######################################################################
wget -q -O - https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/create_dir.sh | bash -sh

#下载tar包-解压######################################################################
mkdir -p /data/software && cd /data/software
wget http://js.funet8.com/centos_software/php7.3-software.tar.gz
tar -zxf php7.3-software.tar.gz

#升级libzip-devel版本######################################################################
yum remove -y libzip
cd /data/software/php7.3-software/libzip-1.2.0
./configure
make && make install

echo '/usr/local/lib64
/usr/local/lib
/usr/lib
/usr/lib64'>>/etc/ld.so.conf
ldconfig -v
cp /usr/local/lib/libzip/include/zipconf.h /usr/local/include/zipconf.h


#编译安装php7.3######################################################################
function install_php7 {

		cd /data/software/php7.3-software/php-7.3.7

		./configure \
		--prefix=${PHP_DIR} \
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
			echo 'php安装错误！'
			exit 1
	fi
	}
#配置环境变量######################################################################
function config_profile {
	echo 'export PATH=$PATH:/usr/local/php/bin'>>/etc/profile
	source /etc/profile
	php -v
}

#安装php扩展######################################################################
function install_kuozhan {
	#安装SSL库
	cd /data/software/php7.3-software/openssl-1.0.1j/
	./config
	make && make install
	#安装memcache扩展
	yum install -y libmemcached libmemcached-devel
	cd /data/software/php7.3-software/libmemcached-1.0.16
	./configure -prefix=/usr/local/libmemcached -with-memcached 
	make && make install
	cd /data/software/php7.3-software/php-memcached/
	/usr/local/php/bin/phpize
	./configure -enable-memcached -with-php-config=/usr/local/php/bin/php-config -with-zlib-dir -with-libmemcached-dir=/usr/local/libmemcached -prefix=/usr/local/phpmemcached  --disable-memcached-sasl
	make  -j4
	make install
	#安装phpredis扩展
	cd /data/software/php7.3-software/phpredis
	/usr/local/php/bin/phpize
	./configure --with-php-config=/usr/local/php/bin/php-config
	make && make install
	
	systemctl restart php-fpm
	php -m|grep redis
	php -m|grep memcache
}

#配置php7.3######################################################################
function config_php {
	cd /etc/
	wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_PHP7.3_PHPFPM/conf/php.ini
	wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_PHP7.3_PHPFPM/conf/php-fpm.conf
	cd /usr/lib/systemd/system/
	wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_PHP7.3_PHPFPM/conf/php-fpm.service

	#加入白名单
	iptables -A INPUT -p tcp --dport ${PHP_PORT} -j ACCEPT
	service iptables save
	systemctl restart iptables
	
	#开机启动	
	systemctl enable php-fpm.service
	systemctl restart php-fpm.service
	ln /usr/local/php/sbin/php-fpm /usr/local/sbin # 软链接php-fpm
	
}
	
install_php7
config_profile
install_kuozhan
config_php



