#!/bin/bash
 
# -------------------------------------------------------------------------------
# Filename:    CentOS6.x_system_init_shell.sh
# Revision:    1.6
# Date:        2016/1/22
# Author:      star
# Email:       liuxing007xing@163.com
# Description: CentOS6.x系统新安装后的初始设置
# -------------------------------------------------------------------------------
# License:     GPL
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# 注意事项:    
# 1、先ping百度域名，看能否解析域名 
# 
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
version=`more /etc/redhat-release |awk '{print substr($3,1,1)}'`
if [ $version != 6 ];then
echo "this script is only for CentOS 6 !"
exit 1
fi
 
cat << EOF
+---------------------------------------+
|   your system is CentOS 6 x86_64      |
|        start optimizing.......        |
+---------------------------------------+
EOF

#变量设置###############################################################################
#default users who are administrators 
ADMIN_USER="test_yxkj" 
#set the default password for administrators,it will be changed when user first login
DEFAULT_PASSWD='123456liuxing'     
#管理员电子邮箱
email=liuxing007xing@163.com #yourname@yourserver.com
#ssh默认端口号
SSH_PORT='60920'
#SRV_TEMP keep result from chkconfig command 
SRV_TEMP="/tmp/chkconfig_list.tmp"   
#定义所要删除的用户
USER_DEL="adm lp sync shutdown halt mail news uucp operator games gopher ftp"
#定义所要删除的用户组
GROUP_DEL="adm lp mail news uucp games dip pppusers popusers slipusers"
#定义所要保留的服务，其它服务将被停止，可以根据实际服务器应用更改
#SRV_ON="crond irqbalance microcode_ctl network sshd syslog"     #add services to this VARIABLES if you want to start them  when linux start 
SRV_ON="crond irqbalance network sshd rsyslog iptables"

# the libs files will be used later 
INSTALL_LIBS="gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5-devel libidn libidn-devel openssl openssl-devel nss_ldap openldap openldap-devel  openldap-clients libxslt-devel libevent-devel libtool-ltdl bison libtool vim-enhanced" 
# the softs will be used later   
INSTALL_SOFTS="wget sed tar unzip lrzsz sudo"    
DONE="\e[0;32m\033[1mdone\e[m" 
#远程连接公钥Publick Key内容
publick_Key='ssh-dss AAAAB3NzaC1kc3MAAAEBAJCKH5T2h1o5+LE7GH2hQ8Vqar8On6iYGQZHJIPgKxVKH1PUy789093DJO5NqAsp/VBu1ZD61lYs55E/UTB7Mv6VCLvA2ChBja47FhojNk2iWkOUHH6pXCYRVkSDLw8+EHK3dWvg8GenznqhUn37wHhEhcNG2DSoorZBfhwIzW5yk/pKpCHkWFBii6QUUM3E9Mb3bbuAliq+qNMRXNJGQozLYH5ZEwtLjh1hYKH8NBItIzoAm2zYrDRE7uZXWPVpHedI1FB91wdtN2lEzVn1oFujfOSWGUQrycf+tW+s0EQNkJ/vL+0BqsHCuYNNs70v/VXjGYLo7atQOgraQq4EyYEAAAAVAI6dMBHCnjO8UaXeVHKOSPbmz0kPAAABABunT8yJB7T4E8uHk3B3yiFp1RPtkB06JGIf9g2WnfMqCsowWiH8Qm+D5ByjsGSXRDTSjp/iThc8/HNT/PrvghzHAUHr0zPb4U83dLShhKohoxOJK9waKDowM0mZGT8tuQVrrNBq4r7cPNtkmqEwhOB2bBrMrej3kWNETlxabEVRizR5a30mIRMzKFlhq6B/OFhGZEtYmeiMQ7eCj9aTOM0HQ1jU8OJrWKTgx5QfF1wiJ9ly8dStkM8FqINchZZmk4zDTIA0UKkLFC8GNZcRbKfVC7ThPHxYMDFnRg6eUI9VoMSJl7J1aRR0WF41upooTDaXBNYuyQyINzgPkBt+JuEAAAEAMiMonzNCFIsuGl2W/xAWSTByjyINgRuB+0NDh5G0KEHNV1QDvb5gp6881O0ddCusHoGeTIrFd9QGoSNzr+0zNPJ/byLLubChrH/02qA/lEkj20DoEWET11NtZUpvbI/EglqAvrXvbBdVDaeMto4xShkLZSvtGEGqK032K1ZPE2P8ByUHhcDvGKRbvt42+dN3hBo9OEYUxlgDUoqd9z84V2memBPBZ3pYPhrcJ5B1tr6jXJYXj201gM4Frw0Ipj0p1PucGWBYp8RWKhKLEnLd4aCz8lpb5IvJv9dubySEsYnWAcT7gu+39+ftITq483UWgbbBXr63cH35szBf3Gy4Jg=='

