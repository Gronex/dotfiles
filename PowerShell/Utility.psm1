
function Get-Base64Encoding{
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $text
    )
    
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($text)
    [Convert]::ToBase64String($bytes)
}

function Get-Base64Decoding{
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $text
    )
    
    $bytes = [Convert]::FromBase64String($text)
    [System.Text.Encoding]::UTF8.GetString($bytes)
}

function Remove-UntrackedGit {
    [CmdletBinding()]
    param (
        [Parameter()]
        [Switch]
        $Force
    )

    $items = git status --porcelain

    $currentLocation = Get-Location

    $toClean = $items | Where-Object { $_.StartsWith("??") } | ForEach-Object { $_.TrimStart('?', ' ') } | ForEach-Object { $_.Trim('"')} | ForEach-Object { Join-Path -Path $currentLocation -ChildPath $_ }

    foreach($item in $toClean)
    {
        Write-Host $item
        if($force){
            Remove-Item -Path $item -Recurse
        }
    }
}

function Get-FileLocker {
    param($lockedFile)

    $processes = Get-Process
    foreach ($process in $processes)
    {
        foreach ($module in $process.Modules)
        {
            if ($_.FileName -like "${lockedFile}*") 
            {
                $process.Name + " PID:" + $process.id + " [" + $module.Filename + "]"
            }
        }
    }
}

function Remove-MergedBranches {
    [CmdletBinding()]
    [Alias('PruneGit')]
    param (
        [Parameter()]
        [Switch]
        $Force
    )

    $branches = @(git branch --merged | Select-String -Pattern '^(\*.*|\s*develop)$' -NotMatch -Raw | ForEach-Object {$_.Trim()})

    if ($Force -and $branches) {
        git branch -d $branches
    }
    else {
        $branches | Format-List
    }
}

Export-ModuleMember -Function Get-Base64Encoding
Export-ModuleMember -Function Get-Base64Decoding
Export-ModuleMember -Function Remove-UntrackedGit
Export-ModuleMember -Function Get-FileLocker
Export-ModuleMember -Function Remove-MergedBranches -Alias PruneGit