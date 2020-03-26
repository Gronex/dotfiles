$items = git status --porcelain

$currentLocation = Get-Location

$toClean = $items | Where-Object { $_.StartsWith("??") }

foreach($item in $toClean){
  $itemPath = $item.TrimStart('?', ' ')
  Write-Host "$currentLocation/$itemPath"
}

$answer = Read-Host -Prompt "Delete items? [y/n]"

if($answer -eq "y"){
  foreach($item in $toClean)
  {
    $itemPath = $item.TrimStart('?', ' ')
    Write-Output "$currentLocation/$itemPath"
    Remove-Item -Path "$currentLocation/$itemPath" -Recurse
  }
}