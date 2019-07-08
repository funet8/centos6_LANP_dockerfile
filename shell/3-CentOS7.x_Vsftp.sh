#!/bin/bash
 
# -------------------------------------------------------------------------------
# Filename:    vsftpd.sh
# Revision:    1.0
# Date:        2015/10/09
# Author:      star
# Email:       liuxing007xing@163.com
# Website:     www.funet8.com
# Description: 安装vsftpd
# Notes:       需要切换到root运行,版本针对64位系统，操作系统为CentOS6.3
#            
# -------------------------------------------------------------------------------
# Copyright:   2013 (c) star
#Version 1.0
#Version 1.1
#20161117
#新增mount方法
# -------------------------------------------------------------------------------

#变量设置#############################################################################
IS_TEST=1 # 是否测试，1为测试，其它值为非测试
FTP_USER="www" 
FTP_DIR="/data/wwwroot/ftp" 
FTP_PORT='62920' #ftp访问端口
# 虚拟用户名单和密码
VIRT_USER_LIST='yxkj_web
123456'
# 虚拟用户配置文件名
VIRT_USER_CONF_FILE_NAME='yxkj_web'

DONE="\e[0;32m\033[1mdone\e[m" 

#测试初始化###########################################################################
	# 创建目录
	mkdir /home/data
	ln -s /home/data /data
	
	mkdir /www
	mkdir /data/wwwroot
	ln -s /data/wwwroot /www/
	mkdir -p /data/wwwroot/{web,log}
	mkdir -p $FTP_DIR
	mkdir /data/conf
	mkdir /data/conf/{sites-available,shell}	

	mkdir /backup
	ln -s /backup /data/
	# 生成www用户useradd -s /sbin/nologin vsftpd
	useradd  www
	chown www:www $FTP_DIR -R
	mkdir -p $FTP_DIR
	chown www:www $FTP_DIR -R	
	chown www:www -R /data/wwwroot/web/
	mkdir -p /data/conf/vsftpd/

#安装vsftp############################################################################
#yum install vsftpd pam pam-* db4 db4-*
yum -y install vsftpd

#开启防火墙
/sbin/iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport $FTP_PORT -j ACCEPT
/sbin/iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 20 -j ACCEPT
/sbin/iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 9000:9045 -j ACCEPT
service iptables save
systemctl restart iptables.service

