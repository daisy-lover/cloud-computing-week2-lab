[CmdletBinding()]
param()

$ErrorActionPreference = "Continue"
$repoRoot = Split-Path -Parent $PSScriptRoot
$passCount = 0
$warnCount = 0
$failCount = 0

function Add-Pass([string]$Name, [string]$Detail) {
    $script:passCount++
    Write-Host "[PASS] $Name - $Detail" -ForegroundColor Green
}

function Add-Warn([string]$Name, [string]$Detail) {
    $script:warnCount++
    Write-Host "[WARN] $Name - $Detail" -ForegroundColor Yellow
}

function Add-Fail([string]$Name, [string]$Detail) {
    $script:failCount++
    Write-Host "[FAIL] $Name - $Detail" -ForegroundColor Red
}

function Get-CommandText([string]$Command) {
    try {
        $output = & $Command --version 2>&1
        if ($LASTEXITCODE -ne 0) { return $null }
        return (($output | Select-Object -First 1) -replace "\x1b\[[0-9;]*m", "").Trim()
    } catch {
        return $null
    }
}

function Get-SemanticVersion([string]$Text) {
    if ($Text -match "(\d+)\.(\d+)\.(\d+)") {
        return [version]"$($Matches[1]).$($Matches[2]).$($Matches[3])"
    }
    return $null
}

Write-Host "第 2 周实验环境检查" -ForegroundColor Cyan
Write-Host "实验包: $repoRoot"
Write-Host ""

# Node.js
$nodeText = Get-CommandText "node"
$nodeVersion = Get-SemanticVersion $nodeText
if (-not $nodeText) {
    Add-Fail "Node.js" "未找到 node；安装 Node.js 24 LTS 后重开终端"
} elseif (-not $nodeVersion -or $nodeVersion -lt [version]"24.9.0") {
    Add-Fail "Node.js" "$nodeText；DSH 0.2.2-rc.5 要求 >=24.9.0"
} else {
    Add-Pass "Node.js" $nodeText
}

# npm
$npmText = Get-CommandText "npm"
$npmVersion = Get-SemanticVersion $npmText
if (-not $npmText) {
    Add-Fail "npm" "未找到 npm；随 Node.js 重新安装"
} elseif (-not $npmVersion -or $npmVersion -lt [version]"10.0.0") {
    Add-Warn "npm" "$npmText；建议 >=10"
} else {
    Add-Pass "npm" $npmText
}

# Python
$pythonText = Get-CommandText "python"
$pythonVersion = Get-SemanticVersion $pythonText
if (-not $pythonText) {
    Add-Fail "Python" "未找到 python；安装 Python 3.10+ 并加入 PATH"
} elseif (-not $pythonVersion -or $pythonVersion -lt [version]"3.10.0") {
    Add-Fail "Python" "$pythonText；要求 >=3.10"
} else {
    Add-Pass "Python" $pythonText
}

# PowerShell 7
$pwshText = Get-CommandText "pwsh"
if (-not $pwshText) {
    Add-Fail "PowerShell" "未找到 pwsh；安装 PowerShell 7"
} else {
    $pwshVersion = Get-SemanticVersion $pwshText
    if ($pwshVersion -and $pwshVersion -lt [version]"7.2.0") {
        Add-Warn "PowerShell" "$pwshText；建议 >=7.2"
    } else {
        Add-Pass "PowerShell" $pwshText
    }
}

# Git
$gitText = Get-CommandText "git"
if ($gitText) {
    Add-Pass "Git" $gitText
} else {
    Add-Fail "Git" "未找到 git；安装 Git 后重开终端"
}

# Pi and DSH
$piText = Get-CommandText "pi"
if (-not $piText) {
    Add-Fail "Pi" "未找到 pi；npm install -g --ignore-scripts @earendil-works/pi-coding-agent@1.6.0"
} elseif ($piText -match "1\.6\.0") {
    Add-Pass "Pi" $piText
} else {
    Add-Warn "Pi" "$piText；课程基线为 1.6.0，请确认兼容性"
}

