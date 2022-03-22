#!/bin/bash

source ${OPS_COMMON_SCRIPTS}/lib/alert/send_sms.sh
source ${OPS_COMMON_SCRIPTS}/lib/log/basic.sh
source ${OPS_COMMON_SCRIPTS}/lib/args/basic-args-parser.sh


TYPE_DB_HOST=string
TYPE_DB_PORT=integer
TYPE_DB_USERNAME=string
TYPE_DB_PASSWORD=string
TYPE_DB_NAME=string

if [ ! -n "$*" ];then
    SHOW_USAGE=true
fi

basic_args_parser $*

function usage(){
    echo """
usage: $0 OPTIONNS

this program provides backup mysql database and upload to Aliyun OSS.

DATABASE OPTIONS:

--db-host           mysql database server host, default is localhost.
--db-port           mysql database server port, default is 3306.
--db-username       database username, default is root.
--db-password       database password, default is ''.
--db-name           backup which database.
OSS OPTIONS:
--oss-config        Aliyun OSS Config, default is $HOME/ossconfig.
--oss-upload-url    OSS URL eg: <oss-bucket>/mysql-backup/test
"""
}

if [ $SHOW_USAGE ];then
    usage
    exit 0
fi

if [ $SHOW_VERSION ];then
    echo "version 1.0"
    exit 0
fi

# set args default or check value.
DB_HOST=${DB_HOST:-localhost}
DB_PORT=${DB_HOST:-3306}
DB_USERNAME=${DB_USERNAME:-root}
DB_PASSWORD=${DB_PASSWORD:-""}

if [ ! -n "$DB_NAME" ];then
    die "database name can not be null."
fi

OSS_CONFIG=${OSS_CONFIG:-$HOME/ossconfig}

LOG_FILE="${basename}.log"


basename=$(date +'%Y-%m-%d_%H-%M-%S-%s')
basename="backup-${mysql_backup_databse}-${basename}"
sql_file="${basename}.sql"

# install mysqldump
if ! which mysqldump &> /dev/null;then
    yum -y install mysql || die "install mysql failed."
fi

# install ossutil
if ! which ossutil &> /dev/null;then
    curl http://gosspublic.alicdn.com/ossutil/1.7.7/ossutil64 -o /usr/local/bin/ossutil || die "download ossutil failed."
    chmod +x /usr/local/bin/ossutil
fi


cmd="mysqldump -u $mysql_username -p${mysql_password} -h $mysql_host --port $mysql_port $mysql_backup_databse > $sql_file"
info "start to dump db ${mysql_backup_databse}, cmd: ${cmd}" 

$cmd || die "dump db ${mysql_backup_databse} failed."

ossutil -c $oss_connfig  cp -r -f ${sql_file}.tgz $oss_upload_url || die "backup database failed: upload to oss failed.."
