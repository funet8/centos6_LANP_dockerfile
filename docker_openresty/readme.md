# openresty的docker实例

## 什么是openresty
http://openresty.org/cn/

OpenResty® 是一个基于 Nginx 与 Lua 的高性能 Web 平台，其内部集成了大量精良的 Lua 库、第三方模块以及大多数的依赖项。用于方便地搭建能够处理超高并发、扩展性极高的动态 Web 应用、Web 服务和动态网关。

2.启动openresty
```
mkdir -p /data/docker/openresty/conf.d/waf/rule-config
chmod 777 -R /data/wwwroot/log/
cd /data/docker/openresty/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/nginx.conf
cd /data/docker/openresty/conf.d/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/nginx_main.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Apache_PHP5.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Backup_PHP5.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Backup_PHP7.conf
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/centos6_Yum_Nginx/Include/Include_Static_File.conf

docker run -itd --name="openresty" \
--restart always \
-p 80:80 \
-p 443:443 \
-v /data/docker/openresty/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf:ro \
-v /data/docker/openresty/conf.d:/etc/nginx/conf.d \
-v /data/wwwroot/:/data/wwwroot/ \
-v /etc/localtime:/etc/localtime \
openresty/openresty

```


3.nginx配置
```
http {
    server {
        listen 80;
        location / {
           index  index.html index.htm index.php;
        }
        location /hello_openresty {
            default_type text/html;
            content_by_lua 'ngx.say("<p>hello, openresty</p>")';
        }
    }
}
```

4.配置waf策略
```
cd /data/docker/openresty/conf.d/waf/
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/access.lua
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/config.lua
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/init.lua
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/lib.lua
cd /data/docker/openresty/conf.d/waf/rule-config
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/args.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/blackip.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/cookie.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/post.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/url.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/useragent.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/whiteip.rule
wget https://raw.githubusercontent.com/funet8/centos6_LANP_dockerfile/master/docker_openresty/waf/rule-config/whiteurl.rule

```
## WAF实现功能
```
支持IP白名单和黑名单功能，直接将黑名单的IP访问拒绝。
支持URL白名单，将不需要过滤的URL进行定义。
支持User-Agent的过滤，匹配自定义规则中的条目，然后进行处理（返回403）。
支持CC攻击防护，单个URL指定时间的访问次数，超过设定值，直接返回403。
支持Cookie过滤，匹配自定义规则中的条目，然后进行处理（返回403）。
支持URL过滤，匹配自定义规则中的条目，如果用户请求的URL包含这些，返回403。
支持URL参数过滤，原理同上。
支持日志记录，将所有拒绝的操作，记录到日志中去。
日志记录为JSON格式，便于日志分析，例如使用ELKStack进行攻击日志收集、存储、搜索和展示。
```

1.模拟sql注入即url攻击-成功
```
实现策略：
# curl http://192.168.0.4/1.sql
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="zh-cn" />
<title>网站防火墙</title>
</head>
<body>
<h1 align="center"> 欢迎白帽子进行授权安全测试，安全漏洞请联系QQ：401313302。
</body>
</html>
```
2.使用ab压测工具模拟防cc攻击
```
ab -n 2000 -c 50 http://192.168.0.4/
```
在访问日志中查看:
```
0.000 - IP:192.168.1.6 - RealIP:- - [13/Jun/2019:09:30:56 +0000] GET / HTTP/1.0 - 403 - ApacheBench/2.3 - 192.168.0.4 - from:-
```

3.模拟ip黑名单-成功
```
echo "--测试IP" >>/data/docker/openresty/conf.d/waf/rule-config/blackip.rule 
echo "192.168.1.6" >>/data/docker/openresty/conf.d/waf/rule-config/blackip.rule 
重启openresty
```

测试：
```
# curl http://192.168.0.4/
<html>
<head><title>403 Forbidden</title></head>
<body bgcolor="white">
<center><h1>403 Forbidden</h1></center>
<hr><center>openresty</center>
</body>
</html>
```

4. 模拟ip白名单-成功

将请求ip放入ip白名单中，此时将不对此ip进行任何防护措施，所以sql注入时应该返回404
```
echo "--测试IP" >>/data/docker/openresty/conf.d/waf/rule-config/whiteip.rule
echo "192.168.1.6" >>/data/docker/openresty/conf.d/waf/rule-config/whiteip.rule
重启openresty
```
测试：
```
# curl http://192.168.0.4/
aaaaaaaaaaaaaaaaa
```

5 模拟URL参数检测
```
浏览器输入 http://192.168.0.4/?id=select * from name where name="jack"
```



[openresty的docker实例](https://segmentfault.com/a/1190000007387013)
