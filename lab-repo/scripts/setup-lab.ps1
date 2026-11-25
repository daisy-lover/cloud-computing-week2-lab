[CmdletBinding()]
param([switch]$Force)

$ErrorActionPreference = "Stop"
$labRepoRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $labRepoRoot
& (Join-Path $repoRoot "scripts\setup-lab.ps1") -TargetDirectory $labRepoRoot -Force:$Force
exit $LASTEXITCODE

