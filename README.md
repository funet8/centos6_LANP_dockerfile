# 基于centos6系统下使用dockerfile创建LNAP


| 字母| 代表 |
|---|---|
| L | Centos6.9 |
| N | nginx |
| A | apache |
| P | php |

1.克隆 dockerfile
```
yum install git
git clone https://github.com/funet8/centos6_LANP_dockerfile.git
```
2.进入相应目录构建进行
```
cd centos6_LANP_dockerfile/centos6
构建镜像:
docker build -t  funet8/centos_lnap:6.9 .
```
3.启动容器：
```
docker run -itd --name centos6LNAP --restart always -p 80:80 -p 443:443 -v /data/:/data/  funet8/centos:6.9
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


