#!/bin/sh
set -e
BASE='http://127.0.0.1:9999/jshERP-boot'

login_token() {
  user="$1"
  docker exec jsherp33-app sh -lc "curl -s -X POST $BASE/user/login -H 'Content-Type: application/json' -d '{\"loginName\":\"$user\",\"password\":\"e10adc3949ba59abbe56e057f20f883e\"}'" \
  | sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
}

TOKEN_JSH="$(login_token jsh)"
TOKEN_TEST="$(login_token test123)"

LOG_ID=2
MSG_ID=2

echo "[Before] log row"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id FROM jsh_log WHERE id=$LOG_ID;\""

echo "[PoC] test123 delete jsh log id=$LOG_ID"
docker exec jsherp33-app sh -lc "curl -s -X DELETE '$BASE/log/delete?id=$LOG_ID' -H 'X-Access-Token: $TOKEN_TEST'"

echo "[After] log row"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id FROM jsh_log WHERE id=$LOG_ID;\""

echo "[Before] msg row"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=$MSG_ID;\""

echo "[PoC] test123 delete jsh msg id=$MSG_ID"
docker exec jsherp33-app sh -lc "curl -s -X DELETE '$BASE/msg/delete?id=$MSG_ID' -H 'X-Access-Token: $TOKEN_TEST'"

echo "[After] msg row"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=$MSG_ID;\""

echo "[Context] tokens"
echo "jsh token: $TOKEN_JSH"
echo "test123 token: $TOKEN_TEST"