#先设置网络临时可以访问#################################################################
#ifconfig eth0 192.168.1.122 netmask 255.255.255.0
#route add default gw 192.168.1.1 #添加默认路由
# 配置DNS
#echo 'nameserver 192.168.1.1' >> /etc/resolv.conf

#设置网络##############################################################################
#修改IP地址，以下要修改的内容，在虚拟机和实际物理机中默认内容有所不同，但原理相同，参考修改即可
#sed -i 's/no/yes/g'  /etc/sysconfig/network-scripts/ifcfg-eth0
#echo 'BOOTPROTO=static
#IPADDR=192.168.1.101
#NETMASK=255.255.255.0
#IPV6INIT="no"
#IPV6_AUTOCONF="no"' >> /etc/sysconfig/network-scripts/ifcfg-eth0
#sed -i '/^ONBOOT/s/no/yes/' /etc/sysconfig/network-scripts/ifcfg-eth0
#修改网关
#echo 'GATEWAY=192.168.1.1' >> /etc/sysconfig/network
#修改DNS
#sed -i 's/nameserver/#nameserver/g'  /etc/resolv.conf
#echo 'nameserver 114.114.114.114' >> /etc/resolv.conf
#echo 'nameserver 8.8.8.8' >> /etc/resolv.conf
#重启服务
#service network restart

#安装常用类库##########################################################################
#可以根据需要打开此项，因为我后面的安装都是通过yum安装，所以不需打开此项
#yum -y install ${INSTALL_LIBS} 1>/dev/null 
#echo -e "Install the usual libs ${DONE}." 


#升级系统
yum -y update

#安装wget等常用工具####################################################################
#yum -y install ${INSTALL_SOFTS} 1>/dev/null 此种方式将看不到任何输出，如果网速太慢还以为脚本卡死了
yum -y install ${INSTALL_SOFTS}
sleep 10
echo “install ${INSTALL_SOFTS} ...”
echo -e "Install the usual softs ${DONE}." 
#更新yum源#############################################################################
#将默认源换为163源
if cat /etc/yum.repos.d/CentOS-Base.repo |awk -F: '{print $1}'|grep '163.com'  2>&1 >/dev/null 
then 
	echo -e "163 Yum has been \e[0;32m\033[1madded\e[m." 
else 
	mv /etc/yum.repos.d/CentOS-Base.repo{,.bak}
	wget http://mirrors.163.com/.help/CentOS6-Base-163.repo -O /etc/yum.repos.d/CentOS-Base.repo
	echo -e "Install 163 source ${DONE}." 
fi 
#如果163源安装失败，则安装搜狐源
if cat /etc/yum.repos.d/CentOS-Base.repo |awk -F: '{print $1}'|grep '163.com'  2>&1 >/dev/null 
then 
	echo -e "163 Yum has been \e[0;32m\033[1madded\e[m." 
else 
	mv /etc/yum.repos.d/CentOS-Base.repo{,.bak}
	wget http://mirrors.sohu.com/help/CentOS-Base-sohu.repo -O /etc/yum.repos.d/CentOS-Base.repo
	echo -e "Install sohu source ${DONE}." 
