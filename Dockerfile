FROM debian:bookworm-slim

ENV USERS **String**

ENV FTP_BANNER "Welcome to My FTP Server"

ENV USER_ID 33
ENV GROUP_ID 33

ENV DATA_PORT 20
ENV FTP_PORT 21

ENV PASV_ENABLE YES
ENV PASV_ADDRESS **IPv4**
ENV PASV_ADDR_RESOLVE NO
ENV PASV_PROMISCUOUS NO
ENV PASV_MIN_PORT 21000
ENV PASV_MAX_PORT 21010

ENV FILE_OPEN_MODE 0666
ENV LOCAL_UMASK 077

RUN apt-get update -y \
  && apt-get install -y db5.3-util vsftpd wget iproute2 \
  \
  # Fix forder and right
  && mkdir -p /ftp \
  && chmod 755 /ftp \
  && mkdir -p /etc/vsftpd/vsftpd_user_conf \
  && mkdir -p /var/run/vsftpd/ \
  \
  # Remove ununsed users
  && userdel mail \
  && userdel news \
  && userdel uucp \
  && userdel proxy \
  && userdel www-data \
  && userdel backup \
  && userdel list \
  && userdel irc \
  && userdel ftp \
  \
  # Dockerize \
  \
  && wget -O - https://github.com/jwilder/dockerize/releases/download/v0.7.0/dockerize-linux-amd64-v0.7.0.tar.gz | tar xzf - -C /usr/local/bin \
  # Cleaning \
  && apt-get -y purge \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY rootfs/ /

VOLUME /ftp

CMD ["/usr/sbin/vsftpd"]
ENTRYPOINT ["/opt/bin/docker-entrypoint.sh"]
