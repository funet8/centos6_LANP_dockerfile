# docker intall_php7or php5.6

虚拟机上
构建PHP5.6
```
docker run -itd --name PHP_FPM5 \
-p 5600:9000 \
--restart always \
-v /data/wwwroot/web:/usr/share/nginx/html \
-v /etc/localtime:/etc/localtime \
docker.io/cytopia/php-fpm-5.6
```

构建php7
```
docker run -itd --name PHP_FPM7 \
-p 7000:9000 \
--restart always \
-v /data/wwwroot/web:/usr/share/nginx/html \
-v /etc/localtime:/etc/localtime \
docker.io/cytopia/php-fpm-7.1
```

下载docker中配置文件
```
PHP_FPM5
/etc/php.ini
/etc/php-fpm.conf

# docker cp PHP_FPM5:/etc/php.ini /root/
# docker cp PHP_FPM5:/etc/php-fpm.conf /root/

PHP_FPM7
docker cp PHP_FPM7:/etc/php.ini /root/
docker cp PHP_FPM7:/etc/php-fpm.conf /root/
```


将docker推送到阿里云docker仓库中(需要登录阿里云账户)

推送phpfpm5.6
```
docker tag docker.io/cytopia/php-fpm-5.6 registry.cn-shenzhen.aliyuncs.com/funet8/php-fpm-5.6

docker push registry.cn-shenzhen.aliyuncs.com/funet8/php-fpm-5.6
```

推送phpfpm7.1
```
docker tag docker.io/cytopia/php-fpm-7.1 registry.cn-shenzhen.aliyuncs.com/funet8/php-fpm-7.1

docker push registry.cn-shenzhen.aliyuncs.com/funet8/php-fpm-7.1
```


重新生产环境
docker生成phpfpm5.6
```
mkdir -p /data/docker/phpfpm5/
cd /data/docker/phpfpm5/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_7_intall_php/docker_conf/phpfpm5/php-fpm.conf
#wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_7_intall_php/docker_conf/phpfpm5/php.ini

docker run -itd --name PHP_FPM5 \
-p 5600:9000 \
--restart always \
-v /data/wwwroot/web:/data/wwwroot/web \
-v /data/docker/phpfpm5/php-fpm.conf:/etc/php-fpm.conf \
-v /etc/localtime:/etc/localtime \
registry.cn-shenzhen.aliyuncs.com/funet8/php-fpm-5.6
```

docker生成php-fpm7
```
mkdir -p /data/docker/phpfpm7/
cd /data/docker/phpfpm7/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_7_intall_php/docker_conf/phpfpm7/php-fpm.conf
#wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_7_intall_php/docker_conf/phpfpm7/php.ini

docker run -itd --name PHP_FPM7 \
-p 7000:9000 \
--restart always \
-v /data/wwwroot/web:/data/wwwroot/web \
-v /data/docker/phpfpm7/php-fpm.conf:/etc/php-fpm.conf \
-v /etc/localtime:/etc/localtime \
registry.cn-shenzhen.aliyuncs.com/funet8/php-fpm-7.1
```











## 在宿主机上安装PHP
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