fi 
#增加第三方资源库#######################################################################
#配置yum第三方资源库  主要作用是官方没有的包 会去第三方查找相关的包
#增加epel源
if [ ! -e /etc/yum.repos.d/epel.repo ] 
then 
	rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm 1>/dev/null 
	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
	echo -e "Install EPEL source ${DONE}." 
fi 
#增加RPMforge源---20170921-发现问题404:Couldn't resolve host 'packages.sw.be
#if [ ! -e /etc/yum.repos.d/rpmforge.repo ] 
#then 
	#curl: (6) Couldn't resolve host 'packages.sw.be'
	#rpm -Uvh http://packages.sw.be/rpmforge-release/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm 1>/dev/null 
	
#	rpm -Uvh ftp://195.220.108.108/linux/dag/redhat/el6/en/x86_64/dag/RPMS/rpmforge-release-0.5.2-2.el6.rf.x86_64.rpm  1>/dev/null 
#	rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag
#	echo -e "Install RPMFORGE source ${DONE}." 
#fi 

# 生成缓存
yum clean all
yum makecache

#root邮件的发送#######################################################################
if cat /etc/aliases |awk -F: '{print $2}'|grep $email  2>&1 >/dev/null 
then 
	echo -e "Email has been \e[0;32m\033[1madded\e[m." 
else 
	# 注释掉decode、games、ingress、system、toor、manager
	sed -i 's/^decode:.*/#decode:         root/g
s/^games:.*/#games:          root/g
s/^ingres:.*/#ingres:         root/g
s/^system:.*/#system:         root/g
s/^toor:.*/#toor:           root/g
s/^manager:.*/#manager:        root/' /etc/aliases

	# 确保文件属主为root
	chown root:root /etc/aliases
	echo "root: $email" >> /etc/aliases
	#重建aliasesdb,让刚刚设定的内容生效
	newaliases
	#发送测试邮件给root
	echo test | mail root
	echo -e "Set mail ${DONE}." 
fi 
#建立一般用户##########################################################################
#add default administrators  
for ADMIN in ${ADMIN_USER} 
do 
	if cat /etc/passwd |awk -F: '{print $1}'|grep ${ADMIN}  2>&1 >/dev/null 
	then 
		echo -e "User ${ADMIN} has been \e[0;32m\033[1madded\e[m." 
	else 
		#add new user, change password when user login  
		useradd ${ADMIN} 
		echo "${DEFAULT_PASSWD}" | passwd --stdin ${ADMIN} 2>&1 >/dev/null 
		usermod -L ${ADMIN} #暂将用户的密码冻结，禁止其登录，即更改 /etc/shadow　的密码栏，在其前面加上 ! 
		chage -d 0 ${ADMIN} #强制用户下次登陆时修改密码
		usermod -U ${ADMIN} #暂将用户的密码解冻，即去掉其 /etc/shadow 密码栏前面的 !
		echo -e "Add User \e[0;32m\033[1m${ADMIN}\e[m done."  
 
		#add user to sudoers file  
		echo "${ADMIN}    ALL=(ALL)       ALL" >> /etc/sudoers 
	fi 
done 
#将一般用户 $name 加在管理员组wheel组中，这种方法一般用于同时给多个用户设置sudo特权，少数几个用户则用上面的方法进行单独授权
#usermod -G wheel $name
# 让wheel用户组的所有用户默认拥有sudo特权，这样就省去了频繁修改/etc/sudoer文件的麻烦了，管理起来更方便
# 注意：不要开启“# %wheel        ALL=(ALL)       NOPASSWD: ALL”这一行，这一行的意思是用户不需要输入密码即可拥有root权限，开启这个功能不安全，所以不要开通此项
sed -i '/NOPASSWD/!s/# \(%wheel\)/\1/' /etc/sudoers
#或
#sed -i 's/^#\s*\(%wheel\s*ALL=(ALL)\s*ALL\)/\1/' /etc/sudoers
# 限制用户使用sudo特权执行su命令，即在所搜索的行末加“!/bin/su”
sed -i '/^#\s*\(%wheel\s*ALL=(ALL)\s*ALL\)/s/$/\!\/bin\/su/' /etc/sudoers
	
