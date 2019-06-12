#!/bin/bash
 
# -------------------------------------------------------------------------------
# Filename:    CentOS7.x_system_init_shell_mini.sh
# Revision:    1.0
# Date:        2018/11/16
# Author:      star
# Email:       liuxing007xing@163.com
# Description: CentOS7.x系统新安装后的初始设置
# 删除一些影响较大的配置
# -------------------------------------------------------------------------------
# License:     GPL
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# 注意事项:    
# 1、先ping百度域名，看能否解析域名 
# 
# -------------------------------------------------------------------------------

HOSTNAME="node2"
SSH_PROT="60920"

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
version=`more /etc/redhat-release |awk '{print $4}'|awk -F'.' '{print $1}'`
if [ $version != 7 ];then
echo "this script is only for CentOS 7 !"
exit 1
fi
 
cat << EOF
+---------------------------------------+
|   your system is CentOS 7 x86_64      |
|        start optimizing.......        |
+---------------------------------------+
EOF

# 修改主机名
hostnamectl set-hostname ${HOSTNAME}

#1.安装wget等常用工具####################################################################
yum -y install wget sed tar unzip lrzsz sudo
sleep 3

#2.将默认源换为阿里云
mv /etc/yum.repos.d/CentOS-Base.repo{,.bak}
wget http://mirrors.aliyun.com/repo/Centos-7.repo -O /etc/yum.repos.d/CentOS-Base.repo
	

#3.安装常用类库##########################################################################
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel nss_ldap openldap openldap-devel  openldap-clients libxslt-devel libevent-devel libtool-ltdl bison libtool vim-enhanced
echo -e "安装常用类库安装完成" 

#4.rc.local添加执行权限##########################################################################
chmod +x /etc/rc.d/rc.local


#5.centos7.0 没有netstat 和 ifconfig命令问题
yum install -y net-tools

#6.增加第三方资源库#######################################################################
#配置yum第三方资源库  主要作用是官方没有的包 会去第三方查找相关的包
#增加epel源
if [ ! -e /etc/yum.repos.d/epel.repo ] 
then 
	rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	echo -e "Install EPEL source ${DONE}." 
fi

#7.关闭SELINUX###########################################################################
sed -i  '/^SELINUX/s/enforcing/disabled/g' /etc/selinux/config
setenforce 0

#8.设置UTF-8##################################################################
#centos7将文件改为 vi /etc/locale.conf
if cat /etc/locale.conf |awk -F: '{print $1}'|grep 'en_US.UTF-8'  2>&1 >/dev/null 
then 
	echo -e "Lang has been \e[0;32m\033[1madded\e[m." 
else 
	sed -i s/LANG=.*$/LANG=\"en_US.UTF-8\"/  /etc/locale.conf
	echo -e "Set LANG en_US.UTF-8 ${DONE}." 
fi 

#9.系统时间设置和定时任务##########################################################################
rm -rf /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime    
yum install -y ntp crontabs
ntpdate -d us.pool.ntp.org
ntpdate -d 2.cn.pool.ntp.org # 再次同步
ntpdate -d 210.72.145.44 # 再次同步
hwclock --systohc # 同步到硬件时钟
# 将系统时间同步写入crontab，每天零时自动校时。	
# 时间同步服务器参考：http://www.pool.ntp.org/zone/cn
echo "*/5 * * * * root /usr/sbin/ntpdate 2.cn.pool.ntp.org &> /dev/null" >> /etc/crontab
systemctl restart  crond.service
# 通过date -R可以看到，时区已经更改成东8区了(+8)
date -R
echo -e "Time ntpdate set ${DONE}." 

sed -i "s/#Port 22/ListenAddress 0.0.0.0:60920/" /etc/ssh/sshd_config
systemctl restart sshd

#10.关闭系统自带防火墙，安装iptables
systemctl stop firewalld.service 		#停止firewall
systemctl disable firewalld.service 	#禁止firewall开机启动
#firewall-cmd --state 					#查看默认防火墙状态（关闭后显示notrunning，开启后显示running）
yum install -y iptables-services
#防火墙初始化
#查看iptables现有规则
iptables -L -n
#先允许所有,不然有可能会杯具
iptables -P INPUT ACCEPT
#清空所有默认规则
iptables -F
#清空所有自定义规则
iptables -X
#所有计数器归0
iptables -Z
#允许来自于lo接口的数据包(本地访问)
iptables -A INPUT -i lo -j ACCEPT
#开放22端口
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
#开放21端口(FTP)
iptables -A INPUT -p tcp --dport 21 -j ACCEPT
#开放80端口(HTTP)
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#开放443端口(HTTPS)
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
#开放ssh端口
iptables -A INPUT -p tcp --dport ${SSH_PROT} -j ACCEPT
#允许ping
iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
#允许接受本机请求之后的返回数据 RELATED,是为FTP设置的
iptables -A INPUT -m state --state  RELATED,ESTABLISHED -j ACCEPT
#其他入站一律丢弃
#iptables -P INPUT DROP
#所有出站一律绿灯
#iptables -P OUTPUT ACCEPT
#所有转发一律丢弃
#iptables -P FORWARD DROP

service iptables save
systemctl restart iptables.service #最后重启防火墙使配置生效
systemctl enable iptables.service #设置防火墙开机启动

#11.重建缓存、系统升级#################################################################################
yum -y install yum-fastestmirror       #安装另外一个自动升级工具，这个工具保证从就近服务器下载安装包
yum clean all     					   # 清除缓存的软件包及旧headers
yum makecache     					   #将服务器上的软件包信息缓存到本地,以提高搜索安装软件的速度
yum -y update                          #系统升级


#重启系统
init 6