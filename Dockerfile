FROM debian:jessie
MAINTAINER zhouyq@goodrain.com


RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/*
    
   
# sshd needs this directory to run
RUN mkdir -p /var/run/sshd
VOLUME /data
COPY sshd_config /etc/ssh/sshd_config
COPY entrypoint /

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
CMD ["/usr/bin/sshd","-D"]
