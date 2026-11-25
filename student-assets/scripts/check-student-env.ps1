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

function Get-VersionText([string]$Command) {
    try {
        $output = & $Command --version 2>&1
        if ($LASTEXITCODE -ne 0) { return $null }
        return (($output | Select-Object -First 1) -replace "\x1b\[[0-9;]*m", "").Trim()
    } catch {
        return $null
    }
}

function Get-Sversion([string]$Text) {
    if ($Text -match "(\d+)\.(\d+)\.(\d+)") {
        return [version]"$($Matches[1]).$($Matches[2]).$($Matches[3])"
    }
    return $null
}

Write-Host "第 2 周实验学生环境检查" -ForegroundColor Cyan
Write-Host "材料包: $repoRoot"
Write-Host ""

$nodeText = Get-VersionText "node"
$nodeVersion = Get-Sversion $nodeText
if (-not $nodeText) {
    Add-Fail "Node.js" "未找到 node；安装 Node.js 24 LTS"
} elseif (-not $nodeVersion -or $nodeVersion -lt [version]"24.9.0") {
    Add-Fail "Node.js" "$nodeText；DSH 要求 >=24.9.0"
} else {
    Add-Pass "Node.js" $nodeText
}

$npmText = Get-VersionText "npm"
if ($npmText) { Add-Pass "npm" $npmText } else { Add-Fail "npm" "未找到 npm" }

$pythonText = Get-VersionText "python"
$pythonVersion = Get-Sversion $pythonText
if (-not $pythonText) {
    Add-Fail "Python" "未找到 python；安装 Python 3.10+"
} elseif (-not $pythonVersion -or $pythonVersion -lt [version]"3.10.0") {
    Add-Fail "Python" "$pythonText；要求 >=3.10"
} else {
    Add-Pass "Python" $pythonText
}

$gitText = Get-VersionText "git"
if ($gitText) { Add-Pass "Git" $gitText } else { Add-Fail "Git" "未找到 git" }

$piText = Get-VersionText "pi"
if (-not $piText) {
    Add-Fail "Pi" "未安装；按环境自查安装 @earendil-works/pi-coding-agent"
} elseif ($piText -match "1\.6\.0") {
    Add-Pass "Pi" $piText
} else {
    Add-Warn "Pi" "$piText；课程基线为 1.6.0"
}

$dshText = Get-VersionText "dsh"
if (-not $dshText) {
    Add-Fail "DSH" "未安装；按环境自查安装 @deepseek-ai/dsh"
} elseif ($dshText -match "0\.2\.2-rc\.5") {
    Add-Pass "DSH" $dshText
} else {
    Add-Warn "DSH" "$dshText；课程基线为 0.2.2-rc.5"
}

$pnpmText = Get-VersionText "pnpm"
if ($pnpmText) { Add-Pass "pnpm" $pnpmText } else { Add-Fail "pnpm" "插件安装需要 pnpm" }

if ($env:ECNU_CHAT_API_KEY) {
    Add-Pass "ChatECNU Key" "当前终端已设置（值已隐藏）"
} else {
    Add-Warn "ChatECNU Key" "尚未设置 ECNU_CHAT_API_KEY"
}

$required = @(
    "config\pi-models.ecnu.json",
    "config\dsh-ecnu.patch.yml",
    "lab-repo\.env.example",
    "plugins\env-guard\index.js"
)
$missing = @($required | Where-Object {
    -not (Test-Path -LiteralPath (Join-Path $repoRoot $_) -PathType Leaf)
})
if ($missing.Count) {
    Add-Fail "实验文件" "缺少: $($missing -join ', ')"
} else {
    Add-Pass "实验文件" "关键文件齐全"
}

Push-Location (Join-Path $repoRoot "lab-repo")
try {
    $testOutput = & python -m unittest discover -s tests -v 2>&1
    if ($LASTEXITCODE -eq 0) {
        Add-Pass "示例仓库测试" (($testOutput | Select-String "Ran \d+ tests").Line -join "")
    } else {
        Add-Fail "示例仓库测试" ($testOutput | Select-Object -Last 6) -join "`n"
    }
} finally {
    Pop-Location
}

$pluginEntry = Join-Path $repoRoot "plugins\env-guard\index.js"
if ((Get-Content -LiteralPath $pluginEntry -Raw) -match "TODO_STUDENT_IMPLEMENTATION") {
    Add-Warn "env-guard" "PENDING：插件骨架尚未完成，按 B3 实现后重跑"
} else {
    Push-Location (Join-Path $repoRoot "plugins\env-guard")
    try {
        $guardOutput = & node ".\test\guard.test.mjs" 2>&1
        if ($LASTEXITCODE -eq 0) {
            Add-Pass "env-guard" (($guardOutput | Select-Object -Last 1) -join "")
        } else {
            Add-Fail "env-guard" ($guardOutput | Select-Object -Last 6) -join "`n"
        }
    } finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "汇总: PASS=$passCount WARN=$warnCount FAIL=$failCount"
if ($failCount -gt 0) { exit 1 }
exit 0

