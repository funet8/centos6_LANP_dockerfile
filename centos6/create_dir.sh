#!/bin/bash
####运行dockerfile先执行创建目录
mkdir /home/data
ln -s /home/data /data
mkdir /www
mkdir /data/wwwroot
ln -s /data/wwwroot /www/
mkdir -p /data/wwwroot/{web,log,git}
mkdir -p /data/wwwroot/log/{web,other}
mkdir /data/conf
mkdir /data/conf/{sites-available,shell}	
mkdir /backup
ln -s /backup /data/