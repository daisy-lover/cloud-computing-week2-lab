[CmdletBinding()]
param(
    [string]$TargetDirectory,
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$labDirectory = if ($TargetDirectory) {
    [System.IO.Path]::GetFullPath($TargetDirectory)
} else {
    Join-Path $repoRoot "lab-repo"
}

$example = Join-Path $labDirectory ".env.example"
$destination = Join-Path $labDirectory ".env"

if (-not (Test-Path -LiteralPath $example -PathType Leaf)) {
    throw "找不到模板: $example"
}

if ((Test-Path -LiteralPath $destination) -and -not $Force) {
    Write-Host "[SKIP] $destination 已存在；如需重建请加 -Force。" -ForegroundColor Yellow
    exit 0
}

Copy-Item -LiteralPath $example -Destination $destination -Force:$Force
Write-Host "[PASS] 已创建课堂假环境文件: $destination" -ForegroundColor Green
Write-Host "       内容只用于安全实验，真实密钥不要写入这里。"

