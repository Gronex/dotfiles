#!/usr/bin/env pwsh
# Can run standalone: pwsh git/setup.ps1 [-Force]
param([switch]$Force)

if (-not (Get-Command Install-Link -ErrorAction SilentlyContinue)) {
    Import-Module (Join-Path $PSScriptRoot '../lib.psm1')
}

Install-Template `
    -Source (Join-Path $PSScriptRoot 'gitconfig_base') `
    -Target '~/.gitconfig' `
    -Placeholder '${gitconfig_path}' `
    -Value $PSScriptRoot `
    -Force:$Force
