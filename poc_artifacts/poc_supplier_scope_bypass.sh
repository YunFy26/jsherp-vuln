#!/bin/sh
set -e
BASE='http://127.0.0.1:9999/jshERP-boot'
P='e10adc3949ba59abbe56e057f20f883e'

login_token() {
  user="$1"
  docker exec jsherp33-app sh -lc "curl -s -X POST $BASE/user/login -H 'Content-Type: application/json' -d '{\"loginName\":\"$user\",\"password\":\"$P\"}'" \
  | sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
}

TOKEN_TEST="$(login_token test123)"
TOKEN_JSH="$(login_token jsh)"

echo "[Role-17 function bindings]"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,key_id,type,value,tenant_id FROM jsh_user_business WHERE type='RoleFunctions' AND key_id=17;\""

echo "[Supplier/Customer function IDs in system]"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,name,url FROM jsh_function WHERE id IN (25,217,235,237) ORDER BY id;\""

echo "[PoC] role-17 user(test123) reads organ debts directly"
for id in 57 58 74; do
  echo "organId=$id"
  docker exec jsherp33-app sh -lc "curl -s '$BASE/supplier/getBeginNeedByOrganId?organId=$id' -H 'X-Access-Token: $TOKEN_TEST'"
  echo
 done

echo "[Control] role-10 user(jsh) same requests"
for id in 57 58 74; do
  echo "organId=$id"
  docker exec jsherp33-app sh -lc "curl -s '$BASE/supplier/getBeginNeedByOrganId?organId=$id' -H 'X-Access-Token: $TOKEN_JSH'"
  echo
 done

echo "[Context]"
echo "test123 token: $TOKEN_TEST"
echo "jsh token: $TOKEN_JSH"