#关闭不需要的服务######################################################################
#需要保留的服务crond , irqbalance , microcode_ctl ,network , sshd ,syslog
#关闭服务器上非必须的系统服务项，并不适用于所有服务器，比如如果是文件服务器则NFS相关服务则不能关闭
# close all services and set necessary services on  
chkconfig  --list | awk '{print $1}' > ${SRV_TEMP} 
 
# close all services  
while read SERVICE 
do 
	chkconfig --level 345 ${SERVICE} off 1>/dev/null  
 
done < ${SRV_TEMP} 
 
#open necessary services  
for SRVS in ${SRV_ON} 
do 
	if [ -e /etc/init.d/${SRVS} ] 
	then  
		chkconfig --level 345 ${SRVS} on 1>/dev/null 
	else 
		echo -e "Service ${SRVS} is \e[0;31m\033[1mnot exits\e[m." 
	fi 
	 
done 

#check if the server is vmware virtual machine 
chkconfig  --list|grep vmware* 2>&1 /dev/null 
GREP_STATUS=$? 
if [[ ${GREP_STATUS} == 0 ]] 
then 
	chkconfig --level 345 vmware on 1>/dev/null  
	chkconfig --level 345 vmware-USBArbitrator on 1>/dev/null  
	chkconfig --level 345 vmware-workstation-server on 1>/dev/null  
	chkconfig --level 345 vmware-wsx-server on 1>/dev/null  
	chkconfig --level 345 vmamqpd on 1>/dev/null  
fi 
 
echo -e "Stop unnecessary services ${DONE}." 
#关闭SELINUX###########################################################################
if cat /etc/selinux/config |awk -F: '{print $1}'|grep 'SELINUX=disabled'  2>&1 >/dev/null 
then 
	echo -e "SELinux has been \e[0;32m\033[1madded\e[m." 
else 
	sed -i 's/SELINUX=enforcing/#SELINUX=enforcing/g
	s/SELINUXTYPE=targeted/#SELINUXTYPE=targeted/g
	$a\SELINUX=disabled'  /etc/selinux/config

	echo -e "Set SELinux disabled ${DONE}." 
fi 

#shutdown -r now   #重启系统
#set LANG en_US.UTF-8##################################################################
if cat /etc/sysconfig/i18n |awk -F: '{print $1}'|grep 'en_US.UTF-8'  2>&1 >/dev/null 
then 
	echo -e "Lang has been \e[0;32m\033[1madded\e[m." 
else 
	sed -i s/LANG=.*$/LANG=\"en_US.UTF-8\"/  /etc/sysconfig/i18n  
	echo -e "Set LANG en_US.UTF-8 ${DONE}." 
fi 

#系统时间设置##########################################################################
#Set timezone  
if [ ! -L /etc/localtime ] 
then 
	rm -rf /etc/localtime  
	ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime  
	  
	yum install -y ntp crontabs
	# chkconfig ntpd on
	ntpdate -d us.pool.ntp.org
	ntpdate -d 2.cn.pool.ntp.org # 再次同步
	ntpdate -d 210.72.145.44 # 再次同步
	hwclock --systohc # 同步到硬件时钟
	# 将系统时间同步写入crontab，每天零时自动校时。	
	# 时间同步服务器参考：http://www.pool.ntp.org/zone/cn
	echo "0 * * * * root /usr/sbin/ntpdate 2.cn.pool.ntp.org &> /dev/null" >> /etc/crontab
	service crond restart
	# 通过date -R可以看到，时区已经更改成东8区了(+8)
	date -R
	echo -e "Time ntpdate set ${DONE}." 
fi 

