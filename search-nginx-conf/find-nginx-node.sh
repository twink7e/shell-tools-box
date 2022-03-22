#!/bin/bash

shopt -s expand_aliases
set -f
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

# 实现拼接绝对路径的逻辑
function get_absolute_config_name(){
    local rootdir=$1
    local filename=$2

    first_char_of_filename=$(echo $filename |  awk '{print substr($0,1,1)}')
    if [ "$first_char_of_filename" == "/" ];then
        echo $filename
    else
        echo "${rootdir}/${filename}"
    fi
}

function find_all_config_files(){
    local node=$1
    local rootdir=$2
    local config_name=$3
    # 处理include 带通配符的情况
    local has_wildcard=$(echo $config_name | grep '\*' -c )
    if [[ "$has_wildcard" != "0" ]];then
        first_char_of_filename=$(echo $config_name |  awk '{print substr($0,1,1)}')
        if [ "$first_char_of_filename" == "/" ];then
            local tmp_files=$(ssh $node "echo $config_name")
        else
            local tmp_files=$(ssh $node "echo ${rootdir}/${config_name}")
        fi
    else
        # 拼接绝对路径
        local config_name=$(get_absolute_config_name $rootdir $config_name)
        local config_files="${config_name} "
        local tmp_files="$(ssh root@${node} " egrep -E '^\s*include ' $config_name | awk '{print \$2}' " | tr -d ';')"
    fi

    for f in $tmp_files;do
        local deep_files=$(find_all_config_files $node $rootdir "$f")
        local config_files="$config_files $deep_files"
    done
    echo $config_files | tr -d "\n"
}


#for node in $(echo 192.168.30.11);do
for node in $(cat /home/admin/cluster/all_host);do
    pid=$(ssh root@${node} 'ps aux |grep -v grep | grep nginx | grep master | awk "{print \$2}"')
    if [ ! -n "$pid" ];then
        continue
    fi
    echo "######### $node ##########"
    cfg=$(ssh root@${node} "awk -F '-c' '{print \$2}' /proc/${pid}/cmdline ")
    if [ ! -n "$cfg" ];then
        cfg=$(ssh root@${node} "/proc/${pid}/exe -t 2>&1 | awk -F 'the configuration file' 'NR==1{print \$2}' | awk '{print \$1}'")
    fi
    if [ ! -n "$cfg" ];then
        die "get node: ${node} pid: ${pid} nginx config file failed."
    fi
    rootdir=$(dirname $cfg)
    nginx_files=$(find_all_config_files $node $rootdir $cfg)
    #find_all_config_files $node $rootdir $cfg
    echo "${node}|${rootdir}|${nginx_files}" >> nginx-configs.list
done
