#Alert

## Example

### Send SMS


```bash
export YUNPIAN_SENDSMS_APIKEY=<yunpian-api-key>
source ${OPS_COMMON_SCRIPTS}/lib/alert/send_sms.sh
```

发送原始告警
```bash
send_sms 17610631273 "test【source】"
```
将收到:
```
【source】test
```

发送带有默认模板的告警
```bash
send_sms_alert 17610631273,188888888 "push database file to oss failed." "Yearning MySQL Backup"
```
将收到：
```
【Shell Alert】Title: Yearning MySQL Backup
Hostname: <hostname>
Ipaddr: <eth0-ipaddr>
Message: push database file to oss failed.
```
