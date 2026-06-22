# 关键规则自动更新脚本（本地源）
# 用法：
#   powershell -ExecutionPolicy Bypass -File scripts/sync-critical-rules.ps1

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$rulesetDir = Join-Path $repoRoot "ruleset"
$logPath = Join-Path $repoRoot "scripts\sync-critical-rules.log"

New-Item -ItemType Directory -Path $rulesetDir -Force | Out-Null

$sources = @(
  @{ Name = "AI.list";        Url = "https://raw.githubusercontent.com/zxcvbnm975/Shadowrocket-Rules/main/ruleset/AI.list" },
  @{ Name = "Apple.list";     Url = "https://raw.githubusercontent.com/zxcvbnm975/Shadowrocket-Rules/main/ruleset/Apple.list" },
  @{ Name = "ApplePush.list"; Url = "https://raw.githubusercontent.com/zxcvbnm975/Shadowrocket-Rules/main/ruleset/ApplePush.list" },
  @{ Name = "Google.list";    Url = "https://raw.githubusercontent.com/zxcvbnm975/Shadowrocket-Rules/main/ruleset/Google.list" }
)

function Write-Log {
    param([string]$line)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts $line" | Out-File -FilePath $logPath -Encoding utf8 -Append
}

Write-Log "开始更新关键规则..."

foreach ($item in $sources) {
    $target = Join-Path $rulesetDir $item.Name
    $tmp = "$target.tmp"
    try {
        Invoke-WebRequest -Uri $item.Url -OutFile $tmp -UseBasicParsing -TimeoutSec 30

        if (Test-Path $target) {
            $oldHash = Get-FileHash -Algorithm SHA256 $target | Select-Object -ExpandProperty Hash
            $newHash = Get-FileHash -Algorithm SHA256 $tmp | Select-Object -ExpandProperty Hash
            if ($oldHash -ne $newHash) {
                Move-Item $tmp $target -Force
                Write-Host "[updated] $($item.Name)"
                Write-Log "updated: $($item.Name)"
            } else {
                Remove-Item $tmp -Force
                Write-Host "[unchanged] $($item.Name)"
                Write-Log "unchanged: $($item.Name)"
            }
        } else {
            Move-Item $tmp $target -Force
            Write-Host "[added] $($item.Name)"
            Write-Log "added: $($item.Name)"
        }
    } catch {
        if (Test-Path $tmp) { Remove-Item $tmp -Force }
        Write-Warning "更新失败: $($item.Name) - $($_.Exception.Message)"
        Write-Log "failed: $($item.Name) - $($_.Exception.Message)"
    }
}

Write-Log "更新完成"
Write-Host "done. log: $logPath"