#修改vsftp配置文件####################################################################
#配置前先备份，直接改名，后面做软链接
mv  /etc/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf.bak
#mv  /etc/vsftpd/vsftpd.conf /data/conf/vsftpd/
echo "
#ftp时间和系统同步,如果启动有错误，请注销
use_localtime=NO
#添加此行，解决客户端登陆缓慢问题！重要！默认vsftpd开启了DNS反响解析！这里需要关闭，如果启动有错误，请注销！
reverse_lookup_enable=NO
#默认无此行，ftp端口为21，添加listen_port=2222把默认端口修改为2222，注意：防火墙同时要开启2222端口
listen_port=$FTP_PORT
#禁止匿名用户
anonymous_enable=NO
#设定本地用户可以访问。注意：主要是为虚拟宿主用户，如果该项目设定为NO那么所有虚拟用户将无法访问
local_enable=YES
#全局设置，是否容许写入（无论是匿名用户还是本地用户，若要启用上传权限的话，就要开启他）
write_enable=YES
#创建或上传后文件的权限掩码，文件的权限是644
local_umask=022
#禁止匿名用户上传
anon_upload_enable=NO
#禁止匿名用户建立目录
anon_mkdir_write_enable=NO
#设定开启目录标语功能，进入目录时可以显示一些设定的信息，可以通过message_file=.message来设置
dirmessage_enable=YES
#设定开启日志记录功能
xferlog_enable=YES
#主动连接的端口号
connect_from_port_20=YES
#设定禁止上传文件更改宿主
chown_uploads=NO
#设定Vsftpd的服务日志保存路径。注意，该文件默认不存在。必须要手动touch出来，并且由于这里更改了Vsftpd的服务宿主用户为手动建立的Vsftpd。必须注意给与该用户对日志的写入权限，否则服务将启动失败，如chown  vsftpd.vsftpd /var/log/vsftpd.log
xferlog_file=/data/wwwroot/log/other/vsftpd_xferlog.log
#格式化日志格式，使用标准格式
xferlog_std_format=YES
# 如果启用该选项，将生成两个相似的日志文件，默认在 /var/log/xferlog 和 /var/log/vsftpd.log 目录下。前者是 wu-ftpd 类型的传输日志，可以利用标准日志工具对其进行分析；后者是Vsftpd类型的日志。
dual_log_enable=YES
vsftpd_log_file=/data/wwwroot/log/other/vsftpd.log
#设定支撑Vsftpd服务的宿主用户为手动建立的Vsftpd用户。注意，一旦做出更改宿主用户后，必须注意一起与该服务相关的读写文件的读写赋权问题。比如日志文件就必须给与该用户写入权限等
nopriv_user=vsftpd
#设定支持异步传输功能
async_abor_enable=YES
#设定支持ASCII模式的上传
ascii_upload_enable=YES
#设定支持ASCII模式的下载
ascii_download_enable=YES
#设定Vsftpd的登陆欢迎语
ftpd_banner=Welcome to 3mu FTP service ^_^
#禁止本地用户登出自己的FTP主目录（NO表示禁止登出，YES表示允许登出）
chroot_local_user=NO
#禁止虚拟用户登出自己的FTP主目录，即限定在自己的目录内，不让他出去，就比如如果设置成NO，那么当你登陆到ftp的时候，可以访问服务器的其他一些有权限目录。设置为YES后，即锁定你的目录了
chroot_list_enable=YES
#文件中的用户被禁锢在自己的宿主目录中。/etc/vsftp/chroot_list本身是不存在的，这要建立vim /etc/vsftp/chroot_list，然后将帐户输入一行一个，保存就可以了
chroot_list_file=/etc/vsftpd/chroot_list
#设为YES时，以standalone方式来启动，否则以超级进程的方式启动。顺便展开说明一下，所谓StandAlone模式就是该服务拥有自己的守护进程支持，在ps -A命令下我们将可用看到vsftpd的守护进程名。如果不想工作在StandAlone模式下，则可以选择SuperDaemon模式，在该模式下vsftpd将没有自己的守护进程，而是由超级守护进程Xinetd全权代理，与此同时，Vsftp服务的许多功能将得不到实现。
listen=YES
#设定PAM服务下Vsftpd的验证配置文件名。因此，PAM验证将参考/etc/pam.d/下的vsftpd文件配置
pam_service_name=vsftpd
#在/etc/vsftpd/user_list中的用户将不得使用FTP,设为YES的时候，如果一个用户名是在userlist_file参数指定的文件中，那么在要求他们输入密码之前，会直接拒绝他们登陆
userlist_enable=YES
#设为YES时，ftp服务器将使用tcp_wrappers作为主机访问控制方式,支持 TCP Wrappers 的防火墙机制
tcp_wrappers=YES
#设定空闲连接超时时间，这里也可以不设置，将具体数值留给每个具体用户具体指定，当然如果不指定的话，还是使用系统的默认值600，单位秒。
idle_session_timeout=300
#空闲1秒后服务器断开
data_connection_timeout=1
#########################################################
# ssl设置												#
#########################################################
ssl_enable=NO
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
ssl_tlsv1=YES
ssl_sslv2=NO
ssl_sslv3=NO
rsa_cert_file=/etc/vsftpd/vsftpd.pem
ssl_ciphers=HIGH

