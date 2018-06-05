#!/bin/bash
 
# -------------------------------------------------------------------------------
# Filename:    CentOS6_7_intall_docker.sh
# Revision:    1.0
# Date:        2017/11/28
# Author:      star
# Email:       liuxing007xing@163.com
# Description: 安装docker
# Notes:       需要切换到root运行,版本针对64位系统，操作系统为CentOS6或者centos7
#            
# -------------------------------------------------------------------------------
# Copyright:   2017 (c) star
# -------------------------------------------------------------------------------


#检查是否是root用户######################################################################
if [ $(id -u) != "0" ]; then  
    echo "Error: You must be root to run this script, please use root to run"  
    exit 1  
fi
#系统版本检测############################################################################
platform=`uname -i`
if [ $platform != "x86_64" ];then 
echo "this script is only for 64bit Operating System !"
exit 1
fi
echo "the platform is ok"
version6=`more /etc/redhat-release |awk '{print substr($3,1,1)}'`
if [ $version6 = 6 ];then
echo "System is CentOS 6 !"
SYSTEM="CentOS6"
fi
version7=`more /etc/redhat-release |awk '{print substr($4,1,1)}'`
if [ $version7 = 7 ];then
echo "System is CentOS 7 !"
SYSTEM="CentOS7"
fi

####centos6
if [ $SYSTEM = 'CentOS6' ]; then
	######安装docker
	yum -y update
	yum install http://mirrors.yun-idc.com/epel/6/i386/epel-release-6-8.noarch.rpm 
	yum install -y docker-io
	chkconfig docker on 
	service docker start	
	
	######修改docker默认存储位置
	mkdir /home/data
	ln -s /home/data /data
	mkdir -p /data/docker/images
	service docker stop
	cd /var/lib
	cp -rf docker docker.bak
	mv /var/lib/docker /data/docker/images
	ln -s /data/docker/images/docker /var/lib/docker
	service docker restart
	chkconfig docker on
	######Docker 中国官方镜像加速	
		cat > /etc/docker/daemon.json << EOFI
				{"registry-mirrors": ["https://registry.docker-cn.com"]}
EOFI
fi

####centos7
if [ $SYSTEM = 'CentOS7' ]; then
	######安装docker
	yum install -y docker
	systemctl enable docker.service
	
	######修改docker默认存储位置
	mkdir /home/data
	ln -s /home/data /data
	mkdir -p /data/docker/images
	systemctl stop docker.service
	cd /var/lib
	cp -rf docker docker.bak
	mv /var/lib/docker /data/docker/images
	ln -s /data/docker/images/docker /var/lib/docker
	######Docker 中国官方镜像加速	
		cat > /etc/docker/daemon.json << EOFI
{"registry-mirrors": ["https://registry.docker-cn.com"]}
EOFI
	systemctl restart docker.service
	systemctl enable docker.service
fi
