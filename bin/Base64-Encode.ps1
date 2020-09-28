[CmdletBinding()]
param (
    [Parameter()]
    [String]
    $text
)


$bytes = [System.Text.Encoding]::Unicode.GetBytes($text)
$encoded = [Convert]::ToBase64String($bytes)

Write-Host $encoded