## 介绍

使用`netstat`获取`ESTABLISHED`状态的tcp连接，然后筛选出目的端口为`MONGO_PORT`的连接，拿到源IP和端口，登录到源地址机器上，根据源端口获取到连接发起方的PID。

可以根据PID的信息，从其他渠道获取到PID的服务名称（这个要你自己修改脚本了）


## 使用示例

假如我想知道哪些服务连接了MongoDB
MongoDB的节点，端口为27019：
- 192.168.100.1
- 192.168.100.2
- 192.168.100.3

修改脚本中的两个变量
```bash
MONGO_IPS="192.168.100.1 192.168.100.2 192.168.100.3"
MONGO_PORT=27019
```

改完后直接执行：
```bash
$ bash get-who-connect-mongo.sh

# ...
$ ls
get_pid_failed.csv  get_who_connection_mongo_app_name.csv  get_who_connection_mongo_app_name_failed.csv  get-who-connect-mongo.sh
```

- get_pid_failed.csv 获取client的发起连接进程失败的列表
- get_who_connection_mongo_app_name_failed.csv 获取到的哪些client进程连接了zookeeper列表，这个表是无法确定服务名，只保留了PID，列表的格式为：ip, client-pid
- get_who_connection_mongo_app_name.csv 获取到的哪些服务连接了zookeeper的列表，格式：client-ip, client-pid, service-name

## 自由统计

```
awk -F ',' '{print $1 $3}' get_who_connection_mongo_app_name.csv | sort  | uniq -c
```

自己发挥吧...
