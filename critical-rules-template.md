# 关键规则本地化清单模板（适配 Shadowrocket）

下面这份是你现在这份配置可直接落地的“关键规则本地化模板”。  
目标：把常用、容易出问题、你又经常依赖的规则放到自己仓库，避免上游改动导致突发异常。

## 1) 建议本地化等级

### A 级（建议必须本地化）
- `ruleset/AI.list`  
  - 用途：AI 服务（ChatGPT、Claude、Copilot、Perplexity、OpenRouter 等）
  - 分组：`🤖 AI 服务`
- `ruleset/Google.list`  
  - 用途：Google 主服务与搜索/搜索生态域名
  - 分组：`🔍 谷歌服务`
- `ruleset/Apple.list`  
  - 用途：Apple 生态与 iCloud/CDN
  - 分组：`🍏 苹果服务`
- `ruleset/ApplePush.list`  
  - 用途：Apple 推送
  - 分组：`🍎 苹果推送`
- `规则/自定义私有网段规则`（可新建为 `ruleset/LAN.list`）  
  - 用途：你家的网段、公司内网、办公网关、打印机、NAS、内网域名
  - 分组：`🏠 私有网络`

### B 级（建议本地备份）
- `Shadowrocket-Rules` 里你常用的业务服务  
  例如：`Telegram`、`GitHub/GitLab/Atlassian`、`Microsoft`、`Steam`
- 实现方式：先保留远程，按周/双周手动同步一次到本地备份文件

### C 级（保留远程）
- 全量广告大全（`Advertising/..`）
- 大范围地理（`CN/Global`、`geolocation-cn`、`geolocation-!cn`）
- 频繁变化但你不想频繁维护的长尾列表

---

## 2) 你的配置里建议的源映射（当前可用版）

- `RULE-SET,ruleset/AI.list,🤖 AI 服务`
- `RULE-SET,ruleset/Google.list,🔍 谷歌服务`
- `RULE-SET,ruleset/Apple.list,🍏 苹果服务`
- `RULE-SET,ruleset/ApplePush.list,🍎 苹果推送`
- `RULE-SET,https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Telegram/Telegram.list,📲 电报消息`
- `RULE-SET,https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/Global/Global.list,🌍 非中国`
- `RULE-SET,https://raw.githubusercontent.com/blackmatrix7/ios_rule_script/master/rule/Shadowrocket/China/China.list,🔒 国内服务`

> 说明：`ruleset/xxx.list` 用的是你的本地文件，更新仓库就生效；远程源在网络不可达时仍可保底。

---

## 3) 自动更新（建议）

你可以直接给「关键规则」配置一个简单更新机制（按周执行）：

1. **固定更新时间**：每周一 06:00
2. **更新来源**：  
   - 关键 4 个列表来自你的仓库（`ruleset/AI.list`、`ruleset/Apple.list`、`ruleset/ApplePush.list`、`ruleset/Google.list`）
3. **更新后动作**：
   - 如果有文件变化，提交一条 commit（或至少改 `更新时间` 注释）
   - 在 Shadowrocket 内触发“规则更新”（或下拉刷新）

### 可选：本地更新脚本模板（PowerShell）

```powershell
# 文件：scripts/sync-critical-rules.ps1
$sources = @(
  @{ Name = "ruleset/AI.list";      Url = "https://raw.githubusercontent.com/zxcvbnm975/Shadowrocket-Rules/refs/heads/main/ruleset/AI.list" },
  @{ Name = "ruleset/Apple.list";   Url = "https://raw.githubusercontent.com/zxcvbnm975/Shadowrocket-Rules/refs/heads/main/ruleset/Apple.list" },
  @{ Name = "ruleset/ApplePush.list"; Url = "https://raw.githubusercontent.com/zxcvbnm975/Shadowrocket-Rules/refs/heads/main/ruleset/ApplePush.list" },
  @{ Name = "ruleset/Google.list";  Url = "https://raw.githubusercontent.com/zxcvbnm975/Shadowrocket-Rules/refs/heads/main/ruleset/Google.list" }
)
$root = "C:\\Users\\26425\\Desktop\\GitHub\\Shadowrocket-Rules"

foreach ($s in $sources) {
  $target = Join-Path $root $s.Name
  Invoke-WebRequest -Uri $s.Url -OutFile $target
  Write-Host "updated: $($s.Name)"
}
```

> 用在本地时建议加 `try/catch`，并在网络失败时失败不退出（保证脚本可重入）。

---

## 4) 本地化验收清单

- 关键本地规则文件是否都存在（至少 AI/Google/Apple/ApplePush）？
- 每个关键列表最近更新时间是否在 7~14 天以内？
- 本地分组是否对应到预期策略（AI 走美/直连、Apple 直连优先）？
- 在 SR 中导入后验证 3~5 条典型域名是否命中预期分组

---

## 5) 快速开箱清单（可直接复制）

- 在仓库中维护 `ruleset/*.list`
- 配置里对照上面的 `规则映射`
- 其他长期类规则（广告/CN-Global）仍用远程源
- 订阅更新频率：`1h~24h`（按你网速和稳定性调）

