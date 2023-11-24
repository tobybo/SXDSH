# sxdsh
多人在线修仙游戏：散修的生活卷一 灵风城

该游戏为 CS 架构，服务器客户端都是基于 [skynet](https://github.com/cloudwu/skynet) 作为引擎框架进行开发的。

AI支持调用的百度千帆大模型平台提供的[ERNIE-Bot 4.0](https://cloud.baidu.com/doc/WENXINWORKSHOP/s/clntwmv7t)。
## 服务器安装（需先自行安装好 docker 以及 docker-compose）
- 下载仓库
  - git clone https://github.com/tobybo/sxdsh.git sxdsh   
  - cd sxdsh
- 获取百度千帆 api 的 access_token，已经有 ak 的可以忽略这一步。也可以通过[其他方式](https://cloud.baidu.com/doc/WENXINWORKSHOP/s/Ilkkrb0i5)拿到 ak
  - python3 request_ak.py API_KEY API_SECRET_KEY
- 配置 access_token
  - echo 'access_token = "xxx"' > game/etc/access_token   # xxx 即为上一步获取到的 ak
- 配置我搭建的一个镜像站到 docker 的镜像站白名单中，有经验的同学可以配置 server.yml 修改镜像 url，就不需要从我这个站拉取了，我搭这个是为了方便
  - vim /etc/docker/daemon.json
  ```
  {
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "200m",
        "max-file": "5"
    },
    "insecure-registries": [
        "http://www.tobybo.life:5000"
    ]
  }
- 启动服务器
  - 后台模式  

    docker-compose -f server.yml up -d
    
  - 前台模式

    docker-compose -f server.yml up -d mongo   # 先启动mongo服务
    docker-compose -f server.yml up game       # 前台模式启动game
    
  - 启动失败处理

    通过前台模式启动可以直接看到报错信息，如果是端口冲突，修改一下 game/etc/config 和 server.yml 中的端口配置，接纳客户端的端口配置在 server.yml 中，skynet 自身基础服务会占用几个端口配置在 game/etc/config 中

  - 启动成功效果图（前台模式直接能看到，后台模式可以用 docker logs -f --tail 10 game 来跟踪日志）

    ![image](https://github.com/tobybo/sxdsh/assets/28852169/e39e2fe0-3a30-41c5-a83e-f0cd496613f1)


## 客户端安装（需先自行安装好 docker 以及 docker-compose）

- 下载仓库（安装过服务器就可以跳过这一步）
  - git clone https://github.com/tobybo/sxdsh.git sxdsh   
  - cd sxdsh
- 编辑 client.yml 修改其中的 SERVER_HOST 和 SERVER_PORT 为你启动的服务器 IP 和端口（按默认配置启动的服务器，就不需要动）
- 启动客户端

    docker-compose -f client.yml run -T client

- 启动成功效果

    ![image](https://github.com/tobybo/sxdsh/assets/28852169/469594cb-b8d3-4a40-a9f8-c275b1b0b8bf)

## 项目目录介绍
为了尽量不影响到 skynet 本身，业务脚本都单独放在 game 目录下开发。skynet 目前只额外增加了一个 lua-cjson 的第三方库支持，启用了 lts 库支持，用于发起https请求和处理百度api返回的http消息。
![image](https://github.com/tobybo/sxdsh/assets/28852169/e7423ae1-7f4a-4f4f-9b74-c7cdb4a382ab)



## 世界观简介
![世界设定](https://github.com/tobybo/sxdsh/assets/28852169/90ace002-6149-4a15-83be-2d4a7db4a0ca)
## 角色设定
![角色设定](https://github.com/tobybo/sxdsh/assets/28852169/5cad216c-e4fc-4dce-8d95-8b2a5bd41193)

