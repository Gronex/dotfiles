[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $Force
)

$items = git status --porcelain

$currentLocation = Get-Location

$toClean = $items | Where-Object { $_.StartsWith("??") } | ForEach-Object { $_.TrimStart('?', ' ') } | ForEach-Object { "$currentLocation/$_" }

foreach($item in $toClean)
{
  Write-Host $item
  if($force){
    Remove-Item -Path $item -Recurse
  }
}