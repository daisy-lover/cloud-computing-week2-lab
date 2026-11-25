[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SubmissionDir
)

$ErrorActionPreference = "Stop"
$directory = [System.IO.Path]::GetFullPath($SubmissionDir)
if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
    throw "提交目录不存在: $directory"
}

$problems = New-Object System.Collections.Generic.List[string]

$reports = Get-ChildItem -LiteralPath $directory -File |
    Where-Object { $_.Name -match "双引擎.*\.(md|pdf)$" }
if (-not $reports) {
    $problems.Add("缺少《双引擎对比实验报告》Markdown/PDF")
}

foreach ($name in @("AGENTS.md", "env-guard", "实验记录表_A.md", "实验记录表_B.md")) {
    if (-not (Test-Path -LiteralPath (Join-Path $directory $name))) {
        $problems.Add("缺少 $name")
    }
}

$images = Get-ChildItem -LiteralPath $directory -Recurse -File |
    Where-Object { $_.Extension -in @(".png", ".jpg", ".jpeg", ".webp") }
if ($images.Count -lt 2) {
    $problems.Add("证据截图少于 2 张")
}

$leakedEnv = Get-ChildItem -LiteralPath $directory -Recurse -File -Force |
    Where-Object { $_.Name -eq ".env" }
if ($leakedEnv) {
    $problems.Add("提交物包含 .env")
}

$secretHits = Get-ChildItem -LiteralPath $directory -Recurse -File |
    Select-String -Pattern "sk-[A-Za-z0-9]{20,}" -ErrorAction SilentlyContinue
if ($secretHits) {
    $problems.Add("检测到疑似真实 API Key，命中文件: $(($secretHits.Path | Sort-Object -Unique) -join ', ')")
}

if ($problems.Count) {
    Write-Host "提交检查未通过：" -ForegroundColor Red
    $problems | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
    exit 1
}

Write-Host "[PASS] 提交文件结构与敏感信息初筛通过。" -ForegroundColor Green
Write-Host "助教仍需人工核对数据真实性、六问、分支证据和插件复跑结果。"

