sftp 应用
==========

> 基于[OpenSSH](https://en.wikipedia.org/wiki/OpenSSH) 实现的一个 简单的 SFTP ([SSH 文件传输协议 ](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol)) 应用。该应用主要解决用户上传或下载大文件的问题，通过关联其它应用的方式将其它应用的/data目录挂载到sftp应用的/mnt 目录下，这样可以借助sftp服务作为桥梁来操作其它应用内部的文件。应用已经适配[好雨云](https://www.goodrain.com) 的一键部署功能，可以在云应用市场体验安装。同样也可以在本地运行，具体运行方法参见下文详细介绍。

<a href="http://app.goodrain.com/app/36/" target="_blank" ><img src="http://www.goodrain.com/images/deploy/button_160125.png" width="147" height="32"></img></a>


# 目录
- [应用工作原理](#应用工作原理)
- [部署到好雨云](#部署到好雨云)
  - [一键部署](#一键部署)
  - [关联其他应用](#与应用关联)
  - [连接sftp应用](#连接sftp应用)
- [部署到本地](#部署到本地)
  - [拉取或构建镜像](#拉取或构建镜像)
      - [拉取镜像](#拉取镜像)
      - [构建镜像](#构建镜像)
      - [运行与连接](#运行与连接)
- [项目参与和讨论](#项目参与和讨论)


# 应用工作原理
![elk](https://github.com/goodrain-apps/sftp/blob/master/img/sftp.png)


# 部署到好雨云
## 一键部署
通过点击本文最上方的 “安装到好雨云” 按钮会跳转到 好雨应用市场的应用首页中，可以通过一键部署按钮安装

## 关联其它应用
安装好sftp应用后，可以在应用的 “关联” 页面看到可以挂载的其它应用，如下图：

<img src="https://github.com/goodrain-apps/sftp/blob/master/img/sftp-mount.png" width="50%" height="50%")/>

选择需要挂载的应用，点击 “挂载” 按钮，关联成功后需要**重启**sftp应用。

## 连接sftp应用
sftp 应用的**连接地址**和**端口**可以在应用的**高级页面**找到，如下图：

- sftp连接地址

<img src="https://github.com/goodrain-apps/sftp/blob/master/img/sftp-link.png" width="50%" height="50%")/>

- sftp连接用户和密码
sftp的连接密码可以在应用首页找到

<img src="https://github.com/goodrain-apps/sftp/blob/master/img/sftp-info.png" width="50%" height="50%")/>

- 连接sftp应用
使用sftp客户端(FileZilla)连接sftp应用

<img src="https://github.com/goodrain-apps/sftp/blob/master/img/sftp-client.png" width="70%" height="70%")/>

连接成功后会自动列出/mnt 下的应用名称

<img src="https://github.com/goodrain-apps/sftp/blob/master/img/sftp-connected.png" width="70%" height="70%")/>

这些目录就是挂载的应用/data 目录内容

# 部署到本地
## 拉取或构建镜像
### 拉取镜像

```
docker pull goodrain.me/sftp:latest
```
### 构建镜像

```
git  clone https://github.com/goodrain-apps/sftp.git
cd sftp

docker build -t sftp .
```

### 运行与连接
- 可以在启动容器时指定参数来创建登陆用户和密码，参数格式（`user:pass[:e][:uid[:gid]]...`）
- 可以通过将外部文件挂载到`/etc/sftp-users.conf`的形式来持久化存储用户信息
- 用户的根目录是/mnt 不能切换到其它目录

#### 简单示例
```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d sftp \
    foo:123:1001
```

##### 使用 Docker Compose 启动:

```
sftp:
    image: sftp
    volumes:
        - /host/share:/home/foo/share
    ports:
        - "2222:22"
    command: foo:123:1001
```


##### 登陆

OpenSSH 服务默认监听22端口，在下面的示例中我们将22端口映射到宿主机的2222端口使用OpenSSH客户端连接命令：
`sftp -P 2222 foo@<host-ip>`

#### 在配置文件中存储用户

```
docker run \
    -v /host/users.conf:/etc/sftp-users.conf:ro \
    -v /host/share:/home/foo/share \
    -v /host/documents:/home/foo/documents \
    -v /host/http:/home/bar/http \
    -p 2222:22 -d sftp
```

/host/users.conf 内容:

```
foo:123:1001
bar:abc:1002
```

### 设置加密的密码

在启动容器时在密码的后面添加 `:e` 标记，代表我输入的密码是加密后的信息：

```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d sftp \
    'foo:$1$0G2g0GSt$ewU0t6GXG15.0hWoOX8X9.:e:1001'
```

提示: 你可以使用 `makepasswd` 命令来生成加密的密码:  
`echo -n "password" | makepasswd --crypt-md5 --clearfrom -`

### 使用 SSH key (不使用密码)

将公钥文件挂载到mnt目录的`.ssh/keys/` 文件夹下，这样所有的key会自动添加到 `.ssh/authorized_keys` 文件中。

```
docker run \
    -v /host/id_rsa.pub:/home/foo/.ssh/keys/id_rsa.pub:ro \
    -v /host/id_other.pub:/home/foo/.ssh/keys/id_other.pub:ro \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d sftp \
    foo::1001
```


# 项目参与和讨论



