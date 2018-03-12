# 基于centos6系统下使用dockerfile创建LNAP


| 字母| 代表 |
|---|---|
| L | Centos6.9 |
| N | nginx |
| A | apache2.2 |
| P | php5.3 |

克隆项目
```
yum install git
git clone https://github.com/funet8/centos6_LANP_dockerfile.git
```
进入相应目录构建进行
```
cd centos6_LANP_dockerfile/centos6
创建目录
sh create_dir.sh 
构建镜像:
docker build -t  funet8/centos_lnap:6.9.1 .
```
启动容器：
```
docker run -itd --name centos6LNAP --restart always -p 80:80 -p 443:443 -v /data/:/data/ -v /data/conf/nginx.conf:/etc/nginx/nginx.conf -v /data/conf/httpd.conf:/etc/httpd/conf/httpd.conf -v /data/conf/php.ini:/etc/php.ini  funet8/centos_lnap:6.9.1
```
进入容器
```
docker logs centos6LNAP
docker exec -it centos6LNAP /bin/bash
```
删除容器和镜像
```
docker rm -f centos6LNAP
docker rmi funet8/centos_lnap:6.9.1
```














## docker网络问题解决
```
pkill docker 
iptables -t nat -F 
ifconfig docker0 down 
brctl delbr docker0 
docker -d 
service docker restart

-bash: brctl: command not found
解决：
yum install bridge-utils
```


