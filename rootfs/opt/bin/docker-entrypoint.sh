#!/bin/bash

if getent passwd ftp > /dev/null 2>&1; then
  deluser ftp
fi
groupadd -g $GROUP_ID ftp
useradd -d /ftp -u $USER_ID  -g ftp -M -s /usr/sbin/nologin ftp > /dev/null

if [ "$FTP_USERS" = "**String**" ]; then
  export FTP_PASS=`cat /dev/urandom | tr -dc A-Z-a-z-0-9 | head -c${1:-16}`
  export FTP_USERS="admin|${FTP_PASS}||ro"
fi

if [ "$PASV_ADDRESS" = "**IPv4**" ]; then
    export PASV_ADDRESS=$(/sbin/ip route|awk '/default/ { print $3 }')
fi

> /tmp/login.cfg
> /tmp/login.txt

for i in $USERS ; do
  NAME=$(echo $i | cut -d'|' -f1)
  PASS=$(echo $i | cut -d'|' -f2)
  FOLDER=$(echo $i | cut -d'|' -f3)
  TYPE=$(echo $i | cut -d'|' -f4)

  if [ -z "$FOLDER" ]; then
    FOLDER="/ftp/$NAME"
  fi

  mkdir -p $FOLDER
  chown ftp:ftp $FOLDER

  cat >> /tmp/login.cfg << EOF
$NAME
$PASS
EOF


  echo " - [${NAME}]" >> /tmp/login.txt
  echo "   - Login: ${NAME}" >> /tmp/login.txt
  echo "   - Password: ${PASS}" >> /tmp/login.txt
  echo "   - Folder: ${FOLDER}" >> /tmp/login.txt
  if [ "rw" = "$TYPE" ]; then
	echo "   - Mode: Read/Write" >> /tmp/login.txt
    cat > /etc/vsftpd/vsftpd_user_conf/$NAME << EOF
write_enable=YES
local_root=$FOLDER
anon_world_readable_only=NO
EOF
  else
	echo "   - Mode: Read only" >> /tmp/login.txt
    cat > /etc/vsftpd/vsftpd_user_conf/$NAME << EOF
write_enable=NO
local_root=$FOLDER
EOF
  fi
  
  unset NAME PASS FOLDER TYPE
done

dockerize -template /opt/conf/vsftpd.conf.tpl:/etc/vsftpd.conf
echo "#> Updated vsftpd configuration"

db5.3_load -T -t hash -f /tmp/login.cfg /etc/vsftpd/login.db
echo "#> Updated vsftpd database"

if [ "$@" == "/usr/sbin/vsftpd" ]; then
  # Log pipe error
  NAMED_PIPED="/var/log/vsftpd_logger"
  rm -rf "$NAMED_PIPED" || true
  mkfifo --mode 666 "${NAMED_PIPED}" || true
  echo "#> Named pipe: ($NAMED_PIPED) creation done"
  (tail -f ${NAMED_PIPED} > /proc/self/fd/1 || pkill vsftpd) &
else
  echo "#> Skipping named pipe"
fi

echo "#> User list"
cat /tmp/login.txt
rm -f /tmp/login.txt /tmp/login.cfg

exec "$@"
