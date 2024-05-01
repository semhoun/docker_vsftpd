![License](https://img.shields.io/github/license/semhoun/docker_vsftpd) ![OpenIssues](https://img.shields.io/github/issues-raw/semhoun/docker_vsftpd) ![Version](https://img.shields.io/github/v/tag/semhoun/docker_vsftpd) ![Docker Size](https://img.shields.io/docker/image-size/semhoun/vsftpd) ![Docker Pull](https://img.shields.io/docker/pulls/semhoun/vsftpd)

# vsftpd
Dockerfile to create containers with vsftpd service.

## 🧾 Components
 - Debian
 - vsftpd

## 🔗 References
https://github.com/semhoun/docker-vsftpd

## ⚙️ Environment variables
This image uses environment variables to allow the configuration of some parameters at run time:

* Variable name: `USERS`
* Default value: `admin|<ramdom password>||ro`
* Accepted values: `name1|password1|[folder1][|<rw|ro>] name2|password2|[folder2][|<rw|ro>]`
* Description: List of user separated by a space, user list will be exportted on STDOUT.  If folder is not specified it will be `/ftp/<name/`.
* Exemple:
  * `user|password foo|bar|/ftp/foo`
  * `user|password|/ftp/userddir|rw`
  * `user|password||ro`

----

* Variable name: `FTP_BANNER`
* Default value:  Welcome to My FTP Server
* Accepted values: any string
* Description: Banner message the vsftpd server displays when the ftp or sftp client connects to the server.

----
* Variable name: `USER_ID`
* Default value: 33
* Accepted values: any integer
* Description: vsftpd user id.

----

* Variable name: `GROUP_ID`
* Default value: 33
* Accepted values: any integer
* Description: vsftpd group id.

----

* Variable name: `DATA_PORT`
* Default value: 20
* Accepted values: any integer
* Description: FTP data port.

----

* Variable name: `FTP_PORT`
* Default value: 21
* Accepted values: any integer
* Description: FTP port.

----

* Variable name: `PASV_ADDRESS`
* Default value: Docker host IP / Hostname.
* Accepted values: Any IPv4 address or Hostname (see PASV_ADDRESS_RESOLVE).
* Description: If you don't specify an IP address to be used in passive mode, the routed IP address of the Docker host will be used. Bear in mind that this could be a local address.

----

* Variable name: `PASV_ADDR_RESOLVE`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to use a hostname (as opposed to IP address) in the PASV_ADDRESS option.

----

* Variable name: `PASV_ENABLE`
* Default value: YES
* Accepted values: <NO|YES>
* Description: Set to NO if you want to disallow the PASV method of obtaining a data connection.

----

* Variable name: `PASV_MIN_PORT`
* Default value: 21100
* Accepted values: Any valid port number.
* Description: This will be used as the lower bound of the passive mode port range. Remember to publish your ports with `docker -p` parameter.

----

* Variable name: `PASV_MAX_PORT`
* Default value: 21110
* Accepted values: Any valid port number.
* Description: This will be used as the upper bound of the passive mode port range. It will take longer to start a container with a high number of published ports.

----

* Variable name: `PASV_PROMISCUOUS`
* Default value: NO
* Accepted values: <NO|YES>
* Description: Set to YES if you want to disable the PASV security check that ensures the data connection originates from the same IP address as the control connection. Only enable if you know what you are doing! The only legitimate use for this is in some form of secure tunnelling scheme, or perhaps to facilitate FXP support.

----

* Variable name: `FILE_OPEN_MODE`
* Default value: 0666
* Accepted values: File system permissions.
* Description: The permissions with which uploaded files are created. Umasks are applied on top of this value. You may wish to change to 0777 if you want uploaded files to be executable.

----

* Variable name: `LOCAL_UMASK`
* Default value: 077
* Accepted values: File system permissions.
* Description: The value that the umask for file creation is set to for local users. NOTE! If you want to specify octal values, remember the "0" prefix otherwise the value will be treated as a base 10 integer!

----

Use cases
----

1) Create a temporary container for testing purposes:

```bash
  docker run --rm semhoun/vsftpd
```

2) Create a container in active mode using the default user account, with a binded data directory:

```bash
docker run -d -p 21:21 -v /my/data/directory:/tmp --name vsftpd semhoun/vsftpd
# see logs for accounts:
docker logs vsftpd
```

3) Create a **production container** with a custom user account, binding a data directory and enabling both active and passive mode:

```bash
docker run -d -v /my/data/directory:/ftp \
-p 20:20 -p 21:21 -p 21100-21110:21100-21110 \
-e USERS="user|p@ssw0rd|/ftp/user/|rw" -e FTP_PASS=mypass \
-e PASV_ADDRESS=127.0.0.1 -e PASV_MIN_PORT=21100 -e PASV_MAX_PORT=21110 \
--name vsftpd --restart=always fauria/vsftpd
```

4) Create a **production container** with a custom user account, binding a data directory and enabling both active and passive mode (Docker Compose version):
```bash
services:
  vsftpd:
    image: semhoun/vsftpd
    restart: always
    environment:
      USERS: "user|p@ssw0rd|/ftp/user/|rw"
      BANNER: "Welcome to Semhoun vsFTP"
      PASV_ADDRESS: "192.168.13.1"
      PASV_MIN_PORT: 21000
      PASV_MAX_PORT: 21010
    ports:
      - 20:20
      - 21:21
      - 21000-21010:21000-21010
    volumes:
      - ./data:/ftp
```