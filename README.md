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

选择需要挂载的应用，点击 “挂载” 按钮，管理成功后需要**重启**sftp应用。

## 连接sftp应用
sftp 应用的**连接地址**和**端口**可以在应用的**高级页面**找到，如下图：

- sftp连接地址

<img src="https://github.com/goodrain-apps/sftp/blob/master/img/sftp-link.png" width="50%" height="50%")/>

- sftp连接用户和密码
sftp的连接密码可以在应用首页找到

<img src="https://github.com/goodrain-apps/sftp/blob/master/img/sftp-info.png" width="50%" height="50%")/>

- 连接sftp应用
使用sftp客户端(FileZilla)连接sftp应用

<img src="https://github.com/goodrain-apps/sftp/blob/master/img/sftp-client.png" width="50%" height="50%")/>

连接成功后会自动列出/mnt 下的应用名称

<img src="https://github.com/goodrain-apps/sftp/blob/master/img/sftp-connected.png" width="50%" height="50%")/>

这些目录就是挂载的应用/data 目录内容




Usage
-----

- Define users as command arguments, STDIN or mounted in /etc/sftp-users.conf
  (syntax: `user:pass[:e][:uid[:gid]]...`).
  - You must set custom UID for your users if you want them to make changes to
    your mounted volumes with permissions matching your host filesystem.
- Mount volumes in user's home folder.
  - The users are chrooted to their home directory, so you must mount the
    volumes in separate directories inside the user's home directory
    (/home/user/**mounted-directory**).

Examples
--------

### Simple example

```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo:123:1001
```

#### Using Docker Compose:

```
sftp:
    image: atmoz/sftp
    volumes:
        - /host/share:/home/foo/share
    ports:
        - "2222:22"
    command: foo:123:1001
```

#### Logging in

The OpenSSH server runs by default on port 22, and in this example, we are
forwarding the container's port 22 to the host's port 2222. To log in with an
OpenSSH client, run: `sftp -P 2222 foo@<host-ip>`

### Store users in config

```
docker run \
    -v /host/users.conf:/etc/sftp-users.conf:ro \
    -v /host/share:/home/foo/share \
    -v /host/documents:/home/foo/documents \
    -v /host/http:/home/bar/http \
    -p 2222:22 -d atmoz/sftp
```

/host/users.conf:

```
foo:123:1001
bar:abc:1002
```

### Encrypted password

Add `:e` behind password to mark it as encrypted. Use single quotes.

```
docker run \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    'foo:$1$0G2g0GSt$ewU0t6GXG15.0hWoOX8X9.:e:1001'
```

Tip: you can use makepasswd to generate encrypted passwords:  
`echo -n "password" | makepasswd --crypt-md5 --clearfrom -`

### Using SSH key (without password)

Mount all public keys in the user's `.ssh/keys/` folder. All keys are automatically
appended to `.ssh/authorized_keys`.

```
docker run \
    -v /host/id_rsa.pub:/home/foo/.ssh/keys/id_rsa.pub:ro \
    -v /host/id_other.pub:/home/foo/.ssh/keys/id_other.pub:ro \
    -v /host/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo::1001
```
