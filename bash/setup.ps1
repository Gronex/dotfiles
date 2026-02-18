#!/usr/bin/env pwsh
# Can run standalone: pwsh bash/setup.ps1 [-Force]
param([switch]$Force)

if (-not (Get-Command Install-SourceLine -ErrorAction SilentlyContinue)) {
    Import-Module (Join-Path $PSScriptRoot '../lib.psm1')
}

if (Test-Platform 'windows') {
    Write-Host "[SKIP]  bash module not supported on Windows"
    return
}

Install-SourceLine `
    -Target '~/.bashrc' `
    -SourcePath (Join-Path $PSScriptRoot 'bashrc.bash') `
    -Force:$Force
