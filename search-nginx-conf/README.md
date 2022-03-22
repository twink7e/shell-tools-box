## 介绍

`find-nginx-node.sh`筛选出存在nginx的节点，然后拿到该节点上nginx的所有配置文件的绝对路径，并把得到的nginx节点IP和配置文件路径保存到当前路径下名为`nginx-configs.list`文件中，`filter-nginx-file.sh`会读取获取的结果，然后连接到该机器使用`egrep`命令筛选配置文件

## 使用示例

```bash
$ echo '192.168.1.100' >> /home/admin/cluster/all_host
$ echo '192.168.1.110' >> /home/admin/cluster/all_host

$ bash find-nginx-node.sh

$ ls 
filter-nginx-file.sh  find-nginx-node.sh  nginx-configs.list,```

$ bash filter-nginx-file.sh -Hn 'www.test.com'
##### 192.168.1.100 #####
##### 192.168.1.110 #####
/home/admin/openresty/nginx/conf/nginx.conf:327:        server_name www.test.com;
```
