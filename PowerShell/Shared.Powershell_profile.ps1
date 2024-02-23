
. $PSScriptRoot/Aliases.ps1

if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
} 
else {
    Write-Verbose "posh-git not imported"
}

if (Get-Module -ListAvailable -Name oh-my-posh) {
    Import-Module oh-my-posh
    Set-PoshPrompt -Theme agnosterplus
}
else {
    Write-Verbose "oh-my-posh not imported"
}

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

Import-Module "$PSScriptRoot/Utility.psm1"