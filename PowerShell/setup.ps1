#!/usr/bin/env pwsh
# Can run standalone: pwsh PowerShell/setup.ps1 [-Force]
param([switch]$Force)

if (-not (Get-Command Install-Link -ErrorAction SilentlyContinue)) {
    Import-Module (Join-Path $PSScriptRoot '../lib.psm1')
}

# --- Cross-platform: pwsh 7+ profile ---
if (Test-Platform 'windows') {
    $PsCore = Join-Path $HOME 'Documents/PowerShell'
} else {
    $PsCore = Join-Path $HOME '.config/powershell'
}

Install-Link (Join-Path $PSScriptRoot 'Core.Powershell_profile.ps1') `
    (Join-Path $PsCore 'Microsoft.PowerShell_profile.ps1') -Force:$Force

foreach ($file in @('Shared.Powershell_profile.ps1', 'Aliases.ps1', 'Utility.psm1')) {
    Install-Link (Join-Path $PSScriptRoot $file) (Join-Path $PsCore $file) -Force:$Force
}

# --- Windows-only: legacy PowerShell 5.1 ---
if (Test-Platform 'windows') {
    $PsLegacy = Join-Path $HOME 'Documents/WindowsPowerShell'

    Install-Link (Join-Path $PSScriptRoot 'Windows.Powershell_profile.ps1') `
        (Join-Path $PsLegacy 'Microsoft.PowerShell_profile.ps1') -Force:$Force

    foreach ($file in @('Shared.Powershell_profile.ps1', 'Aliases.ps1', 'Utility.psm1')) {
        Install-Link (Join-Path $PSScriptRoot $file) (Join-Path $PsLegacy $file) -Force:$Force
    }
}
