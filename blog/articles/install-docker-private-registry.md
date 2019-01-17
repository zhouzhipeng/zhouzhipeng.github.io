# Docker 私有仓库搭建

## docker安装配置
```bash
# 安装docker环境
curl -sSL https://get.daocloud.io/docker | sh
# 安装docker镜像加速器
curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s http://00ff2cb2.m.daocloud.io
```

## 建好volume目录
```bash
mkdir /data/docker_volumes
```

## 运行registry镜像
```bash
docker run -d --restart=always  --name registry -p 5000:5000  -v /data/docker_volumes/registry:/var/lib/registry  registry
```


## 搭建nginx代理配置
以下` registry.oakdb.com`换为你的域名及https证书.
```bash
## registry.oakdb.com 配置



server {
    listen 80;
    server_name registry.oakdb.com;

    return      301 https://$server_name$request_uri;
}


server {
    listen 443;
    server_name registry.oakdb.com;

    ssl on;
    ssl_certificate /etc/nginx/certs/registry.oakdb.com/registry.oakdb.com.crt; # https证书
    ssl_certificate_key /etc/nginx/certs/registry.oakdb.com/registry.oakdb.com.key; # https证书

    #proxy_set_header Host       $http_host;   # required for Docker client sake
    #proxy_set_header X-Real-IP  $remote_addr; # pass on real client IP

    client_max_body_size 0; # disable any limits to avoid HTTP 413 for large image uploads

    # required to avoid HTTP 411: see Issue #1486 (https://github.com/dotcloud/docker/issues/1486)
    chunked_transfer_encoding on;

    location / {
        auth_basic              "Restricted";
        auth_basic_user_file    /etc/nginx/htpasswd/docker-registry.htpasswd;  #用户密码文件

        proxy_pass http://localhosthost:5000;
    }
}
```

## 绑定域名
恭喜成功了！
