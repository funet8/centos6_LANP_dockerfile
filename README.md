# Centos下构建LNMAP-web开发环境


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
# sh CentOS7.x_system_init_shell_mini.sh
```

## 新建服务器目录
```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/create_dir.sh
sh create_dir.sh
```


## 安装PHP
### 安装PHP5.6

```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_7_intall_php/centos6_7_intall_php5_6_9.sh

sh centos6_7_intall_php5_6_9.sh
```

### 安装PHP7.1
```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_7_intall_php/centos6_7_intall_php7_1_5.sh

sh centos6_7_intall_php7_1_5.sh
```

## 安装docker
```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/CentOS6_7_intall_docker.sh

sh CentOS6_7_intall_docker.sh
```

## 登录阿里云docker仓库
```
docker login --username=funet8@163.com registry.cn-shenzhen.aliyuncs.com
```

## 构建基于docker的nginx
```
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/run-aliyun-nginx.sh

sh run-aliyun-nginx.sh
```

## 构建基于docker的httpd
```

```



## 切割日志

```
cd /data/conf/shell/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/shell/cut_log_nginx_docker.sh
chmod +x /data/conf/shell/cut_nginx_log.sh
echo '00 00 * * * root /data/conf/shell/cut_nginx_log.sh' >> /etc/crontab
systemctl restart crond
```





















