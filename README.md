# Centos下构建LNMAP-web开发环境

环境说明：
宿主系统： Centos7

| 字母| 代表 | 端口 |
|---|---|---|
| L | Centos6.9 | \ |
| N | nginx |80 443|
| A | apache2.2 | 8080 |
| P | php5.6 或者PHP7 |5600 7000 |

## 系统安装
centos7安装 略

## 初始化系统

```
# wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/CentOS7.x_system_init_shell_mini.sh
修改hostname和端口
# sh CentOS7.x_system_init_shell_mini.sh
```

## 新增挂载硬盘
```
# fdisk -l
# fdisk /dev/vdb
...
Command (m for help): n
Select (default p): p
Command (m for help): wq
格式化：
# mkfs.ext4 /dev/vdb1

# vi /etc/fstab 
添加：
/dev/vdb1 /home ext4 defaults 0 0 
# mount -a

```


## 新建服务器目录
```
wget -q -O - https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/create_dir.sh | bash -sh
```

## 新建Vs服务
```
# wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/3-CentOS7.x_Vsftp.sh
修改参数
# sh 3-CentOS7.x_Vsftp.sh

```


## 安装docker
```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/CentOS6_7_intall_docker.sh
sh CentOS6_7_intall_docker.sh
```


## 构建基于docker的openresty-WAF
```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/run-aliyun-openresty.sh
需要修改是否连接PHPfpm-和数据库

sh run-aliyun-openresty.sh

#启动容器 --link链接mysql容器
********************************************
docker run -itd --name=openresty \
--restart always \
--link centos6_httpd_php56 \
-p 80:80 \
-p 443:443 \
-v /data/docker/openresty/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf \
-v /data/docker/openresty/conf.d:/etc/nginx/conf.d \
-v /data/wwwroot/:/data/wwwroot/ \
-v /etc/localtime:/etc/localtime \
registry.cn-shenzhen.aliyuncs.com/funet8/openresty

```

## 构建基于docker的nginx
```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/run-aliyun-nginx.sh
sh run-aliyun-nginx.sh
```

## 构建基于docker的apache2.2-php5.6
```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/run-aliyun-apache.sh

sh run-aliyun-apache.sh

********************************************
docker run -itd --name centos6_httpd_php56 \
--restart always \
-p 8080:8080 \
-v /data/docker/httpd/httpd.conf:/etc/httpd/conf/httpd.conf \
-v /data/docker/httpd/php.ini:/etc/php.ini  \
-v /data/docker/httpd/conf.d/:/etc/httpd/conf.d/  \
-v /data/wwwroot/:/data/wwwroot/ \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-httpd-php:v5.7
```


## 构建基于docker的mysql
```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/run-aliyun-mysql.sh
sh run-aliyun-mysql.sh

docker run -itd --name mysql \
--restart always \
-p 61950:3306 \
-v /data/docker/mysql_conf/my.cnf:/etc/my.cnf  \
-v /data/docker/mysql_conf/mysql_slowQuery.log:/var/log/mysql/mysql_slowQuery.log \
-v /data/docker/mysql_docker:/var/lib/mysql \
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-mariadb:v1

```

## 宿主机安装php7.3
```
端口:7300
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/CentOS7_Install_PHP7.3_PHPFPM.sh
sh CentOS7_Install_PHP7.3_PHPFPM.sh

```


## 切割日志

```
cd /data/conf/shell/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/cut_log_nginx_docker.sh
chmod +x /data/conf/shell/cut_log_nginx_docker.sh
echo '00 00 * * * root /data/conf/shell/cut_log_nginx_docker.sh' >> /etc/crontab
systemctl restart crond
```

## 解决权限问题
```
###权限问题的总结
#在宿主上查看www用户的ID
cat /etc/passwd |grep www
www:x:1001:1001::/home/www:/sbin/nologin
#进入docker虚拟机
docker exec -it centos6_httpd_php56 /bin/bash
usermod -u 1001 www && groupmod -g 1001 www
#将所需要的目录更改权限
ll /data/wwwroot/web/
```


## 重启docker网络

这是由于来自守护进程的错误响应，而致使外部连接失败。解决的办法就是将其docker进程 kill掉，然后再 清空掉iptables下nat表下的所有链（规则） 。最后，将 docker的网桥删除，并重启docker服务
```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/docker_net.sh
sh docker_net.sh
```