#将ctrl alt delete键进行屏蔽###########################################################
#禁止使用Ctrl+Alt+Del快捷键，防止误操作的时候服务器重启
#CentOS 6.x 
if cat /etc/init/control-alt-delete.conf |awk -F: '{print $1}'|grep '#exec /sbin/shutdown'  2>&1 >/dev/null 
then 
	echo -e "Ctrl+Alt+Del has been \e[0;32m\033[1madded\e[m." 
else 
	sed -i 's#start on control-alt-delete#\#start on control-alt-delete#g' /etc/init/control-alt-delete.conf
	sed -i 's#exec /sbin/shutdown -r now#\#exec /sbin/shutdown -r now#g' /etc/init/control-alt-delete.conf
	echo -e "Set ctrl alt delete disabled ${DONE}." 
fi 
# CentOS 5.x :
# 编辑/etc/inittab，注释
# ca::ctrlaltdel:/sbin/shutdown -t3 -r now 
# 保存退出。执行/sbin/init q ，使设置生效。

#禁用IPv6，提升网络性能################################################################
if [ ! -e /etc/modprobe.d/ipv6.conf ] 
then 
	cat > /etc/modprobe.d/ipv6.conf << EOFI
alias net-pf-10 off
options ipv6 disable=1
EOFI

	echo "NETWORKING_IPV6=off" >> /etc/sysconfig/network
	echo -e "Set IPv6 disabled ${DONE}." 
fi 

#配置远程登陆工具openssh###############################################################
if cat /etc/ssh/sshd_config |awk -F: '{print $1}'|grep 'UseDNS no'  2>&1 >/dev/null 
then 
	echo -e "ssh has been \e[0;32m\033[1madded\e[m." 
else 
	#备份文件
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
	#禁止root用户通过ssh远程登陆，本脚本执行完成后再单独运行此命令，防止操作过程中突然中断远程连接
	#sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
	#大家结合自己的情况设置，我这里设置能3个用户同时通过ssh登陆
	sed -i 's/#MaxStartups 10/MaxStartups 5/' /etc/ssh/sshd_config
	#它的作用禁止用户通过密码的方式进行远程登陆保存并退出
	#sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
	#禁用GSSAPI来认证，也禁用DNS反向解析，加快SSH登陆速度
	sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
	sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
	#修改默认登录端口号
	sed -i "s/#Port 22/Port ${SSH_PORT}/" /etc/ssh/sshd_config
	#service sshd restart 或者 /etc/init.d/sshd restart（ssh服务器重启） 
	echo -e "set ssh ${DONE}." 
fi

#配置用户远程登陆的方式################################################################
for ADMIN in ${ADMIN_USER} 
do 	
	if [ ! -e /home/${ADMIN}/.ssh ] 
	then 
		mkdir -p /home/${ADMIN}/.ssh     #建立$name用户公钥存放目录
		#建立公钥文件,并复制附件中建立公钥教程中产生公钥的文本保存到公钥文件中
		echo $publick_Key > /home/${ADMIN}/.ssh/authorized_keys
		
		chown ${ADMIN}.${ADMIN} -R /home/${ADMIN}/    #更改$name用户目录的权限，使得test用户拥有访问.ssh目录和目录下文件的权限
		chmod 700 /home/${ADMIN}/.ssh         #.ssh目录只准$name用户有读写执行的权限
		chmod 600 /home/${ADMIN}/.ssh/authorized_keys  #authorized_keys文件只准$name用户具有读写权限
		
		echo -e "User ${ADMIN} publick_Key Add \e[0;32m\033[1m${ADMIN}\e[m done." 
	fi 	
done 
#/etc/init.d/ssh restart
#用户管理##############################################################################
#删除系统默认创建用户，常用服务器中基本不使用的一些帐号，但是这些帐号常被黑客利用和攻击服务器
if [ ! -e /etc/passwd.bak ] 
then 
	#修改之前先备份
	cp  /etc/passwd  /etc/passwd.bak   
	for i in $USER_DEL ;do 
	userdel $i ;done
	echo -e "Set userdel ${DONE}." 
fi

