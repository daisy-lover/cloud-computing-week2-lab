[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$template = Join-Path $repoRoot "config\pi-models.ecnu.json"

if (-not (Test-Path -LiteralPath $template -PathType Leaf)) {
    throw "找不到 Pi 模型配置模板: $template"
}

$agentDir = $env:PI_CODING_AGENT_DIR
if (-not $agentDir) {
    $agentDir = Join-Path $env:USERPROFILE ".pi\agent"
}

New-Item -ItemType Directory -Force -Path $agentDir | Out-Null
$destination = Join-Path $agentDir "models.json"
Copy-Item -LiteralPath $template -Destination $destination -Force

Write-Host "[PASS] 已安装 ChatECNU 的 Pi 模型配置: $destination" -ForegroundColor Green
Write-Host "       配置通过 ECNU_CHAT_API_KEY 读取 Key，不保存明文。"
Write-Host ""
Write-Host "当前终端请设置 Key：" -ForegroundColor Cyan
Write-Host '  $env:ECNU_CHAT_API_KEY = Read-Host -AsSecureString | ForEach-Object { [System.Net.NetworkCredential]::new("", $_).Password }'
Write-Host ""
Write-Host "然后运行：" -ForegroundColor Cyan
Write-Host "  pi --list-models ecnu"

