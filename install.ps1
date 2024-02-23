[CmdletBinding(SupportsShouldProcess)]
param (
    # If existing files should be overwritten
    [switch]
    $Force
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
        $fileLocation = Join-Path -Path $folder.FullName -ChildPath $map.Name
        $filemap[$fileLocation] = $map.Value
    }
}

Write-Host "Filemaps:"
$filemap | Format-Table

foreach ($map in $filemap.GetEnumerator()) {
    foreach($target in $map.Value) {
        if ((Test-Path $target) -and -not $Force) {
            Write-Host "$target already exists. Skipping because of overwite setting"
            continue;
        }
        Write-Host "$target -> $($map.Name)"
        $folder = Split-Path -Parent $target
        if(-not (Test-Path -PathType Container $folder)) {
            New-Item -ItemType Directory $folder
        }

        New-Item -ItemType SymbolicLink -Path "$target" -Value $map.Name -Force:$Force
    }
}

Pop-Location