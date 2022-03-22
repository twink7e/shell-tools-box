#!/bin/bash


err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [ERROR]: $@" >&2
  [ -n "$LOG_FILE" ] && echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [ERROR]: $@" >> ${LOG_FILE}
}
info() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [INFO]: $@" >&1
  [ -n "$LOG_FILE" ] && echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')] [INFO]: $@" >> ${LOG_FILE}
}
function die(){
    err $1
    exit 1
}
