#!/bin/bash

# -------------------------------------------------------------------------------
# Filename:    create_dir.sh
# Revision:    1.0
# Date:        2018-05-17
# Author:      star
# Email:       liuxing007xing@163.com
# Website:     www.funet8.com
# Description: CentOS6.x
# Notes:       需要切换到root运行,版本针对64位系统，操作系统为CentOS6.3
# -------------------------------------------------------------------------------
# License:     GPL
# -------------------------------------------------------------------------------

#目录设置############################################################################
#创建网站相关目录####################################################################

	mkdir /home/data
	ln -s /home/data /data
	mkdir /data/wwwroot
	mkdir -p /data/wwwroot/{web,log,mysql_log}
	mkdir -p /home/data/wwwroot/log/other/
	
	mkdir /data/conf
	mkdir /data/conf/{sites-available,shell}
	mkdir /home/data/backup
	mkdir /home/data/software
	
#执行退出，后面的操作在相应的脚本中执行################################################
echo 'Create Dir success!!! '