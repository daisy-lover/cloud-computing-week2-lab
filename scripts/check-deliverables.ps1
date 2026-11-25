[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot
$required = @(
    "README.md",
    "docs\学生实验指导.md",
    "docs\学生环境自查.md",
    "docs\实验记录表模板.md",
    "docs\实验报告模板.md",
    "docs\助教课前检查清单.md",
    "docs\评分与验收说明.md",
    "scripts\check-student-env.ps1",
    "scripts\check-submission.ps1",
    "scripts\setup-lab.ps1",
    "lab-repo\README.md",
    "lab-repo\.env.example",
    "lab-repo\ticketflow\cli.py",
    "plugins\env-guard\package.json",
    "plugins\env-guard\index.js",
    "plugins\env-guard\cordis.patch.yml",
    "plugins\env-guard\test\guard.test.mjs"
)

$missing = @()
foreach ($relative in $required) {
    $path = Join-Path $repoRoot $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        $missing += $relative
    }
}
if ($missing.Count) {
    throw "缺少交付文件:`n$($missing -join "`n")"
}
Write-Host "[PASS] 交付文件齐全" -ForegroundColor Green

Push-Location (Join-Path $repoRoot "lab-repo")
try {
    $testOutput = & python -m unittest discover -s tests -v 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "示例项目测试失败:`n$($testOutput -join "`n")"
    }
    Write-Host "[PASS] 示例项目测试" -ForegroundColor Green
} finally {
    Pop-Location
}

Push-Location (Join-Path $repoRoot "plugins\env-guard")
try {
    $guardOutput = & node ".\test\guard.test.mjs" 2>&1
    if ($LASTEXITCODE -ne 0 -or ($guardOutput -join "`n") -notmatch "6 passed") {
        throw "env-guard 测试失败:`n$($guardOutput -join "`n")"
    }
    Write-Host "[PASS] env-guard 测试" -ForegroundColor Green
} finally {
    Pop-Location
}

# Scan authored files for likely real secrets. The supplied test key is not
# included in this tool or repository.
$authoredExtensions = @("*.md", "*.ps1", "*.js", "*.mjs", "*.json", "*.yml", "*.yaml", "*.py", "*.toml")
$authoredFiles = foreach ($extension in $authoredExtensions) {
    Get-ChildItem -Path $repoRoot -Recurse -File -Filter $extension |
        Where-Object {
            $_.FullName -notmatch "\\.research\\|\\.tools\\|\\.npm-cache\\|\\node_modules\\"
        }
}
$secretHits = $authoredFiles | Select-String -Pattern "sk-[A-Za-z0-9]{20,}" -ErrorAction SilentlyContinue
if ($secretHits) {
    throw "检测到疑似 API Key，请从以下文件移除:`n$($secretHits.Path | Sort-Object -Unique)"
}
Write-Host "[PASS] 未发现疑似真实 API Key" -ForegroundColor Green

$envFiles = Get-ChildItem -Path $repoRoot -Recurse -File -Force |
    Where-Object {
        $_.Name -eq ".env" -and
        $_.FullName -notmatch "\\.tools\\|\\.research\\"
    }
if ($envFiles) {
    Write-Host "[WARN] 找到本地 .env；发布前确认被 .gitignore 排除：" -ForegroundColor Yellow
    $envFiles | ForEach-Object { Write-Host "       $($_.FullName)" }
}
Write-Host "交付物静态检查完成。" -ForegroundColor Cyan

