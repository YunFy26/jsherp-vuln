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

说明：

- 每个子脚本都使用 `STEP` 分段展示。
- 每条关键操作前都会打印真实执行命令（以 `+` 开头）。
- 每个步骤后都会打印当前数据库状态（例如删除前后目标行、用户/租户落库结果、对象是否变化）。
- 这意味着你不需要截图，直接保存终端输出即可作为 PoC 证据。

---

## 3. 分项复现 PoC（完整命令）

## 3.1 高危 1 + 高危 2：Log/Msg 越权删除（IDOR）

该脚本按步骤输出：

1. 登录拿到 `jsh/test123` token
2. 查询 DB 基线（`jsh_log/jsh_msg` 总量）
3. 插入受害者记录（归属 `user_id=63`）
4. 查询受害者记录（删除前状态）
5. `test123` 删除日志并立即查询 DB（删除后状态）
6. `test123` 删除消息并立即查询 DB（删除后状态）
7. 再次查询总量（最终状态）

```bash
./poc_artifacts/poc_idor_log_msg_seeded.sh
```

复现成功特征：

- 删除接口返回 `{"code":200,...}`
- 删除前 `SELECT ... WHERE id=...` 有数据，删除后同一查询为空

---

## 3.2 高危 3：registerUser 批量赋值

该脚本按步骤输出：

1. 查询注册前 DB 基线（用户数、租户数）
2. 提交注册请求（含敏感字段）
3. 查询 `jsh_user`（看 `ismanager` 等）
4. 查询 `jsh_tenant`（看 `user_num_limit/expire_time`）
5. 直接登录新账号
6. 查询注册后 DB 基线（用户数、租户数）

提交的敏感字段：

- `ismanager=1`
- `userNumLimit=9999999`
- `expireTime=2099-12-31 23:59:59`

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

该脚本按步骤输出：

1. 获取 `jsh/test123` token
2. 查询 `role=17` 的功能绑定（DB）
3. 查询供应商/客户模块功能 ID（DB）
4. 查询目标 `organId` 对应基础数据（DB）
5. 用 `test123` 调用债务接口
6. 用 `jsh` 做对照调用
7. 再查一遍目标数据（DB 未变化）

复现成功特征：

- 输出中显示 role17 功能绑定不含供应商/客户菜单 ID
- `test123` 调用 `/supplier/getBeginNeedByOrganId?organId=...` 返回 `code=200` 与债务字段

### B. 跨租户探测（补充）

脚本会自动注册一个新租户攻击账号，并访问 tenant63 的 `organId`：

```bash
./poc_artifacts/poc_supplier_idor.sh
```

该脚本按步骤输出：

1. 查询目标供应商记录（DB）
2. 自动注册攻击账号（新租户）
3. 查询攻击账号在 `jsh_user/jsh_tenant` 的状态（DB）
4. 获取 `jsh` 与攻击账号 token
5. `jsh` 正常读取（基线）
6. 攻击账号跨租户读取同一 `organId`
7. 再查目标供应商记录（DB）

当前环境下常见现象：

- 攻击账号调用返回 `500 获取数据失败`（被租户隔离拦截）
- 说明跨租户在现配置下被部分阻断，但同租户对象级越权仍成立

---

## 4. 现成报告与证据

完整分析报告：

- `poc_artifacts/jshERP3.3_4flows_poc_report.md`
- `poc_artifacts/BEGINNER_POC.md`（小白专用：一步一命令 + 每步 DB 状态）
- `poc_artifacts/FULL_COMMAND_TRACE_REPORT.md`（不筛选，`sh -x` 全命令 + 全输出）

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
