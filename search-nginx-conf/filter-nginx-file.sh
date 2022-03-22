#!/bin/bash


cmdline=$@

function filter_nginx_conf(){
    local node=$1
    local config_names=$2

    echo "##### $node #####"
    ssh $node "egrep $cmdline $config_names || exit 0"
}

# while read line
# do
#     node=$(echo $line | awk -F '|' '{print $1}')
#     rootdir=$(echo $line | awk -F '|' '{print $2}')
#     config_names=$(echo $line | awk -F '|' '{print $3}')
#     filter_nginx_conf $node "$config_names"
#
# done < nginx-configs.list


IFS=\n
IFS=$(echo -en "\n\b")

for line in $( cat nginx-configs.list);do
    node=$(echo $line | awk -F '|' '{print $1}')
    rootdir=$(echo $line | awk -F '|' '{print $2}')
    config_names=$(echo $line | awk -F '|' '{print $3}')
    filter_nginx_conf $node "$config_names"
done
