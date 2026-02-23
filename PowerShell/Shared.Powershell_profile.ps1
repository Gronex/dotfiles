$realScriptRoot = Split-Path -Parent ((Get-Item $PSCommandPath).Target ?? $PSCommandPath)

. $realScriptRoot/Aliases.ps1

if (Get-Module -ListAvailable -Name posh-git) {
    Import-Module posh-git
} 
else {
    Write-Verbose "posh-git not imported"
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    $configPath = Resolve-Path "$realScriptRoot/../config/oh-my-posh.toml"
    oh-my-posh init pwsh --config $configPath | Invoke-Expression
}
else {
    Write-Verbose "oh-my-posh not found"
}

if ($IsWindows) {
    $ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
    if (Test-Path($ChocolateyProfile)) {
        Import-Module "$ChocolateyProfile"
    }

    $completionScripts = Get-ChildItem -Path "C:/completions/" -Filter *.ps1 -ErrorAction SilentlyContinue
    foreach($script in $completionScripts) {
        Write-Verbose "Loading completion: $script"
        . $script
    }
}

Import-Module "$realScriptRoot/Utility.psm1"

$userProfile = Join-Path $HOME "Powershell_Profile.ps1"
if (Test-Path $userProfile) {
    . $userProfile
}