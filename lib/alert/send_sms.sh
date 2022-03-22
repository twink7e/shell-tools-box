# use yunpian.com to send sms alert with default context.
# $1: phone nums, eg: 17610631273,1888888888
# $2: write $1 in msg context.
function send_sms_alert(){
    local phone_nums=$1
    local msg=$2
    local title=${3:-"ShellScript"}
    local msg_context="""
Title: ${title}
Hostname: ${HOSTNAME}
IPAddr: $(ip addr show dev eth0 | awk 'NR==3{print $2}' | awk -F '/' '{print $1}')
Message: ${msg}
【Shell Alert】
"""

    IFS=','
    for num in $phone_nums;do
        send_sms $num "${msg_context}"
    done

}

# send sms alert
# $1: phone num.
# $2: sms message.
function send_sms(){
    local mobile=$1
    local msg_context=$2
    # send sms alert
    local apikey="$YUNPIAN_SENDSMS_APIKEY"
    if [ ! -n "$apikey" ];then
        echo "error sendsms apikey is null."
        exit 1
    fi
    curl -m 5 -s --data "apikey=$apikey&mobile=$mobile&text=$msg_context" "https://sms.yunpian.com/v2/sms/single_send.json"
}
