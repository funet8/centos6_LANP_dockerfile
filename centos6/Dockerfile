#
# MAINTAINER        star <funet8@163.com>
# DOCKER-VERSION    1.6.1
#
# Dockerizing CentOS6: Dockerfile for building CentOS images
# LNAP

FROM 		daocloud.io/centos:6.9
MAINTAINER star  <funet8@163.com>

ENV TZ "Asia/Shanghai"
ENV TERM xterm

ADD aliyun-centos6-mirror.repo /etc/yum.repos.d/CentOS-Base.repo
ADD aliyun-centos6-epel.repo /etc/yum.repos.d/epel.repo

RUN yum install -y curl wget tar bzip2 unzip vim-enhanced passwd sudo yum-utils hostname net-tools rsync man && \
    yum install -y gcc gcc-c++ git make automake cmake patch logrotate python-devel libpng-devel libjpeg-devel && \
    yum install -y --enablerepo=epel pwgen python-pip && \
    yum clean all
	
#卸载nginx httpd php
RUN yum -y remove nginx httpd* php*

#安装nginx
RUN rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm && \
	yum -y install nginx
#安装httpd,php和其他
RUN yum -y install httpd php php-mysql php-gd libjpeg* php-imap php-ldap php-odbc php-pear php-xml php-xmlrpc php-mbstring php-mcrypt php-bcmath php-mhash libmcrypt

RUN groupadd www && \
useradd -g www www

VOLUME ["/data"]

#nginx配置文件
RUN cp -p /etc/nginx/nginx.conf  /etc/nginx/nginx.conf.bak && \
	rm -rf /etc/nginx/nginx.conf	&& \
	ln -s /data/conf/nginx.conf /etc/nginx/
ADD nginx.conf /data/conf/nginx.conf

RUN cp -p /etc/nginx/conf.d/default.conf  /etc/nginx/conf.d/default.conf.bak && \
	rm -rf /etc/nginx/conf.d/default.conf	
ADD nginx_main.conf /data/conf/sites-available/nginx_main.conf

##httpd配置文件
RUN cp -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.bak && \
	mv /etc/httpd/conf/httpd.conf /data/conf/ && \
	ln -s /data/conf/httpd.conf /etc/httpd/conf/

RUN sed -i 's/Listen 80/Listen 8080/g' /data/conf/httpd.conf
	
RUN sed -i 's/ServerTokens OS/ServerTokens Prod/
s/ServerSignature On/ServerSignature Off/
s/Options Indexes FollowSymLinks/Options FollowSymLinks/
s/Options Indexes MultiViews FollowSymLinks/Options MultiViews FollowSymLinks/
s/DirectoryIndex index.html/DirectoryIndex index.html index.php/
s/KeepAlive Off/KeepAlive On/
s/MaxKeepAliveRequests 100/MaxKeepAliveRequests 1000/
s/User apache/User www/
s/Group apache/Group www/
s#/var/www/html#/data/wwwroot/web#' /data/conf/httpd.conf

ADD apache_main.conf /data/conf/sites-available/apache_main.conf

##php配置文件
RUN cp -p /etc/php.ini /etc/php.ini.bak && \
  mv /etc/php.ini /data/conf/ && \
  ln -s /data/conf/php.ini /etc/
 
RUN sed -i 's/;date.timezone \=/date.timezone \= PRC/
s/disable_functions \=/disable_functions \= passthru,exec,system,chroot,scandir,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,escapeshellcmd,dll,popen,disk_free_space,checkdnsrr,checkdnsrr,getservbyname,getservbyport,disk_total_space,posix_ctermid,posix_get_last_error,posix_getcwd, posix_getegid,posix_geteuid,posix_getgid, posix_getgrgid,posix_getgrnam,posix_getgroups,posix_getlogin,posix_getpgid,posix_getpgrp,posix_getpid, posix_getppid,posix_getpwnam,posix_getpwuid, posix_getrlimit, posix_getsid,posix_getuid,posix_isatty, posix_kill,posix_mkfifo,posix_setegid,posix_seteuid,posix_setgid, posix_setpgid,posix_setsid,posix_setuid,posix_strerror,posix_times,posix_ttyname,posix_uname/
s/expose_php = On/expose_php = Off/
s/;open_basedir =/open_basedir = \/tmp\/:\/var\/tmp\/:\/data\/wwwroot\/web\/:\/usr\/share\/phpmyadmin\//
s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo = 0/
s/upload_max_filesize = 2M/upload_max_filesize = 5M/
s/max_input_time = 60/max_input_time = 30/
s/memory_limit = 128M/memory_limit = 64M/
s/error_reporting = E_ALL & ~E_DEPRECATED/error_reporting = E_ERROR/
s/session.save_path/;session.save_path/
s/display_errors = On/display_errors = Off/
s/register_globals = On/register_globals = Off/
s/short_open_tag = Off/short_open_tag = On/
s/log_errors = Off/log_errors = On/' /data/conf/php.ini


#重启nginx和httpd
#ENTRYPOINT ["/etc/init.d/nginx","reload"]
#ENTRYPOINT ["/etc/init.d/httpd","reload"]

EXPOSE 80 443 8080
