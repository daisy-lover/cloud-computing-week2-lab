[CmdletBinding()]
param(
    [string]$Profile = "web"
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$template = Join-Path $repoRoot "config\dsh-ecnu.patch.yml"
$dshHome = $env:DSH_HOME
if (-not $dshHome) {
    $dshHome = Join-Path $env:USERPROFILE ".dsh"
}

$profileDir = Join-Path $dshHome "profiles\$Profile"
New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
$destination = Join-Path $profileDir "cordis.patch.yml"

if (Test-Path -LiteralPath $destination) {
    $meaningful = @(
        Get-Content -LiteralPath $destination |
            Where-Object { $_ -match "\S" -and $_ -notmatch "^\s*#" } |
            ForEach-Object { $_.Trim() }
    ) -join ""
    if ($meaningful -and $meaningful -ne "[]") {
        throw "配置文件已存在且包含用户内容，为避免覆盖请先备份: $destination"
    }
}

Copy-Item -LiteralPath $template -Destination $destination -Force
Write-Host "[PASS] 已写入 ChatECNU 的 DSH 配置: $destination" -ForegroundColor Green
Write-Host '       当前终端请设置 $env:ECNU_CHAT_API_KEY 后再启动 dsh。'

