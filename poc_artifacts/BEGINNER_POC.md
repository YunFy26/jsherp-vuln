# Beginner PoC Guide (命令行版)

本指南给“小白”使用：直接复制命令即可验证 4 条漏洞。  
每条脚本都满足以下格式：

- 输出 `STEP 1/2/3...`
- 每一步先打印实际执行命令（`+ ...`）
- 每一步执行后打印数据库状态（删除前/后、写入前/后、对象读取前/后）

> 不需要截图，终端输出就是证据。

---

## 0) 准备

在仓库根目录执行：

```bash
docker compose -f ./docker-compose.jsherp33.yml ps
```

确认 `jsherp33-app` 和 `jsherp33-mysql` 为 `Up` 状态。

---

## 1) 高危：Log/Msg 越权删除（IDOR）

```bash
./poc_artifacts/poc_idor_log_msg_seeded.sh
```

你会看到：

1. `STEP 4` 中受害者记录存在（DB 有行）
2. `STEP 5/6` 删除接口返回 `{"code":200,...}`
3. `STEP 5/6` 删除后同 ID 的 DB 查询为空

---

## 2) 高危：registerUser 批量赋值

```bash
./poc_artifacts/poc_register_mass_assignment.sh
```

你会看到：

1. 注册请求 payload（包含 `ismanager/userNumLimit/expireTime`）
2. `jsh_user` 中新用户 `ismanager=1`
3. `jsh_tenant` 中新租户 `user_num_limit=9999999`、`expire_time=2099-12-31 23:59:59`

---

## 3) 中危：同租户低权限越权读取 supplier 债务接口

```bash
./poc_artifacts/poc_supplier_scope_bypass.sh
```

你会看到：

1. `STEP 2` 打印 role17 的函数绑定（DB）
2. `STEP 3` 打印供应商/客户相关功能 ID（DB）
3. `STEP 5` 低权限用户 `test123` 仍可读取 `getBeginNeedByOrganId`（返回 `code=200`）
4. `STEP 7` 数据库对象未变化（证明是读取型越权）

---

## 4) 中危补充：跨租户读取探测

```bash
./poc_artifacts/poc_supplier_idor.sh
```

你会看到：

1. 自动创建跨租户攻击账号
2. DB 中能查到攻击账号与新租户
3. `jsh` 可正常读取目标 `organId`
4. 跨租户攻击者读取同一 `organId` 返回 `500 获取数据失败`（当前环境被租户隔离拦截）

---

## 5) 一键跑完并保存证据

```bash
./poc_artifacts/run_all_poc.sh
```

执行结束后会给出证据目录，例如：

```text
poc_artifacts/run_20260302_130234
```

把该目录里的 `.out` 文件交给审计/老师即可。

