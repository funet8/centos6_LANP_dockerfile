#!/bin/bash
###########################################################
#名字：	CentOS6_7_Vsftp_Add_User.sh
#功能：	创建Vsftp用户，并且赋予目录权限
#作者：	star
#邮件：	star@funet8.com
#时间：      2019/05/16
#Version 1.0
#20190516修改记录：
# shell脚本初始化
#说明：必须安装vsftpd服务
###########################################################
#1.检查是否是root用户######################################################################
if [ $(id -u) != "0" ]; then  
    echo "Error: You must be root to run this script, please use root to run"  
    exit 1
fi
#2.检查是否安装vsftpd软件######################################################################
isVsftpd=`rpm -qa vsftpd`
if [[ $isVsftpd =~ 'vsftpd' ]];then
	echo 'vsftpd服务已安装，进入下一步!'
	sleep 1;
else
	echo 'vsftpd服务未安装，退出程序！'
	exit 1
fi
######################################################################
#指定用户名和密码、项目目录
UserName="yxkj_limingming"
UserPasswd="lmNmX12WsS7fsemWr77UN"
UserPath="c.apk.ace-hand.com"
ServerIP="`curl icanhazip.com`"
######################################################################
echo "$UserName" 	>> /etc/vsftpd/virtusers
echo "$UserPasswd" 	>> /etc/vsftpd/virtusers
echo "$UserName" 	>> /etc/vsftpd/chroot_list
db_load -T -t hash -f /etc/vsftpd/virtusers /etc/vsftpd/virtusers.db
cp /data/conf/vsftpd/vconf/yxkj_web /data/conf/vsftpd/vconf/$UserName
sed -i "s/\/data\/wwwroot\/ftp\/yxkj_web/\/data\/wwwroot\/ftp\/$UserName/g" /data/conf/vsftpd/vconf/$UserName
mkdir -p /data/wwwroot/ftp/$UserName/$UserPath
chown www.www -R /data/wwwroot/ftp/$UserName
######################################################################
function SYSTEM6(){
	echo "##vsftpd-user-$UserName##" >> /etc/fstab
	echo "/data/wwwroot/web/$UserPath  /data/wwwroot/ftp/$UserName/$UserPath	none	rw,bind	0	0">> /etc/fstab
	mount -a
	service vsftpd restart
}
function SYSTEM7(){
	mount --bind /data/wwwroot/web/$UserPath /data/wwwroot/ftp/$UserName/$UserPath
	echo "##vsftpd-user-$UserName##" >> /etc/rc.local
	echo "mount --bind /data/wwwroot/web/$UserPath /data/wwwroot/ftp/$UserName/$UserPath" >> /etc/rc.local
	systemctl restart vsftpd
}
######################################################################
#3.检查centos版本，并且执行相关函数
version6=`more /etc/redhat-release |awk '{print substr($3,1,1)}'`
if [ $version6 = 6 ];then
	echo "System is CentOS 6 !"
	SYSTEM6	
	echo "FTP账户添加成功。"
	echo "服务器：$ServerIP:62920"
	echo "FTP账户：$UserName"
	echo "FTP密码：$UserPasswd"	
fi 
version7=`more /etc/redhat-release |awk '{print substr($4,1,1)}'`
if [ $version7 = 7 ];then
	echo "System is CentOS 7 !"
	SYSTEM7
	echo "FTP账户添加成功。"	
	echo "服务器：$ServerIP:62920"
	echo "FTP账户：$UserName"
	echo "FTP密码：$UserPasswd"	
fi



