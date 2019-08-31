#!/bin/bash
# Filename:    CentOS7.x_system_init_shell_mini.sh
# wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/CentOS7.x_system_init_shell_mini.sh
# Revision:    1.0
# Date:        2019/08/31
# Author:      star
# Email:       liuxing007xing@163.com
# Description: CentOS7.x系统新安装后的初始设置
# 删除一些影响较大的配置
# 2019/08/31 新增功能
# -------------------------------------------------------------------------------
# 注意事项:    
# 1、先ping百度域名，看能否解析域名、修改主机名和ssh端口
# 主要功能:
#	1.修改主机名
#   2.安装wget、tar、lrzsz等常用工具
#   3.将默认源换为阿里云
#   4.安装常用类库
#   5.rc.local添加执行权限
#   6.安装 net-tools
#   7.增加第三方资源库
#   8.关闭SELINUX
#   9.设置UTF-8
#   10.系统时间设置和定时任务
#   11.修改主机SSH端口
#   12.删除MySQL、shell历史记录
#   13.隐藏服务器系统信息
#   14.优化Linux内核参数
#   15. CentOS系统优化【/etc/profile】
#   16.关闭系统自带firewalld防火墙，安装iptables
#   17.安装yum-fastestmirror
#   18.重建缓存、系统升级
#   19.重启系统    
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

#1.修改主机名
hostnamectl set-hostname ${HOSTNAME}

#2.安装wget等常用工具
yum -y install wget sed tar unzip lrzsz sudo
sleep 3

#3.将默认源换为阿里云
mv /etc/yum.repos.d/CentOS-Base.repo{,.bak}
wget http://mirrors.aliyun.com/repo/Centos-7.repo -O /etc/yum.repos.d/CentOS-Base.repo
	
#4.安装常用类库
yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel nss_ldap openldap openldap-devel  openldap-clients libxslt-devel libevent-devel libtool-ltdl bison libtool vim-enhanced
echo -e "安装常用类库安装完成" 

#5.rc.local添加执行权限
chmod +x /etc/rc.d/rc.local


#6.centos7.0 没有netstat 和 ifconfig命令问题
yum install -y net-tools

#7.增加第三方资源库
#配置yum第三方资源库  主要作用是官方没有的包 会去第三方查找相关的包
#增加epel源
if [ ! -e /etc/yum.repos.d/epel.repo ] 
then 
	rpm -ivh http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
	echo -e "Install EPEL source ${DONE}." 
fi

#8.关闭SELINUX###########################################################################
sed -i  '/^SELINUX/s/enforcing/disabled/g' /etc/selinux/config
setenforce 0

#9.设置UTF-8
#centos7将文件改为 vi /etc/locale.conf
if cat /etc/locale.conf |awk -F: '{print $1}'|grep 'en_US.UTF-8'  2>&1 >/dev/null 
then 
	echo -e "Lang has been \e[0;32m\033[1madded\e[m." 
else 
	sed -i s/LANG=.*$/LANG=\"en_US.UTF-8\"/  /etc/locale.conf
	echo -e "Set LANG en_US.UTF-8 ${DONE}." 
fi 

#10.系统时间设置和定时任务
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

#11.修改主机SSH端口
sed -i "s/#Port 22/ListenAddress 0.0.0.0:${SSH_PROT}/" /etc/ssh/sshd_config
systemctl restart sshd

#12.删除MySQL、shell历史记录
#用户登陆数据库后执行的SQL命令也会被MySQL记录在用户目录的.mysql_history文件里。
#如果数据库用户用SQL语句修改了数据库密码，也会因.mysql_history文件而泄漏。
#所以我们在shell登陆及备份的时候不要在-p后直接加密码，而是在提示后再输入数据库密码。
#另外这两个文件我们也应该不让它记录我们的操作，以防万一。
cd
if [ ! -e .bash_history.bak  ] 
then 
	cd
	cp .bash_history  .bash_history.bak  #备份
	if [ ! -e .mysql_history  ]; then  
		touch .mysql_history
	fi
	cp .mysql_history .mysql_history.bak   
	rm .bash_history .mysql_history
	ln -s /dev/null .bash_history
	ln -s /dev/null .mysql_history