$dshText = Get-CommandText "dsh"
if (-not $dshText) {
    Add-Fail "DSH" "未找到 dsh；npm install -g @deepseek-ai/dsh@0.2.2-rc.5"
} elseif ($dshText -match "0\.2\.2-rc\.5") {
    Add-Pass "DSH" $dshText
} else {
    Add-Warn "DSH" "$dshText；课程基线为 0.2.2-rc.5，请确认兼容性"
}

$pnpmText = Get-CommandText "pnpm"
if ($pnpmText) {
    Add-Pass "pnpm" $pnpmText
} else {
    Add-Fail "pnpm" "插件安装需要；npm install -g pnpm"
}

# Credentials are checked by presence only. Never print their values.
if ($env:ECNU_CHAT_API_KEY) {
    Add-Pass "ChatECNU Key" "检测到 ECNU_CHAT_API_KEY（值已隐藏）"
} else {
    Add-Warn "ChatECNU Key" "未检测到 ECNU_CHAT_API_KEY；按环境自查设置自己的 Key"
}

# Repository files
$requiredFiles = @(
    "lab-repo\README.md",
    "lab-repo\.env.example",
    "lab-repo\ticketflow\__main__.py",
    "plugins\env-guard\index.js",
    "plugins\env-guard\cordis.patch.yml"
)
$missing = @($requiredFiles | Where-Object {
    -not (Test-Path -LiteralPath (Join-Path $repoRoot $_) -PathType Leaf)
})
if ($missing.Count -eq 0) {
    Add-Pass "实验文件" "关键文件齐全"
} else {
    Add-Fail "实验文件" "缺少: $($missing -join ', ')"
}

# Python smoke tests
if ((Get-Command python -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $repoRoot "lab-repo\tests"))) {
    Push-Location (Join-Path $repoRoot "lab-repo")
    try {
        $pythonOutput = & python -m unittest discover -s tests -v 2>&1
        if ($LASTEXITCODE -eq 0) {
            $testCount = ($pythonOutput | Select-String -Pattern "Ran \d+ tests").Line
            Add-Pass "示例项目测试" $testCount
        } else {
            Add-Fail "示例项目测试" ($pythonOutput | Select-Object -Last 8) -join "`n"
        }
    } finally {
        Pop-Location
    }
}

# env-guard has no model dependency.
if ((Get-Command node -ErrorAction SilentlyContinue) -and
    (Test-Path (Join-Path $repoRoot "plugins\env-guard\test\guard.test.mjs"))) {
    Push-Location (Join-Path $repoRoot "plugins\env-guard")
    try {
        $guardOutput = & node ".\test\guard.test.mjs" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Add-Pass "env-guard 测试" (($guardOutput | Select-Object -Last 1) -join "")
        } else {
            Add-Fail "env-guard 测试" ($guardOutput | Select-Object -Last 8) -join "`n"
        }
    } finally {
        Pop-Location
    }
}

# Check Git status only when the package itself is a repository.
Push-Location $repoRoot
try {
    & git rev-parse --is-inside-work-tree *> $null
    if ($LASTEXITCODE -eq 0) {
        $dirty = & git status --porcelain
        if ($dirty) {
            Add-Warn "Git 工作区" "有未提交文件；提交前确认没有 .env 和真实 Key"
        } else {
            Add-Pass "Git 工作区" "干净"
        }
    } else {
        Add-Warn "Git 工作区" "当前实验包尚未初始化 Git；不影响实验运行"
    }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "汇总: PASS=$passCount WARN=$warnCount FAIL=$failCount"
if ($failCount -gt 0) {
    Write-Host "先按 docs/学生环境自查.md 修复所有 FAIL，再开始实验。" -ForegroundColor Red
    exit 1
}

if ($warnCount -gt 0) {
    Write-Host "必检项已通过；请阅读 WARN 判断是否需要在提交前处理。" -ForegroundColor Yellow
} else {
    Write-Host "环境检查全部通过。" -ForegroundColor Green
}
exit 0

