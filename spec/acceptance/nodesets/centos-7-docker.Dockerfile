FROM centos:7
MAINTAINER puppet-jenkins
ENV container docker

# beaker default behavior
RUN yum clean all
RUN yum install -y sudo openssh-server openssh-clients curl ntpdate
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key
RUN mkdir -p /var/run/sshd
RUN echo root:root | chpasswd
RUN sed -ri 's/^#?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -ri 's/^#?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
RUN yum install -y crontabs tar wget
EXPOSE 22

# based on https://github.com/slafs/dockerfiles/blob/master/centos7-systemd/Dockerfile
RUN yum -y swap -- remove fakesystemd -- install systemd systemd-libs
RUN systemctl mask dev-mqueue.mount dev-hugepages.mount \
    systemd-remount-fs.service sys-kernel-config.mount \
    sys-kernel-debug.mount sys-fs-fuse-connections.mount \
    display-manager.service systemd-logind.service
RUN systemctl disable graphical.target; systemctl enable multi-user.target
RUN systemctl enable sshd.service
VOLUME ["/sys/fs/cgroup"]

# provides /usr/sbin/service required by the service redhat provider
RUN yum install -y initscripts

CMD  ["/usr/lib/systemd/systemd"]
