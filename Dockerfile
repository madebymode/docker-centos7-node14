FROM centos:7
MAINTAINER madebymode

ARG HOST_USER_UID=1000
ARG HOST_USER_GID=1000

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN rpm -Uvh https://repo.ius.io/ius-release-el7.rpm

# Update and install latest packages and prerequisites
RUN yum update -y \
    && yum install -y --nogpgcheck --setopt=tsflags=nodocs \
    curl \
    wget \
    gcc-c++ \
    make \
    git \
    ssh

RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash -

RUN curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo

RUN yum install -y nodejs \
    yarn \
    && yum clean all && yum history new

# install bower
RUN npm install --global bower

RUN echo 'Creating notroot docker user and group from host' && \
    groupadd -g $HOST_USER_GID docker && \
    useradd -lm -u $HOST_USER_UID -g $HOST_USER_GID docker

# give docker user sudo access
RUN usermod -aG wheel docker
# give docker user access to /dev/stdout and /dev/stderror
RUN usermod -aG tty docker

# Ensure sudo group users are not
# asked for a password when using
# sudo command by ammending sudoers file
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER docker
