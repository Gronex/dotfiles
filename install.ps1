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
    # TODO: Change format to support duplicate keys
    $filemapPath = Join-Path -Path $folder -ChildPath "filemap.json"
    if (-not (Test-Path $filemapPath)) {
        continue;
    }
    $localFilemap = Get-Content $filemapPath | ConvertFrom-Json

    Write-Host $folder.FullName
    foreach ($map in $localFilemap.PSObject.Properties) {
        $fileLocation = Join-Path -Path $folder -ChildPath $map.Name
        $filemap[$fileLocation] = $map.Value
    }
}

Write-Host "Filemaps:"
$filemap | Format-Table

foreach ($map in $filemap.GetEnumerator()) {
    foreach($target in $map.Value) {
        if ((Test-Path $target) -and -not $overwrite) {
            Write-Host "$target already exists. Skipping because of overwite setting"
            continue;
        }
    
        New-Item -ItemType SymbolicLink -Path $target -Value $map.Name -Force:$Overwrite
    }
}

Pop-Location