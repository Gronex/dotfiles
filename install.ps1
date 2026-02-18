#!/usr/bin/env pwsh
[CmdletBinding(SupportsShouldProcess)]
param(
    [string[]]$Modules,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'lib.psm1') -Force

# Discover modules: subdirectories containing setup.ps1
$allModules = Get-ChildItem -Path $PSScriptRoot -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'setup.ps1') } |
    Select-Object -ExpandProperty Name

if ($Modules) {
    foreach ($m in $Modules) {
        if ($m -notin $allModules) {
            Write-Error "Module '$m' not found. Available: $($allModules -join ', ')"
            return
        }
    }
} else {
    $Modules = $allModules
}

for ($i = 0; $i -lt $Modules.Count; $i++) {
    $m = $Modules[$i]
    $step = "$($i + 1)/$($Modules.Count)"
    $pct = [math]::Floor(($i / $Modules.Count) * 100)
    Write-Progress -Activity 'Installing dotfiles' -Status "[$step] $m" -PercentComplete $pct
    Write-Host "`n[$step] $m" -ForegroundColor Cyan
    $setupScript = Join-Path $PSScriptRoot $m 'setup.ps1'
    & $setupScript -Force:$Force
}

Write-Progress -Activity 'Installing dotfiles' -Completed
