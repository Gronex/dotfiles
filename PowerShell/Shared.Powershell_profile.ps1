
. $PSScriptRoot/Aliases.ps1

if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
} 
else {
    Write-Warning "posh-git not imported"
}

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

$profileRoot = Get-Item $MyInvocation.MyCommand.Definition | Select-Object -ExpandProperty Target | Split-Path -Parent


$env:Path += ";$profileRoot/../bin"