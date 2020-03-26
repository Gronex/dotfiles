[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $force
)

if (-not $force) {
    Write-Host "Would delete:"
    git branch --merged develop | findstr /v "develop$" | findstr /v "master$"
}
else {
    git branch --merged develop | findstr /v "develop$" | findstr /v "master$" | ForEach-Object { git branch -d $_.Trim() }
}
