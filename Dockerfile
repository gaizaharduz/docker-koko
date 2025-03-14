FROM ghcr.io/linuxserver/baseimage-ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ARG KOKO_RELEASE

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
    gcc \
    git \
    openssl \
    python \
    python-pip && \
 echo "**** install koko node env & npm ****" && \
 curl -o nodejs.deb https://deb.nodesource.com/node_8.x/pool/main/n/nodejs/nodejs_8.11.1-1nodesource1_amd64.deb && \
 dpkg -i ./nodejs.deb && \
 rm nodejs.deb && \
 rm -rf /var/lib/apt/lists/* && \
 apt-get install -y \
    npm && \
 echo "**** install lexigram-cli ****"  && \ 
 npm install -g lexigram-cli -unsafe && \
 echo "**** install koko skill & webserver ****" && \
 mkdir -p \
	/app/koko && \
 if [ -z ${KOKO_RELEASE+x} ]; then \
	KOKO_RELEASE=$(curl -sX GET "https://api.github.com/repos/m0ngr31/koko/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 curl -o \
 /tmp/koko.tar.gz -L \
	"https://github.com/m0ngr31/koko/archive/${KOKO_RELEASE}.tar.gz" && \
 tar xzf /tmp/koko.tar.gz --strip 1 -C \
 /app/koko/ && \
 cd /app/koko && \
 echo ${KOKO_RELEASE} > version.txt && \
 touch /app/koko/deployed-koko.txt && \
 pip install --no-cache-dir pip==9.0.3 && \
 pip install -r \
    requirements.txt \
    python-Levenshtein && \
 echo "**** cleanup ****" && \
 apt-get -y remove \
    gcc \
    git \
    npm && \
 apt-get -y autoremove && \
 rm -rf \
	/root/.cache \
	/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8000
VOLUME /config
