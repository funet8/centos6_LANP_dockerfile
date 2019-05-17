#!/bin/bash
####运行dockerfile先执行创建目录
mkdir /home/data
ln -s /home/data /data
mkdir /www
mkdir /data/wwwroot
ln -s /data/wwwroot /www/
mkdir -p /data/wwwroot/{web,log}
mkdir -p /data/wwwroot/log/{web,other}
mkdir /data/conf
mkdir /data/conf/{sites-available,shell}
mkdir /backup
ln -s /backup /data/

cp -r conf/nginx.conf /data/conf/nginx.conf
cp -r conf/nginx_main.conf /data/conf/sites-available/nginx_main.conf
cp -r conf/apache_main.conf /data/conf/sites-available/apache_main.conf
cp -r conf/httpd.conf /data/conf/httpd.conf
cp -r conf/php.ini /data/conf/php.ini