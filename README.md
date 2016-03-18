sftp 应用
==========

> 基于[OpenSSH](https://en.wikipedia.org/wiki/OpenSSH) 实现的一个 简单的 SFTP ([SSH 文件传输协议 ](https://en.wikipedia.org/wiki/SSH_File_Transfer_Protocol)) 应用。这个应用已经适配[好雨云](https://www.goodrain.com) 支持一键部署，可以在云应用市场体验安装。同样该应用也可以在本地运行，具体运行方法参见下文详细介绍。

<a href="http://app.goodrain.com/app/36/" target="_blank" ><img src="http://www.goodrain.com/images/deploy/button_160125.png" width="147" height="32"></img></a>


# 目录
- [部署到好雨云](#部署到好雨云)
  - [一键部署](#一键部署)
  - [关联其他应用](#与应用关联)
  - [连接sftp服务](#连接sftp服务)
- [部署到本地](#部署到本地)
  - [拉取或构建镜像](#拉取或构建镜像)
      - [拉取镜像](#拉取镜像)
      - [构建镜像](#构建镜像)
      - [运行与连接](#运行与连接)
- [项目参与和讨论](#项目参与和讨论)


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