fi

#13.隐藏服务器系统信息
#它会告诉你该linux发行版的名称、版本、内核版本、服务器的名称。
#为了不让这些默认的信息泄露出来，我们要进行下面的操作，让它只显示一个"login:"提示符。
#删除/etc/issue和/etc/issue.net这两个文件，或者把这2个文件改名，效果是一样的。
if [ ! -e /etc/issue.bak ] 
then 
	mv /etc/issue /etc/issue.bak
	mv /etc/issue.net /etc/issue.net.bak
fi

#14.优化Linux内核参数
if [ ! -e /etc/sysctl.conf.bak ] 
then 
	cp /etc/sysctl.conf  /etc/sysctl.conf.bak
	echo '# 限定SYN队列的长度
net.ipv4.tcp_max_syn_backlog = 65536
#禁止ip转发功能
net.ipv4.ip_forward = 0  
#禁止转发重定向报文
net.ipv4.conf.all.send_redirects = 0  
net.ipv4.conf.default.send_redirects = 0
#打开反向路径过滤功能，防止ip地址欺骗
net.ipv4.conf.all.rp_filter = 1  
net.ipv4.conf.default.rp_filter = 1
#禁止包含源路由的ip包
net.ipv4.conf.all.accept_source_route = 0  
net.ipv4.conf.default.accept_source_route = 0
#禁止接收路由重定向报文，防止路由表被恶意更改
net.ipv4.conf.all.accept_redirects = 0  
net.ipv4.conf.default.accept_redirects = 0
#只接受来自网关的“重定向”icmp报文
net.ipv4.conf.all.secure_redirects = 0  
net.ipv4.conf.default.secure_redirects = 0
# 禁止ICMP重定向
net.ipv4.icmp_echo_ignore_broadcasts = 1  
net.core.netdev_max_backlog =  32768
net.core.somaxconn = 32768
net.core.wmem_default = 8388608
net.core.rmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_tw_recycle = 1
#net.ipv4.tcp_tw_len = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_mem = 94500000 915000000 927000000
net.ipv4.tcp_max_orphans = 3276800
#net.ipv4.tcp_fin_timeout = 30
#net.ipv4.tcp_keepalive_time = 120
#（表示用于向外连接的端口范围。缺省情况下很小：32768到61000  #注意：这里不要将最低值设的太低，否则可能会占用掉正常的端口！ ）
net.ipv4.ip_local_port_range = 10024  65535 
fs.file-max = 6553560' >> /etc/sysctl.conf  
	/sbin/sysctl -p   # 使配置立即生效	
	chmod 600 /etc/sysctl.conf # 更改文件属性
fi

#15. CentOS系统优化
if [ ! -e /etc/profile.bak2 ] 
then 
	cp /etc/profile /etc/profile.bak2
	echo 'ulimit -c unlimited
ulimit -s unlimited
ulimit -SHn 65535' >> /etc/profile
	source  /etc/profile    #使配置立即生效
	ulimit -a    #显示当前的各种用户进程限制
fi

#16.关闭系统自带firewalld防火墙，安装iptables
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
iptables -P INPUT DROP
#所有出站一律绿灯
iptables -P OUTPUT ACCEPT
#所有转发一律丢弃
iptables -P FORWARD DROP

service iptables save
systemctl restart iptables.service #最后重启防火墙使配置生效
systemctl enable iptables.service #设置防火墙开机启动

#17.安装yum-fastestmirror
yum -y install yum-fastestmirror

#18.重建缓存、系统升级
yum clean all	# 清除缓存的软件包及旧headers
yum makecache	
yum -y update

#19.重启系统
init 6