#删除系统默认创建组
if [ ! -e /etc/group.bak  ] 
then 
	#修改之前先备份
	cp /etc/group   /etc/group.bak   
	for i in $GROUP_DEL ;do 
	groupdel $i ;done
	echo -e "Set groupdel ${DONE}." 
fi

#增加自动注销帐号功能####################################################################
#root用户拥有最高权限，能够在服务器上做任何事情，当我们登陆过后，忘记注销了，将被别人利用，产生重大的安全隐患。应该让系统拥有自动注销功能。
#修改history命令记录
if cat /etc/profile |awk -F: '{print $1}'|grep 'TMOUT=300'  2>&1 >/dev/null 
then 
	echo -e "TMOUT has been \e[0;32m\033[1madded\e[m." 
else 
	sed -i 's/HISTSIZE=1000/HISTSIZE=1000 TMOUT=300/
	s/HISTSIZE=1000/HISTSIZE=50/' /etc/profile
	echo -e "Set TMOUT ${DONE}." 
fi

#只允许root执行cron/at####################################################################
echo root > /etc/cron.allow
echo root > /etc/at.allow
chown root:root /etc/cron.allow
chown root:root /etc/at.allow
chmod 400 /etc/cron.allow
chmod 400 /etc/at.allow

# 设置用户口令安全机制#####################################################################
# 编辑 /etc/login.defs，修改如下内容
#PASS_MAX_DAYS   90 #口令需要修改的天数，根据实际情况设置
#PASS_MIN_DAYS   7 #口令不可修改的天数，根据实际情况设置
#PASS_MIN_LEN    7 #口令最小长度
#PASS_WARN_AGE   28 #警告期限
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   99999/
	s/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   7/
	s/^PASS_MIN_LEN.*/PASS_MIN_LEN    7/
	s/^PASS_WARN_AGE.*/PASS_WARN_AGE   28/' /etc/login.defs

#安装Denyhosts防止暴力破解FTP/SSH等服务，自动封IP#########################################
#解封直接清除掉/etc/hosts.deny文件中对应的IP即可"echo '' > /etc/hosts.deny"
if [ ! -e /etc/denyhosts.conf  ] 
then 
	yum -y install denyhosts
	service denyhosts start
	chkconfig --levels 345 denyhosts on
	echo -e "Set Denyhosts ${DONE}." 
fi

#存放用户名密码的系统文件加锁############################################################
#这里使用chattr是改变文件属性，若不通过chattr -i 文件名，命令解锁的话，即使root用户也无法修改它，查看文件是否加锁方法：lsattr 文件名
#文件加上不可更改属性，从而防止非授权用户获得权限
chattr +i /etc/passwd        
chattr +i /etc/shadow
chattr +i /etc/gshadow
chattr +i /etc/group
chattr +i /etc/services    #给系统服务端口列表文件加锁,防止未经许可的删除或添加服务  
#lsattr  /etc/passwd   /etc/shadow  /etc/group  /etc/gshadow   /etc/services   #显示文件的属性 
#注意：执行以上权限修改之后，就无法添加删除用户了。
#如果再要添加删除用户，需要先取消上面的设置，等用户添加删除完成之后，再执行上面的操作  
#chattr -i /etc/passwd     #取消权限锁定设置
#chattr -i /etc/shadow
#chattr -i /etc/group
#chattr -i /etc/gshadow
#chattr -i /etc/services   #取消系统服务端口列表文件加锁
#现在可以进行添加删除用户了，操作完之后再锁定目录文件
echo -e "Set chattr ${DONE}." 

#更改系统的一些重要文件的权限#############################################################
chmod 600 /etc/passwd
chmod 600 /etc/shadow
chmod 600 /etc/group
chmod 600 /etc/gshadow

