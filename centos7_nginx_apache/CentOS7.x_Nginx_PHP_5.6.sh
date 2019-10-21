#!/bin/bash
 
# -------------------------------------------------------------------------------
# Filename:    CentOS7.x_Nginx_PHP_5.6.sh
# 	系统环境： centos7.x
#	nginx 		yum安装
#	httpd		yum安装apache2.4
#	php			yun安装5.6版本
# wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_nginx_apache/CentOS7.x_Nginx_PHP_5.6.sh
# sh CentOS7.x_Nginx_PHP_5.6.sh
# -------------------------------------------------------------------------------

# -------------------------------------------------------------------------------
#
#作者：funet8@163.com
#20190808

#解锁系统文件#########################################################################
chattr -i /etc/passwd 
chattr -i /etc/group
chattr -i /etc/shadow
chattr -i /etc/gshadow
chattr -i /etc/services
#如果已安装Apache和PHP，则卸载########################################################
yum -y remove httpd* php*  mysql
#更新软件库###########################################################################
yum -y update

#安装apache###########################################################################
yum -y install httpd
systemctl enable httpd.service

#安装相关
yum -y install openssl openssl-devel gcc wget

#####################################################################################
#目录设置############################################################################
#创建网站相关目录####################################################################
mkdir /home/data
ln -s /home/data /data
mkdir /www
mkdir /data/wwwroot
ln -s /data/wwwroot /www/
mkdir -p /data/wwwroot/{web,log}
mkdir /data/conf/
mkdir /data/conf/{sites-available,shell}	
mkdir /backup
ln -s /backup /data/
mkdir -p /home/data/software/

#yun安装nginx######################################################################
yum -y install nginx
systemctl enable nginx.service

yum remove -y php.x86_64 php-cli.x86_64 php-common.x86_64 php-gd.x86_64 php-ldap.x86_64 php-mbstring.x86_64 php-mcrypt.x86_64 php-mysql.x86_64 php-pdo.x86_64

#配置epel源
yum install -y epel-release
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo

yum install -y m4 autoconf

#配置remi源
rpm -ivh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
# yum list --enablerepo=remi --enablerepo=remi-php56 | grep php
#安装php5.6.x
yum install -y --enablerepo=remi --enablerepo=remi-php56 php php-opcache php-devel php-mbstring php-mcrypt php-mysqlnd php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof

#为PHP5取得MySQL支持和安装PHP常用库###################################################
yum -y install php-mysql php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-mcrypt php-bcmath php-mhash libmcrypt --enablerepo=remi-php56

#配置文件目录设置######################################################################
#移动nginx配置文件
cp -p /etc/nginx/nginx.conf  /etc/nginx/nginx.conf.bak
rm -rf /etc/nginx/nginx.conf
cd /data/conf/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_nginx_apache/nginx.conf
ln -s /data/conf/nginx.conf /etc/nginx/
echo "nginx.conf move success"



#移动apache配置文件
cp -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak
rm -rf /etc/httpd/conf/httpd.conf
cd /data/conf/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_nginx_apache/httpd.conf
ln -s /data/conf/httpd.conf /etc/httpd/conf/
echo "httpd.conf move success"


#移动php配置文件
cp -p /etc/php.ini /etc/php.ini.bak
rm -f /etc/php.ini
cd /data/conf/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_nginx_apache/php.ini
ln -s /data/conf/php.ini /etc/
echo "php.ini move success"

#站点配置
cd /data/conf/sites-available/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_nginx_apache/apache_main.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos7_nginx_apache/nginx_main.conf

#添加www组和www用户####################################################################
groupadd www
useradd -g www www
#设置目录权限##########################################################################
chown -R www:www /data/wwwroot/web

#开启防火墙
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp --dport 8081 -j ACCEPT
iptables -A INPUT -p tcp --dport 8082 -j ACCEPT
iptables -A INPUT -p tcp --dport 8083 -j ACCEPT
iptables -A INPUT -p tcp --dport 8084 -j ACCEPT
iptables -A INPUT -p tcp --dport 8085 -j ACCEPT
service iptables save
systemctl restart iptables.service


#安装memcache扩展
yum install -y libmemcached libmemcached-devel
cd /data/software/
wget http://js.funet8.com/centos_software/libmemcached-1.0.16.tar.gz
tar -zxf libmemcached-1.0.16.tar.gz
cd /data/software/libmemcached-1.0.16
./configure -prefix=/usr/local/libmemcached -with-memcached 
make && make install

cd /data/software/
wget http://pecl.php.net/get/memcache-2.2.6.tgz
#wget http://js.funet8.com/centos_software/memcache-2.2.6.tgz
tar zxvf memcache-2.2.6.tgz
cd /data/software/memcache-2.2.6
/usr/bin/phpize
./configure --with-php-config=/usr/bin/php-config

make && make install
#/usr/lib64/php/modules/

#安装phpredis扩展
cd /data/software/
wget http://js.funet8.com/centos_software/phpredis.tar.gz
tar -zxf phpredis.tar.gz
cd /data/software/phpredis
/usr/bin/phpize
./configure --with-php-config=/usr/bin/php-config
make && make install

#安装zip扩展
#cd /data/software/
#wget http://js.funet8.com/centos_software/zip-1.13.5.tgz
#tar -zxf zip-1.13.5.tgz
#cd /data/software/zip-1.13.5
#/usr/bin/phpize
#./configure --with-php-config=/usr/bin/php-config
#make && make install


php -m|grep redis
php -m|grep memcache

chmod 777 -R /var/lib/php

rm -rf /usr/share/httpd/icons/*
#重启nginx和apche服务
systemctl restart httpd.service
systemctl restart nginx.service

#系统文件加锁
#chattr +i /etc/passwd        
#chattr +i /etc/shadow
#chattr +i /etc/gshadow
#chattr +i /etc/group
#chattr +i /etc/services
