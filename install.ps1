[CmdletBinding(SupportsShouldProcess)]
param (
    # If existing files should be overwritten
    [Parameter()]
    [switch]
    $Overwrite
)

$ErrorActionPreference = 'Stop';

Push-Location $PSScriptRoot

$containingFolders = Get-ChildItem -Directory

$filemap = @{}

foreach ($folder in $containingFolders) {
    $filemapPath = Join-Path -Path $folder -ChildPath "filemap.json"
    if (-not (Test-Path $filemapPath)) {
        continue;
    }
    $localFilemap = Get-Content $filemapPath | ConvertFrom-Json -AsHashtable

    Write-Host $folder.FullName
    foreach ($map in $localFilemap.GetEnumerator()) {
        Write-Host $map.Key
        Write-Host $map.Value
        $fileLocation = Join-Path -Path $folder -ChildPath $map.Key
        $filemap[$fileLocation] = $map.Value
    }
}

Write-Host "Filemaps:"
$filemap | ForEach-Object { [PSCustomObject]$_ } | Format-List

foreach ($map in $filemap.GetEnumerator()) {

    if ((Test-Path $map.Value) -and -not $overwrite) {
        Write-Host "$($map.Value) already exists. Skipping because of overwite setting"
        continue;
    }

    New-Item -ItemType SymbolicLink -Path $map.Value -Value $map.Key -Force:$Overwrite
}

Pop-Location