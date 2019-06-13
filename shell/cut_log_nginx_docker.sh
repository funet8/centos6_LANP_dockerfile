#!/bin/bash

#添加自动执行，安装方法
#vi /etc/crontab
#输入：
#00 00 * * * root /data/conf/shell/cut_log_nginx_docker.sh

###docker的名字
Nginx_Name="nginx"
Httpd_Name="centos6_httpd_php56"

#设置日志保存的时间，天
save_days=60

#set the path to nginx log files
log_files_path="/data/wwwroot/log/"
nginx_old_log_path="/data/wwwroot/nginx_old_log/"
log_files_dir=${nginx_old_log_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")
log_files_name=`/bin/ls $log_files_path`

#设置nginx文件的位置
#nginx_sbin="/usr/sbin/nginx"
#nginx_sbin="/data/conf/nginx/sbin/nginx"


mkdir -p $log_files_dir
#移动日志
for log_name in $log_files_name;do
	mv ${log_files_path}${log_name} ${log_files_dir}/${log_name}_$(date -d "yesterday" +"%Y%m%d").log
done

#删除过期日志
find $nginx_old_log_path -mtime +$save_days -exec rm -rf {} \; 

#重启服务
docker restart $Nginx_Name
docker restart $Httpd_Name
#docker restart myFpm

#/etc/init.d/httpd reload
#/etc/init.d/nginx reload

# 如果/data/wwwroot/log/other 不存在则建立这个目录
if [ ! -d "/data/wwwroot/log/other" ];then
	mkdir -p /data/wwwroot/log/other
fi

