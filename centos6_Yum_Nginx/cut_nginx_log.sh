#!/bin/bash

#添加自动执行，安装方法
#vi /etc/crontab
#输入：
#00 00 * * * root /data/conf/shell/cut_nginx_log.sh >> /data/wwwroot/log/cut_nginx_log.log

#这样每天0点整就会自动开始切割脚本

#set the path to nginx log files
#设置nginx日志文件目录路径
log_files_path="/data/wwwroot/log/"
#把nginx备份分区路径赋给nginx_oldlog_path变量
nginx_old_log_path="/data/wwwroot/nginx_old_log/"
#日志文件将会存放到/data/wwwroot/log/年/月/日志文件名_年月日.log
log_files_dir=${nginx_old_log_path}$(date -d "yesterday" +"%Y")/$(date -d "yesterday" +"%m")
#set nginx log files you want to cut
#设置要切割的日志的名字，如果日志目录下面的日志文件名为jayshao.com.log，则填写jayshao.com，每个日志名用空格分隔（已优化为自动生成）
log_files_name=`/bin/ls $log_files_path`
#set the path to nginx.
#设置nginx文件的位置
#nginx_sbin="/usr/sbin/nginx"
#nginx_sbin="/data/conf/nginx/sbin/nginx"
#nginx_sbin="/usr/bin/docker"
#Set how long you want to save
#设置日志保存的时间，天
save_days=30

############################################
#Please do not modify the following script #
############################################
mkdir -p $log_files_dir

#cut nginx log files
for log_name in $log_files_name;do
mv ${log_files_path}${log_name} ${log_files_dir}/${log_name}_$(date -d "yesterday" +"%Y%m%d").log
done

#delete 30 days ago nginx log files
find $nginx_old_log_path -mtime +$save_days -exec rm -rf {} \; 

#重启docker
#$nginx_sbin restart ghssNginx
#$nginx_sbin restart ghssFpm

systemctl restart docker
#/etc/init.d/httpd reload

# 如果/data/wwwroot/log/other 不存在则建立这个目录
if [ ! -d "/data/wwwroot/log/other" ];then
	mkdir -p /data/wwwroot/log/other
fi

