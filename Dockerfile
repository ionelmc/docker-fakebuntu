FROM ubuntu:xenial-20170410

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
        openssh-server systemd \
        locales tzdata wget \
        strace gdb lsof locate net-tools htop iputils-ping dnsutils \
        python2.7-dbg python2.7 libpython2.7 python-dbg libpython-dbg \
        python-svn \
        curl nano vim tree less \
 && bash -o pipefail -c "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -" \
 && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
 && add-apt-repository ppa:ionel-mc/socat \
 && apt-get update \
 && apt-get install -y --no-install-recommends docker-ce socat=1.7.3.1-1ionelmc1~ppa1 \
 && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV TERM=xterm
ENV container docker

RUN locale-gen en_US.UTF-8

RUN find /etc/systemd/system \
         /lib/systemd/system \
         -path '*.wants/*' \
         -not -name '*journald*' \
         -not -name '*docker*' \
         -not -name '*ssh*' \
         -not -name '*pwr*' \
         -not -name '*systemd-tmpfiles*' \
         -not -name '*systemd-user-sessions*' \
         -exec rm \{} \;
RUN systemctl set-default multi-user.target
RUN echo 'ForwardToConsole=yes' >> /etc/systemd/journald.conf
RUN echo 'MaxLevelConsole=info' >> /etc/systemd/journald.conf
RUN echo 'SplitMode=none' >> /etc/systemd/journald.conf
RUN echo 'Storage=volatile' >> /etc/systemd/journald.conf
RUN echo 'TTYPath=/dev/console' >> /etc/systemd/journald.conf
VOLUME ["/storage"]
STOPSIGNAL "PWR"
ADD entrypoint.sh /
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/sbin/init", "--log-target=journal", "--log-level=info"]
