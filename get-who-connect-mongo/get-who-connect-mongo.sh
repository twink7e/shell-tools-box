#!/bin/bash

MONGO_IPS="192.168.11.105 192.168.21.105"
MONGO_PORT=27017


GET_APP_NAME_CSV="get_who_connection_mongo_app_name.csv"
GET_APP_NAME_FAILED_CSV="get_who_connection_mongo_app_name_failed.csv"


GET_PID_FAILED_CSV="get_pid_failed.csv"


shopt -s expand_aliases
alias scp="scp -o StrictHostKeyChecking=no"
alias ssh="ssh -o StrictHostKeyChecking=no"
alias pscp="pscp -O StrictHostKeyChecking=no"
alias pssh="pssh -O StrictHostKeyChecking=no"

function err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [ERROR]: $@" >&2
  [ -n "$LOG_FILE" ] && echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [ERROR]: $@" >> ${LOG_FILE}
}
function info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [INFO]: $@" >&1
  [ -n "$LOG_FILE" ] && echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [INFO]: $@" >> ${LOG_FILE}
}
function die(){
    err $1
    exit 1
}

function handle_get_app_name_failed(){
    local host=$1
    local port=$2
    local pid=$3
    echo "${host}, ${port}, ${pid}" >> $GET_APP_NAME_FAILED_CSV
}

function get_app_name_from_host_and_port(){
    local host=$1
    local port=$2
    local mip=$3

    local pid=$(ssh root@$host "netstat -antp |grep ${port} | grep $mip | grep ESTABLISHED | awk '{print \$7}' | awk -F '/' '{print \$1}'") || die "fetch host $port:$port pid failed."
    info "get pid from $host, pid: $pid"
    if [ ! -n "$pid" ];then
        echo "$host, $port" >> $GET_PID_FAILED_CSV
        return 1
    fi
    local app_name=$(ssh root@$host "ps aux | grep -v grep |grep ${pid}  | grep -o   'Dapp\.name=[^ ]*' | awk -F '=' '{print \$2}'") || handle_get_app_name_failed $host $port $pid
    if [ ! -n "$app_name" ];then
        handle_get_app_name_failed $host $port $pid
        return
    fi
    echo "${host}, ${port}, ${app_name}" >> $GET_APP_NAME_CSV

}



for mip in $MONGO_IPS;do
    info "##### start with mongo host $mip"
    mongo_connections=$(ssh root@$mip "netstat -antp |grep ${mip}:${MONGO_PORT} | awk '{print \$5}'") || die "get mongo connection from $mip failed."

    for host_and_port in $mongo_connections;do
        info "#### get connection form $host_and_port"
        h=$(echo $host_and_port | awk -F ':' '{print $1}')
        p=$(echo $host_and_port | awk -F ':' '{print $2}')
        get_app_name_from_host_and_port $h $p $mip
    done
done
