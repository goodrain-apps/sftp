FROM debian:jessie
MAINTAINER zhouyq@goodrain.com

RUN groupadd -g 200 www-data && useradd -u 200 -g 200 www-data

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install git openssh-server php5-fpm nginx && \
    rm -rf /var/lib/apt/lists/*
    

RUN  mkdir -p /opt/ && \
     cd /opt && \
     git clone --depth=1  https://github.com/kalcaddle/KODExplorer.git && \
     mv KODExplorer VolumeExplorer
     
# sshd needs this directory to run
RUN mkdir -p /var/run/sshd
VOLUME /data
COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint /
COPY README.md /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
