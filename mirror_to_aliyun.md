# 将镜像推送到阿里云仓库

由于速度和隐私原因，可以使用阿里云的docker镜像，优势可以免费使用私有镜像，并且大天朝的速度也可以保证。
https://cr.console.aliyun.com/#/imageList

1."命名空间管理"--->"创建命名空间" 这里我创建funet8作为空间名
2."镜像列表"--->"指定的地域"--->"穿件镜像仓库"


# 服务器中登录阿里云registry:
这里我选择华南仓库。
```
# docker login --username=funet8@163.com registry.cn-shenzhen.aliyuncs.com
Password: 
Email: funet8@163.com
WARNING: login credentials saved in /root/.docker/config.json
Login Succeeded
```

**使用自己的账号登录后可以下载自己私有的镜像服务。**
大概分为以下几步骤。
1.在阿里云ECS中构建成功镜像。
2.将次镜像打一个“TAG”标签，将镜像推送到阿里云registry。（涉及到更新镜像）
4.推送镜像到阿里云registry。
5.在阿里云或者其他服务器中拉取使用镜像。

## 参考脚本

### 查看本地镜像：
```
[root@centos-02 ~]# docker images
REPOSITORY                                                 TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
funet8/centos6.9-base                                      latest              f22a5aff7f55        3 days ago          671.3 MB
```

### 将镜像推送到registry

给本地镜像打标签
```
docker tag [ImageId] registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:[镜像版本号]

# docker tag funet8/centos6.9-base registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:v1
# docker tag funet8/centos6mariadb registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-mariadb:v1
# docker tag funet8/centos6nginx:v1 registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-nginx:v1
# docker tag funet8/centos6php56:v1 registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-httpd-php:v5.6
# docker tag funet8/centos6_httpd_php56:v1 registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-httpd-php:v5.8
# docker tag funet8/centos6redis2:v2 registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-redis:v1
```

将centos7镜像推送到阿里云registry
```
docker push registry.cn-shenzhen.aliyuncs.com/funet8/centos7.2-base:v1
docker push registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-httpd-php:v5.8
```

### 更新docker
```
docker tag funet8/centos6_httpd_php56:v2 registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-httpd-php:v5.7
```

### 查看镜像
```
[root@centos-02 ~]# docker images
REPOSITORY                                                 TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
funet8/centos6.9-base                                      latest              f22a5aff7f55        3 days ago          671.3 MB
registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base    v1                  f22a5aff7f55        3 days ago          671.3 MB
```
### 推送镜像到阿里云
```
# docker push registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:v1
# docker push registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-mariadb:v1
# docker push registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-nginx:v1
# docker push registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-httpd-php:v5.6
# docker push registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-redis:v1
# docker push registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-httpd-php:v5.7
```
### 拉取刚才使用镜像：
拉取最新的镜像:latest
```
# docker pull registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:v1

# docker run -itd --name centos6base  registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:v1

# docker pull registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-mariadb:v1

```




# 阿里云官方参考文档
```
#### 登录阿里云docker registry:
$ sudo docker login --username=funet8@163.com registry.cn-shenzhen.aliyuncs.com

登录registry的用户名是您的阿里云账号全名，密码是您开通服务时设置的密码。
你可以在镜像管理首页点击右上角按钮修改docker login密码。

#### 从registry中拉取镜像：
$ sudo docker pull registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:[镜像版本号]

#### 将镜像推送到registry：
  $ sudo docker login --username=funet8@163.com registry.cn-shenzhen.aliyuncs.com
  $ sudo docker tag [ImageId] registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:[镜像版本号]
  $ sudo docker push registry.cn-shenzhen.aliyuncs.com/funet8/centos6.9-base:[镜像版本号]

其中[ImageId],[镜像版本号]请你根据自己的镜像信息进行填写。
```
