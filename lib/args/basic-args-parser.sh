#!/bin/bash


# 检查传入的$1变量的类型
function check_var_type(){
    local a="$1"
    if [ "$a" == "true" ] || [ "$a" == "false" ];then
        echo "bool"
        return
    fi
    if [ ! -n "$a" ];then
        echo "string"
        return
    fi
    printf "%d" "$a" &>/dev/null && echo "integer" && return
    printf "%d" "$(echo $a|sed 's/^[+-]\?0\+//')" &>/dev/null && echo "integer" && return
    printf "%f" "$a" &>/dev/null && echo "number" && return
    [ ${#a} -eq 1 ] && echo "char" && return
    echo "string"
}

set_option () {
    local option=$1
    local value=$2
    local expect_type=$3
    local var=$4
    # var=$(echo "$option" | tr abcdefghijklmnopqrstuvwxyz- ABCDEFGHIJKLMNOPQRSTUVWXYZ_)
    eval "local expect_type=\$TYPE_${var}"

    if [ ! -n "$expect_type" ];then
        echo "parse args $option failed not define type var: TYPE_${var} ."
        return 1
    fi
    local value_type=$(check_var_type $value)
    if [[ "$expect_type" != "$value_type" ]] && [[ "$expect_type" != "string" ]];then
        echo "parse args $option value failed: wrong type: $value_type need: $expect_type."
        return 2
    fi
    eval "local old_value=\$$var"
    if [ -n "$old_value" ];then
        echo "warning var $var value $old_value is overwritten."
    fi
    eval "$var=$value"
}


function basic_args_parser(){
    for arg in $* ;do
        case $arg in
        -h | --help)
            SHOW_USAGE=true
            continue
            ;;
        -V | --version)
            SHOW_VERSION=true
            continue
            ;;
        -*[a-z]*=*)
            local option=`expr "$arg" : '-*\([^=]*\)'`
            local value=`expr "$arg" : '[^=]*=\(.*\)'`
            local var=$(echo "$option" | tr abcdefghijklmnopqrstuvwxyz- ABCDEFGHIJKLMNOPQRSTUVWXYZ_)
            eval "local expect_type=\$TYPE_${var}"
            ;;
        -*[a-z]*)
            if [ -n "$option" ];then
                local value=true
                set_option $option $value $expect_type $var
            fi
            local option=`expr "$arg" : '-*\(.*\)'`
            local var=$(echo "$option" | tr abcdefghijklmnopqrstuvwxyz- ABCDEFGHIJKLMNOPQRSTUVWXYZ_)
            eval "local expect_type=\$TYPE_${var}"
            local value=true
            if [ "$expect_type" != "bool" ];then
                continue
            fi
            ;;
        *)
            if [ -n "$option" ];then
                local value=$arg
            else
                [ -n "$COMMAND" ] && COMMAND="${COMMAND} $arg" || COMMAND=$arg
                continue
            fi
        esac
        set_option $option $value $expect_type $var
    
        # clean var
        local option=""
        local value=""
        local expect_type=""
        local var=""
    done
}
