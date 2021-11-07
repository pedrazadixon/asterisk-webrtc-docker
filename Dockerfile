FROM centos:centos7.9.2009
MAINTAINER trabajo_de_grado_ucc <jonathan.pedraza@campusucc.edu.co>

RUN useradd --system asterisk

RUN yum install -y --no-install-recommends \
            autoconf \
            binutils-dev \
            build-essential \
            ca-certificates \
            curl \
            libcurl4-openssl-dev \
            libedit-dev \
            libgsm1-dev \
            libjansson-dev \
            libogg-dev \
            libpopt-dev \
            libresample1-dev \
            libspandsp-dev \
            libspeex-dev \
            libspeexdsp-dev \
            libsqlite3-dev \
            libsrtp0-dev \
            libssl-dev \
            libvorbis-dev \
            libxml2-dev \
            libxslt1-dev \
            portaudio19-dev \
            python-pip \
            unixodbc-dev \
            uuid \
            uuid-dev \
            xmlstarlet \
            && \
            yum purge -y --auto-remove

ENV ASTERISK_VERSION=15.5.0
COPY etc /tmp/etc
COPY var /tmp/var
COPY install.sh /tmp/install.sh
RUN /tmp/install.sh
