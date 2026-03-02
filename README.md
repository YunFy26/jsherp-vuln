# jshERP 3.3 Docker + 漏洞 PoC 复现仓库

本仓库用于复现并验证以下 4 条已确认污点流对应漏洞：

1. `log/delete` 对象级越权删除（高危）
2. `msg/delete` 对象级越权删除（高危）
3. `user/registerUser` 批量赋值权限/配额提升（高危）
4. `supplier/getBeginNeedByOrganId` 越权读取（中危）

---

## 目录结构

```text
.
├── docker-compose.jsherp33.yml
├── db/
│   └── jsh_erp.sql
├── jsherp.3.3/                    # 本地镜像离线目录（用户自备，不建议提交）
└── poc_artifacts/
    ├── jshERP3.3_4flows_poc_report.md
    ├── poc_idor_log_msg_seeded.sh
    ├── poc_register_mass_assignment.sh
    ├── poc_supplier_scope_bypass.sh
    ├── poc_supplier_idor.sh
    └── run_all_poc.sh
```

---

## 前置条件

1. Docker Desktop 可用（macOS/Windows/Linux 均可）
2. 当前目录已有离线镜像目录：`jsherp.3.3/`（由 `docker save` 导出内容）
3. 终端可执行 `docker`、`docker compose`

---

## 1. 启动服务（从零开始）

以下命令默认在仓库根目录执行（README 所在目录）：

```bash
cd <你的仓库目录>
```

### 1.1 导入离线镜像

```bash
tar -c --no-xattrs --disable-copyfile -f /tmp/jsherp_33.tar -C ./jsherp.3.3 .
docker load -i /tmp/jsherp_33.tar
```

导入成功应看到：

```text
Loaded image: jsherp:3.3
```

### 1.2 启动容器

```bash
docker compose -f ./docker-compose.jsherp33.yml up -d
docker compose -f ./docker-compose.jsherp33.yml ps
```

预期关键状态：

```text
jsherp33-mysql   Up (healthy)
jsherp33-app     Up
```

### 1.3 访问地址

- 前端：`http://localhost:3000`
- 后端：`http://localhost:9999/jshERP-boot`

默认已知账号（用于验证）：

- `admin / 123456`
- `jsh / 123456`
- `test123 / 123456`

注意：后端登录接口密码传输为 MD5，`123456` 的 MD5 值为 `e10adc3949ba59abbe56e057f20f883e`。

---

## 2. 一键复现全部 PoC（推荐）

```bash
./poc_artifacts/run_all_poc.sh
```

脚本会顺序执行：

1. `poc_idor_log_msg_seeded.sh`
2. `poc_register_mass_assignment.sh`
3. `poc_supplier_scope_bypass.sh`
4. `poc_supplier_idor.sh`

并输出证据目录 `poc_artifacts/run_YYYYmmdd_HHMMSS/`。

---

## 3. 分项复现 PoC（完整命令）

## 3.1 高危 1 + 高危 2：Log/Msg 越权删除（IDOR）

脚本会自动：

1. 在数据库插入 `jsh(user_id=63)` 所属的日志与消息
2. 使用 `test123(user_id=131)` 的 token 执行删除
3. 对比删除前后 DB 结果

```bash
./poc_artifacts/poc_idor_log_msg_seeded.sh
```

复现成功特征：

- 删除接口返回 `{"code":200,...}`
- 删除后目标行查询为空

---

## 3.2 高危 3：registerUser 批量赋值

脚本会以匿名注册方式提交敏感字段：

- `ismanager=1`
- `userNumLimit=9999999`
- `expireTime=2099-12-31 23:59:59`

并检查这些值是否进入 `jsh_user/jsh_tenant`。

```bash
./poc_artifacts/poc_register_mass_assignment.sh
```

复现成功特征：

- 接口返回 `code=200`
- DB 中新用户 `ismanager=1`
- DB 中新租户 `user_num_limit=9999999` 且 `expire_time=2099-12-31 23:59:59`

---

## 3.3 中危 4：supplier/getBeginNeedByOrganId 越权读取

### A. 同租户低权限越权读取（主验证）

`test123(role=17)` 不具备供应商/客户功能菜单，但可直接访问债务查询接口：

```bash
./poc_artifacts/poc_supplier_scope_bypass.sh
```

复现成功特征：

- 输出中显示 role17 功能绑定不含供应商/客户菜单 ID
- `test123` 调用 `/supplier/getBeginNeedByOrganId?organId=...` 返回 `code=200` 与债务字段

### B. 跨租户探测（补充）

脚本会自动注册一个新租户攻击账号，并访问 tenant63 的 `organId`：

```bash
./poc_artifacts/poc_supplier_idor.sh
```

当前环境下常见现象：

- 攻击账号调用返回 `500 获取数据失败`（被租户隔离拦截）
- 说明跨租户在现配置下被部分阻断，但同租户对象级越权仍成立

---

## 4. 现成报告与证据

完整分析报告：

- `poc_artifacts/jshERP3.3_4flows_poc_report.md`

已有证据输出示例：

- `poc_artifacts/poc_idor_log_msg_seeded.out`
- `poc_artifacts/poc_register_mass_assignment.out`
- `poc_artifacts/poc_supplier_scope_bypass.out`
- `poc_artifacts/poc_supplier_idor.out`

---

## 5. 环境重置（可重复复现）

```bash
docker compose -f ./docker-compose.jsherp33.yml down
rm -rf ./jsherp.3.3/mysql-data
docker compose -f ./docker-compose.jsherp33.yml up -d
```

---

## 6. Git 仓库初始化

本目录已执行：

```bash
git init
```

可直接继续使用：

```bash
git add .
git commit -m "init: jshERP3.3 docker setup and full PoC reproduction docs"
```