chmod 700 -R /etc/init.d/  #修改init目录文件执行权限,禁止非root用户执行/etc/init.d/下的系统命令
chmod 600 /etc/grub.conf   #修改系统引导文件的权限
chattr +i /etc/grub.conf   #对系统引导文件加锁
chattr +i /etc/service     #对系统服务端口列表文件加锁
chmod a-s /usr/bin/chage   #修改部分系统文件的SUID和SGID的权限
chmod a-s /usr/bin/gpasswd
chmod a-s /usr/bin/wall
chmod a-s /usr/bin/chfn
chmod a-s /usr/bin/chsh
chmod a-s /usr/bin/newgrp
chmod a-s /usr/bin/write
chmod a-s /usr/sbin/usernetctl
chmod a-s /bin/traceroute
chmod a-s /bin/mount
chmod a-s /bin/umount
chmod a-s /bin/ping
chmod a-s /sbin/netreport

chattr +a .bash_history           #避免删除.bash_history或者重定向到/dev/null
chattr +i .bash_history 
chmod 555 /usr/bin                #恢复  chmod 555 /usr/bin 如果需要使用sudo命令，此项则不修改，否则会导致“-bash: sudo: command not found”的错误
chmod 700 /bin/ping               #恢复  chmod 4755 /bin/ping
chmod 700 /usr/bin/vim         	  #恢复  chmod 755 /usr/bin/vim
chmod 700 /bin/netstat            #恢复  chmod 755 /bin/netstat
chmod 700 /usr/bin/tail           #恢复  chmod 755 /usr/bin/tail
chmod 700 /usr/bin/less           #恢复  chmod 755 /usr/bin/less
chmod 700 /usr/bin/head           #恢复  chmod 755 /usr/bin/head
chmod 755 /bin/cat                #恢复  chmod 755 /bin/cat	原来是700权限
chmod 700 /bin/uname              #恢复  chmod 755 /bin/uname
chmod 500 /bin/ps                 #恢复  chmod 755 /bin/ps
echo -e "Set SUID AND SGID ${DONE}."
#关闭多余的虚拟控制台#####################################################################
#我们知道从控制台切换到 X 窗口，一般采用 Alt-F7 ，为什么呢？因为系统默认定义了 6 个虚拟控制台，
#所以 X 就成了第7个。实际上，很多人一般不会需要这么多虚拟控制台的，修改/etc/inittab ，注释掉那些你不需要的。
#系统如果是最小化安装，没有这部份内容，这段代码可以不用执行
if [ ! -e /etc/inittab.bak  ] 
then 
	cp /etc/inittab  /etc/inittab.bak
	sed -i 's/2:2345/#2:2345/
	s/3:2345/#3:2345/
	s/4:2345/#4:2345/
	s/5:2345/#5:2345/
	s/6:2345/#6:2345/' /etc/inittab
fi

#1:2345:respawn:/sbin/mingetty tty1 只保留第一个
#删除MySQL历史记录########################################################################
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

#隐藏服务器系统信息#######################################################################
#在缺省情况下，当你登陆到linux系统，它会告诉你该linux发行版的名称、版本、内核版本、服务器的名称。
#为了不让这些默认的信息泄露出来，我们要进行下面的操作，让它只显示一个"login:"提示符。
#删除/etc/issue和/etc/issue.net这两个文件，或者把这2个文件改名，效果是一样的。
if [ ! -e /etc/issue.bak ] 
then 
	mv /etc/issue /etc/issue.bak
	mv /etc/issue.net /etc/issue.net.bak
fi

#处理/etc/hosts.equiv#####################################################################
#/etc/hosts.equiv里的主机不需要提供密码就可以访问本机.
#A、不需要/etc/hosts.equiv
#预先生成/etc/hosts.equiv文件，并且设置权限为0000,防止被写入"++"。
touch /etc/hosts.equiv
chmod 0000 /etc/hosts.equiv
#B、需要/etc/hosts.equiv
#文件属主确保为root，设置权限为0600,防止被写入"++"。

#优化Linux内核参数########################################################################
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

#CentOS 系统优化##########################################################################
if [ ! -e /etc/profile.bak2 ] 
then 
	cp /etc/profile /etc/profile.bak2
	echo 'ulimit -c unlimited
ulimit -s unlimited
ulimit -SHn 65535' >> /etc/profile
	source  /etc/profile    #使配置立即生效
	ulimit -a    #显示当前的各种用户进程限制