# 是否启用隐式ssl功能，不建议开启
implicit_ssl=YES
# 隐式ftp端口设置，如果不设置，默认还是21，但是当客户端以隐式ssl连接时，默认会使用990端口，导致连接失败！！
listen_port=62920
# 输出ssl相关的日志信息
#debug_ssl=YES
#########################################################
#以下这些是关于Vsftpd虚拟用户支持的重要配置项目。
#默认Vsftpd.conf中不包含这些设定项目，需要自己手动添加配置
#########################################################
#设定启用虚拟用户功能
guest_enable=YES
#指定虚拟用户的宿主用户（这个是我们后面要新建的用户），系统默认是ftp用户，这里是全局设置，在虚拟用户的配置文件中也可以单独指定来覆盖全局设置的用户
guest_username=$FTP_USER
#设定虚拟用户个人Vsftp的配置文件存放路径。也就是说，这个被指定的目录里，将存放每个Vsftp虚拟用户个性的配置文件，一个需要注意的
#地方就是这些配置文件名必须和虚拟用户名相同。
#比如说vsftpd.conf的配置文件，你复制到这个目录下，你要mv一下，配置成虚拟用户的名称
user_config_dir=/data/conf/vsftpd/vconf
#当该参数激活（YES）时，虚拟用户使用与本地用户相同的权限。
#当此参数关闭（NO）时，虚拟用户使用与匿名用户相同的权限。默认情况下此参数是关闭的（NO）。
virtual_use_local_privs=YES
#设置被动模式的端口范围
pasv_min_port=9000
#设置被动模式的端口范围
pasv_max_port=9045
#保持5秒
accept_timeout=5
#1秒后重新连接
connect_timeout=1
#解决vsftpd: refusing to run with writable root inside chroot ()错误
allow_writeable_chroot=YES
" > /data/conf/vsftpd/vsftpd.conf

# 输出无注释的配置文件内容，方便查看
#awk '! /^(#|$)/' /data/conf/vsftpd/vsftpd.conf

# 建立Vsftpd配置文件软链接
ln -s /data/conf/vsftpd/vsftpd.conf /etc/vsftpd/vsftpd.conf

# 建立Vsftpd的日志文件
mkdir -p /data/wwwroot/log/other
# 创建wu-ftpd类型的日志文件（经测试无需创建，会自己创建）
#touch /data/wwwroot/log/other/vsftpd_xferlog.log
#chmod 600 /data/wwwroot/log/other/vsftpd_xferlog.log
#chown $FTP_USER.$FTP_USER /data/wwwroot/log/other/vsftpd_xferlog.log

# 创建vsftpd类型的日志文件（经测试无需创建，会自己创建）
#touch /data/wwwroot/log/other/vsftpd.log
#chmod 600 /data/wwwroot/log/other/vsftpd.log
#chown $FTP_USER.$FTP_USER /data/wwwroot/log/other/vsftpd.log

# 用openssl生成vsftpd的证书：
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/vsftpd/vsftpd.pem -out /etc/vsftpd/vsftpd.pem

# 建立虚拟用户名单文件
touch /etc/vsftpd/virtusers
# 用echo命令输出加引号的字符串时，将字符串原样输出；
# 用echo命令输出不加引号的字符串时，将字符串中的各个单词作为字符串输出，各字符串之间用一个空格分割。
echo "$VIRT_USER_LIST" > /etc/vsftpd/virtusers

# 生成虚拟用户数据文件：
db_load -T -t hash -f /etc/vsftpd/virtusers /etc/vsftpd/virtusers.db

# 设定PAM验证文件，并指定对虚拟用户数据库文件进行读取
chmod 600 /etc/vsftpd/virtusers.db  

# 在/etc/pam.d/vsftpd的文件头部加入以下信息（在后面加入无效，或是将vsftpd原内容全部注释掉，在文件末尾加）
cp /etc/pam.d/vsftpd  /etc/pam.d/vsftpd.bak
# 注意：如果系统为64为，则下面的lib改为lib64，否则配置失败

sed -ir 's/^/#/g' /etc/pam.d/vsftpd 

echo 'auth sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/virtusers
account sufficient /lib64/security/pam_userdb.so db=/etc/vsftpd/virtusers' >> /etc/pam.d/vsftpd

# 新建一个系统用户vsftpd，用户家目录为/data/wwwroot, 用户登录终端设为/bin/false(即使之不能登录系统)。因为配置网站的运行环境时已生成www用户，所以此步可以忽略
#useradd vsftpd -d /data/wwwroot -s /bin/false
#chown vsftpd:vsftpd /data/wwwroot -R

