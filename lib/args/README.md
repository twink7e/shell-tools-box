# Basic Args Parser
## 简介
`lib/args/basic-args-parser.sh`提供了Shell参数的解析和语法检查

## 使用
以一个简单的获取数据库参数的场景来演示，需要读取到数据库的地址、账号、密码、端口、和数据库名称。
```bash
# 引入脚本
source $OPS_COMMON_SCRIPTS/lib/args/basic-args-parser.sh

# 定义对应参数的类型，支持string bool integer
TYPE_DB_NAME="string"
TYPE_DB_USERNAME="string"
TYPE_DB_PASSWORD="string"
TYPE_DB_HOST="string"
TYPE_DB_PORT=integer
TYPE_WITHOUT_DNS=bool


# 开始解析，执行过程中报错，比如提示类型错误等等。
basic_args_parser $*


echo "DB_NAME: $DB_NAME"
echo "DB_USERNAME: $DB_USERNAME"
echo "DB_PASSWORD: $DB_PASSWORD"
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "WITHOUT_DNS: $WITHOUT_DNS"
echo "COMMAND: $COMMAND"
```

测试：
```
$ bash test.sh -db-name  db_test -db-host=localhost --db-port 3306 --db-username=root --db-password=abc123 --without-dns list databases
DB_NAME: db_test
DB_USERNAME: root
DB_PASSWORD: abc123
DB_HOST: localhost
DB_PORT: 3306
WITHOUT_DNS: true
COMMAND: list databases
```
