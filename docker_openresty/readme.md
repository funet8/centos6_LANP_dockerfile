# openresty的docker实例

## 什么是openresty
http://openresty.org/cn/

OpenResty® 是一个基于 Nginx 与 Lua 的高性能 Web 平台，其内部集成了大量精良的 Lua 库、第三方模块以及大多数的依赖项。用于方便地搭建能够处理超高并发、扩展性极高的动态 Web 应用、Web 服务和动态网关。

1.基于docker
```
docker pull openresty/openresty:1.9.15.1-trusty
```

2.启动openresty
```
docker run -itd --name openresty \
--restart always \
-p 80:80 -p 443:443 \
-v /data/docker/openresty/config/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf:ro \
-v /data/docker/openresty/logs:/usr/local/openresty/nginx/logs \
openresty/openresty:1.9.15.1-trusty
```

3.nginx配置
```
worker_processes  1;
error_log logs/error.log;
events {
    worker_connections 1024;
}
http {
    server {
        listen 80;
        location / {
            default_type text/html;
            content_by_lua '
                ngx.say("<p>hello, world</p>")
            ';
        }
    }
}
```



[openresty的docker实例](https://segmentfault.com/a/1190000007387013)
