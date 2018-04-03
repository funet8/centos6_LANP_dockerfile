# MAINTAINER        star <funet8@163.com>

#FROM 		funet8/centos:6.9
FROM 		registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:v1
MAINTAINER star  <funet8@163.com>

ENV TZ "Asia/Shanghai"
ENV TERM xterm

ADD MariaDB.repo /etc/yum.repos.d/MariaDB.repo

RUN yum -y remove mysql* mariadb*
RUN rpm --import http://yum.mariadb.org/RPM-GPG-KEY-MariaDB

RUN yum clean all && \ 
	yum makecache
	
RUN yum install -y MariaDB-server MariaDB-client && \ 
	chkconfig --levels 235 mysql on
	
RUN mkdir -p /var/log/mysql/ && \ 
	chown mysql.mysql -R /var/log/mysql/

#设置密码	
#RUN mysql -e "grant all privileges on *.* to 'root'@'%' identified by '1234';"
#RUN mysql -e "grant all privileges on *.* to 'root'@'localhost' identified by '1234';"
EXPOSE 3306
	
EXPOSE 3306

ADD conf/my.cnf /etc/my.cnf
ADD supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
