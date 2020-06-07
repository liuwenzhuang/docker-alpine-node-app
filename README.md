Alpine Linux 是一个面向安全，轻量级的基于musl libc与busybox项目的Linux发行版，其具有安全、简单以及资源效率的特点。在docker中，如果对体积、安全性的考虑，那么alpine环境是一个比较好的选择，以node环境来说，如果以`node:12-stretch`构建一个应用，大概有将近900M+的体积；如果使用`node:12-alpine`，则体积会锐减到90M+；如果使用`alpine`构建应用，则体积还能够减到50M+。

## 使用alpine构建node应用

```Dockerfile
FROM alpine:3.10

# 如果有网络问题，启用下面一行更换清华镜像
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN apk update
RUN apk add nodejs

RUN addgroup -S node && adduser -S node -G node

USER node

RUN mkdir /home/node/app

WORKDIR /home/node/app

COPY --chown=node:node package.json package-lock.json ./

RUN npm ci

COPY --chown=node:node . .

CMD ["node", "index.js"]
```

> 上面分两次进行`COPY`动作是为了充分利用docker的缓存机制，因为docker中的缓存和Dockerfile中的声明顺序息息相关，影响`npm ci`的执行结果只有package.json和package-lock.json，所以如果这两个文件没变，`npm ci`的结果就可以利用缓存，不必每次执行`docker build`都要从网络获取npm包。而如果先执行`COPY . .`，在执行`npm ci`，则任意文件变化都会导致`npm ci`重新从网络获取npm包。

## 打包、检查node应用

```bash
# 打包
$ docker build -t alpine-node-app .
# 查看体积
$ docker inspect alpine-node-app
```

> 通过测试，如果当前应用只依赖于`express`时，体积大概在50M左右。

## 运行应用

```bash
$ docker run -dit --init --rm -p 8085:8085 alpine-node-app
$ curl -i http://0.0.0.0:8085
```