fi

#服务器禁止ping###########################################################################
if [ ! -e /etc/rc.d/rc.local.bak ] 
then 
	cp /etc/rc.d/rc.local /etc/rc.d/rc.local.bak     
	echo 'echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all' >> /etc/rc.d/rc.local
	#参数0表示允许   1表示禁止
fi

#对您的系统上所有的用户设置资源限制可以防止DoS类型攻击####################################
#如最大进程数，内存数量等。例如，对所有用户的限制象下面这样：
#下面的代码示例中，所有用户每个会话都限制在 10 MB，并允许同时有四个登录。第三行禁用了每个人的内核转储。第四行除去了用户 bin 的所有限制。
if [ ! -e  /etc/security/limits.conf.bak ] 
then 
	cp /etc/security/limits.conf /etc/security/limits.conf.bak 
	echo '* hard rss 10000
* hard maxlogins 4
* hard core 0
bin -
* soft nofile 65535
* hard nofile 65535' >> /etc/security/limits.conf
	#激活这些限制
	echo 'session required /lib64/security/pam_limits.so' >> /etc/pam.d/login
fi

#使用yum update更新系统时不升级内核，只更新软件包#########################################
#由于系统与硬件的兼容性问题，有可能升级内核后导致服务器不能正常启动，这是非常可怕的，
#没有特别的需要，建议不要随意升级内核。
if [ ! -e  /etc/yum.conf.bak ] 
then 
	cp /etc/yum.conf    /etc/yum.conf.bak
	echo 'exclude=kernel*' >> /etc/yum.conf
fi

#系统升级#################################################################################
#防止被不小心更改了，或被黑客利用了，导致系统崩溃等问题
/etc/init.d/yum-updatesd stop          #停止自动升级工具
yum -y remove yum-updatesd             #卸载yum-updatesd工具
yum -y install yum-fastestmirror       #安装另外一个自动升级工具，这个工具保证从就近服务器下载安装包

yum clean all     					   # 清除缓存的软件包及旧headers
yum makecache     					   #将服务器上的软件包信息缓存到本地,以提高搜索安装软件的速度
yum -y update                          #系统升级
#reboot                                #从新启动系统
echo -e "Set update ${DONE}."
#查看系统信息#############################################################################
#输出正在运行的服务
ps aux | wc -l
#输出运行的服务
netstat -na --ip

# 打开远程连接端口#########################################################################
#防火墙初始化
#查看iptables现有规则
#iptables -L -n
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
#iptables -A INPUT -p tcp --dport 22 -j ACCEPT
#开放21端口(FTP)
#iptables -A INPUT -p tcp --dport 21 -j ACCEPT
#开放80端口(HTTP)
#iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#开放443端口(HTTPS)
#iptables -A INPUT -p tcp --dport 443 -j ACCEPT
#允许ping
#iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
#允许sshd端口
iptables -A INPUT -p tcp --dport $SSH_PORT -j ACCEPT
#允许接受本机请求之后的返回数据 RELATED,是为FTP设置的
iptables -A INPUT -m state --state  RELATED,ESTABLISHED -j ACCEPT
#其他入站一律丢弃
iptables -P INPUT DROP
#所有出站一律绿灯
iptables -P OUTPUT ACCEPT

#防火墙初始化


/etc/rc.d/init.d/iptables save
/etc/init.d/iptables restart

cat << EOF
+-------------------------------------------------+
|               optimizer is done                 |
|   it's recommond to restart this server !       |
+-------------------------------------------------+
EOF

#init done,and reboot system  
echo -e "Do you want to \e[0;31m\033[1mreboot\e[m system now? [Y/N]:\t " 
read REPLY 
case $REPLY in  
	Y|y) 
		echo "The system will reboot now ..." 
		shutdown -r now  
		;; 
	N|n) 
		echo "You must reboot later..." 
		source /etc/profile  
		;; 
	*) 
		echo "You must input [Y/N]." 
		source /etc/profile  
		;; 
esac 