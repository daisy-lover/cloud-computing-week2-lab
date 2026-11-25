[CmdletBinding()]
param(
    [string]$OutputDirectory
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$outputRoot = if ($OutputDirectory) {
    [System.IO.Path]::GetFullPath($OutputDirectory)
} else {
    Join-Path $repoRoot "delivery"
}
$packageName = "pi-dsh-week2-student-package"
$staging = Join-Path $outputRoot "$packageName-2026-11-25"
$zipPath = Join-Path $outputRoot "$packageName-2026-11-25.zip"

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
if (Test-Path -LiteralPath $staging) {
    $resolvedStaging = (Resolve-Path -LiteralPath $staging).Path
    if (-not $resolvedStaging.StartsWith($outputRoot + "\", [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "拒绝清理输出目录之外的路径: $resolvedStaging"
    }
    Remove-Item -LiteralPath $resolvedStaging -Recurse -Force
}
if (Test-Path -LiteralPath $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

New-Item -ItemType Directory -Force -Path $staging,
    (Join-Path $staging "docs"),
    (Join-Path $staging "config"),
    (Join-Path $staging "scripts"),
    (Join-Path $staging "plugins") | Out-Null

Copy-Item -LiteralPath (Join-Path $repoRoot "student-assets\README.md") `
    -Destination (Join-Path $staging "README.md")
Copy-Item -LiteralPath (Join-Path $repoRoot "LICENSE") `
    -Destination (Join-Path $staging "LICENSE")
Copy-Item -LiteralPath (Join-Path $repoRoot ".gitattributes") `
    -Destination (Join-Path $staging ".gitattributes")
Copy-Item -LiteralPath (Join-Path $repoRoot ".gitignore") `
    -Destination (Join-Path $staging ".gitignore")

$studentDocs = @(
    "学生实验指导.md",
    "学生环境自查.md",
    "实验记录表模板.md",
    "实验报告模板.md"
)
foreach ($doc in $studentDocs) {
    Copy-Item -LiteralPath (Join-Path $repoRoot "docs\$doc") `
        -Destination (Join-Path $staging "docs\$doc")
}

$keyGuide = Join-Path $repoRoot "docs\ChatECNU-Key获取说明.md"
if (Test-Path -LiteralPath $keyGuide -PathType Leaf) {
    Copy-Item -LiteralPath $keyGuide -Destination (Join-Path $staging "docs\ChatECNU-Key获取说明.md")
}

Copy-Item -Path (Join-Path $repoRoot "config\*") -Destination (Join-Path $staging "config") -Recurse
Copy-Item -LiteralPath (Join-Path $repoRoot "scripts\setup-lab.ps1") `
    -Destination (Join-Path $staging "scripts\setup-lab.ps1")
Copy-Item -LiteralPath (Join-Path $repoRoot "scripts\configure-pi-ecnu.ps1") `
    -Destination (Join-Path $staging "scripts\configure-pi-ecnu.ps1")
Copy-Item -LiteralPath (Join-Path $repoRoot "scripts\configure-dsh-ecnu.ps1") `
    -Destination (Join-Path $staging "scripts\configure-dsh-ecnu.ps1")
Copy-Item -LiteralPath (Join-Path $repoRoot "student-assets\scripts\check-student-env.ps1") `
    -Destination (Join-Path $staging "scripts\check-student-env.ps1")

$labDestination = Join-Path $staging "lab-repo"
Copy-Item -LiteralPath (Join-Path $repoRoot "lab-repo") -Destination $labDestination -Recurse
Get-ChildItem -LiteralPath $labDestination -Recurse -Force |
    Where-Object {
        $_.Name -in @(".env", "__pycache__", ".pytest_cache") -or
        $_.Name -like "*.pyc" -or
        $_.Name -eq "技术结构文档.md"
    } |
    Sort-Object { $_.FullName.Length } -Descending |
    ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction SilentlyContinue }

Copy-Item -LiteralPath (Join-Path $repoRoot "student-assets\env-guard") `
    -Destination (Join-Path $staging "plugins\env-guard") -Recurse

$forbiddenNames = @(
    "助教验收记录.md",
    "助教课前检查清单.md",
    "评分与验收说明.md",
    ".env"
)
$leaks = Get-ChildItem -LiteralPath $staging -Recurse -File -Force |
    Where-Object { $_.Name -in $forbiddenNames }
if ($leaks) {
    throw "学生包包含不应分发的文件: $($leaks.FullName -join ', ')"
}

$secretHits = Get-ChildItem -LiteralPath $staging -Recurse -File -Force |
    Where-Object { $_.Extension -in @(".md", ".ps1", ".js", ".mjs", ".json", ".yml", ".yaml", ".py", ".toml") } |
    Select-String -Pattern "sk-[A-Za-z0-9_-]{20,}" -ErrorAction SilentlyContinue
if ($secretHits) {
    throw "学生包中发现疑似真实 API Key: $((($secretHits.Path | Sort-Object -Unique) -join ', '))"
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory(
    $staging,
    $zipPath,
    [System.IO.Compression.CompressionLevel]::Optimal,
    $true
)

$hash = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
@(
    "Student package: $zipPath"
    "SHA256: $hash"
) | Set-Content -LiteralPath (Join-Path $outputRoot "SHA256SUMS.txt") -Encoding UTF8

Write-Host "[PASS] 学生包目录: $staging" -ForegroundColor Green
Write-Host "[PASS] 学生压缩包: $zipPath" -ForegroundColor Green
Write-Host "SHA256: $hash"

