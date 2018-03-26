# MAINTAINER        star <funet8@163.com>

FROM 		funet8/centos:6.9
MAINTAINER star  <funet8@163.com>

ENV TZ "Asia/Shanghai"
ENV TERM xterm

ADD MariaDB.repo /etc/yum.repos.d/MariaDB.repo

RUN yum -y remove mysql* mariadb*
RUN rpm --import http://yum.mariadb.org/RPM-GPG-KEY-MariaDB

RUN yum clean all && \ yum makecache
RUN yum install -y MariaDB-server MariaDB-client && \ chkconfig --levels 235 mysql on
RUN mkdir -p /var/log/mysql/ && \ chmod mysql.mysql -R /var/log/mysql/

EXPOSE 3306

ADD conf/my.cnf /etc/my.cnf
ADD supervisord.conf /etc/supervisord.conf

ENTRYPOINT ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]



