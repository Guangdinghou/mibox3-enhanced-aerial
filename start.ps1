param([switch]$List)
$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

$Labels = @(
  '1. 设备检查', '2. 备份', '3. 下载资源', '4. 临时 ROOT', '5. 永久 ROOT',
  '6. 应用清理', '7. Aerial 桌面', '8. 状态验证', '9. 完整恢复'
)
if ($List) { $Labels; exit 0 }

$Candidates = @(
  "$env:ProgramFiles\Git\bin\bash.exe",
  "${env:ProgramFiles(x86)}\Git\bin\bash.exe"
)
$Bash = $Candidates | Where-Object { $_ -and (Test-Path $_) } | Select-Object -First 1
if (-not $Bash) {
  $Command = Get-Command bash.exe -ErrorAction SilentlyContinue
  if ($Command) { $Bash = $Command.Source }
}
if (-not $Bash) {
  Write-Host '未找到 Git for Windows 的 bash。请先安装 Git for Windows，再双击 start.cmd。' -ForegroundColor Red
  Read-Host '按回车退出'
  exit 1
}

function Invoke-Stage([string]$Script, [string[]]$Arguments = @()) {
  Push-Location $Root
  try {
    & $Bash $Script @Arguments
    if ($LASTEXITCODE -ne 0) { throw "阶段失败，退出码：$LASTEXITCODE" }
  } finally { Pop-Location }
}
function Ask-Backup {
  $Path = Read-Host '请输入备份目录的完整路径'
  if (-not $Path) { throw '未输入备份目录' }
  return $Path
}

while ($true) {
  Clear-Host
  Write-Host '小米盒子 3 增强版改造向导'
  Write-Host '每次只执行一个阶段；出现错误后不要反复重试。'
  $Labels | ForEach-Object { Write-Host $_ }
  Write-Host '0. 退出'
  $Choice = Read-Host '请选择'
  try {
    switch ($Choice) {
      '1' { Invoke-Stage 'scripts/00-doctor.sh' }
      '2' { Invoke-Stage 'scripts/10-backup.sh' }
      '3' { Invoke-Stage 'scripts/20-fetch-assets.sh' }
      '4' { Invoke-Stage 'scripts/30-test-temp-root.sh' }
      '5' { Invoke-Stage 'scripts/31-install-permanent-root.sh' @((Ask-Backup)) }
      '6' { Invoke-Stage 'scripts/40-debloat.sh' @((Ask-Backup)) }
      '7' {
        Invoke-Stage 'scripts/50-install-aerial.sh'
        Write-Host '请先在电视上确认 Aerial 可正常操作。'
        Invoke-Stage 'scripts/51-configure-aerial.sh' @((Ask-Backup))
        Write-Host '请用真实遥控器测试返回键和主页键；确认后再运行原桌面停用脚本。'
      }
      '8' { Invoke-Stage 'scripts/90-verify.sh' }
      '9' { Invoke-Stage 'scripts/99-restore-all.sh' @((Ask-Backup)) }
      '0' { exit 0 }
      default { Write-Host '无效选择。' -ForegroundColor Yellow }
    }
  } catch {
    Write-Host $_ -ForegroundColor Red
  }
  Read-Host '按回车返回菜单'
}