# 添加默认支撑Vsftpd服务的宿主用户，-M：不创建家目录
useradd vsftpd -M -s /bin/false

# 创建保存虚拟用户配置文件的目录
mkdir -p /data/conf/vsftpd/vconf
cd /data/conf/vsftpd/vconf
# 这里创建三个虚拟用户配置文件
touch $VIRT_USER_CONF_FILE_NAME
# 创建要将哪些用户固定在家目录的配置文件
touch /etc/vsftpd/chroot_list

# 编辑用户web1配置文件，其他的跟这个配置文件类似
cd /data/conf/vsftpd/vconf/ 
for VUSER in $VIRT_USER_CONF_FILE_NAME ;do 
	cat > $VUSER << EOF
#启用虚拟用户,centos下yes必须为小写字母 
#guest_enable=yes 
#通过此项可以配置不同的虚拟用户属于不同宿主用户，默认则用全局配置中的设置
#映射本地虚拟用户 
guest_username=$FTP_USER
#如果当时创建用户的时候锁定一个目录了，那就可以不写 
local_root=$FTP_DIR/$VUSER
#用户会话空闲后10分钟
idle_session_timeout=600
#将数据连接空闲2分钟断
data_connection_timeout=120
#最大客户端连接数 
max_clients=10 
#每个ip最大连接数 
max_per_ip=5 
#限制上传速率，0为无限制 
local_max_rate=0
#设置一个文件名或者目录名式样（注意：只能是文件名或是目录名，不支持路径模式）以阻止在任何情况下访问它们。并不是隐藏它们，而是拒绝任何试图对它们进行的操作（下载，改变目录层，和其他有影响的操作）。
deny_file={*.mp3,*.mov,.private}
#设置了一个文件名或者目录名（注意：只能是文件名或是目录名，不支持路径模式）列表，这个列表内的资源会被隐藏，不管是否有隐藏属性。但如果用户知道了它的存在，将能够对它进行完全的访问。
hide_file={*.mp3,.hidden,hide*}
EOF

	# 创建测试用户ftp目录
	mkdir -p $FTP_DIR/$VUSER
	# 将用户固定在家目录
	echo $VUSER >> /etc/vsftpd/chroot_list
done

chown $FTP_USER:$FTP_USER $FTP_DIR -R 
echo -e "Set virt_user_conf_file ${DONE}." 

#挂载ftp目录
#echo "/data/wwwroot/web  /data/wwwroot/ftp/$VUSER      none    rw,bind         0 0" >> /etc/fstab
#mount -a
#写入fstab中开机会报错："welcome to emergency mode! ....."
mount --bind /data/wwwroot/web  /data/wwwroot/ftp/yxkj_web
echo "##vsftpd-user-mount##" >> /etc/rc.local
echo "mount --bind /data/wwwroot/web  /data/wwwroot/ftp/yxkj_web" >> /etc/rc.local

# 设置开机自动启动并重新启动vsftpd
systemctl enable vsftpd.service
systemctl restart vsftpd.service

# 添加新用户的方法
# 建立虚拟用户名单文件 vi /etc/vsftpd/virtusers
# 生成虚拟用户数据文件 db_load -T -t hash -f /etc/vsftpd/virtusers /etc/vsftpd/virtusers.db
# 建立虚拟用户个人vsftp的配置文件 cp /data/conf/vsftpd/vconf/yxkj_web /data/conf/vsftpd/vconf/zhts_new
# 修改用户的ftp目录：修改文件：/data/conf/vsftpd/vconf/zhts_new中的local_root=/data/wwwroot/ftp/zhts_new
# 创建用户ftp目录 mkdir -p /data/wwwroot/ftp/zhts_new
# 将用户固定在家目录 echo zhts_new >> /etc/vsftpd/chroot_list
# 挂载网站目录：http://blog.sina.com.cn/s/blog_4496b0890101dqob.html
