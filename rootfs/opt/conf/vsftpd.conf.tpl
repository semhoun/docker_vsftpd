background=NO

# Interdire les connexions anonymes au serveur
anonymous_enable=NO
anon_upload_enable=YES
anon_mkdir_write_enable=YES
anon_other_write_enable=YES

# Autoriser les utilisateurs locaux (obligatoire même si on ne veut que des utilisateurs virtuels)
local_enable=YES

# Autoriser les utilisateurs virtuels
user_config_dir=/etc/vsftpd/vsftpd_user_conf
guest_enable=YES
virtual_use_local_privs=YES
pam_service_name=vsftpd
nopriv_user=ftp
guest_username=ftp
userlist_enable=NO

# On définit les droits par défaut des fichiers uploadés
local_umask={{ .Env.LOCAL_UMASK }}
file_open_mode={{ .Env.FILE_OPEN_MODE }}

# On défini le nombre maximum de sessions à 200 (les nouveaux clients recevront
# un message du genre: "erreur : serveur occupé").
# On défini le nombre maximum de sessions par IP à 4
max_clients=200
max_per_ip=4

# activation des logs
xferlog_enable=YES
xferlog_std_format=NO
vsftpd_log_file=/var/log/vsftpd_logger

ftpd_banner="{{ .Env.FTP_BANNER }}"

listen=YES
tcp_wrappers=YES
connect_from_port_20=YES
ftp_data_port={{ .Env.DATA_PORT }}
listen_port={{ .Env.FTP_PORT }}

pasv_enable={{ .Env.PASV_ENABLE }}
pasv_address={{ .Env.PASV_ADDRESS }}
pasv_addr_resolve={{ .Env.PASV_ADDR_RESOLVE }}
pasv_promiscuous={{ .Env.PASV_PROMISCUOUS }}
pasv_min_port={{ .Env.PASV_MIN_PORT }}
pasv_max_port={{ .Env.PASV_MAX_PORT }}

data_connection_timeout=120

# Configuration de l’authentification
secure_chroot_dir=/var/run/vsftpd
allow_writeable_chroot=YES
chroot_local_user=YES

# SSL
ssl_enable=NO
