
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
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High')]
    param ()

    $items = git status --porcelain

    $currentLocation = Get-Location

    $toClean = $items | Where-Object { $_.StartsWith("??") } | ForEach-Object { $_.TrimStart('?', ' ') } | ForEach-Object { $_.Trim('"')} | ForEach-Object { Join-Path -Path $currentLocation -ChildPath $_ }

    foreach($item in $toClean)
    {
        Write-Host $item
        if($PSCmdlet.ShouldProcess($item)){
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
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High')]
    [Alias('PruneGit')]
    param (
        [Parameter()]
        [Switch]
        $Remote
    )

    if($Remote) {
        $branches = @(git branch -a --merged | Select-String -Pattern '^\s{2}remotes/(.+)/(?!develop|(master|main|dev|develop|HEAD))' -Raw)
    }
    else {
        $branches = @(git branch --merged | Select-String -Pattern '^(\*.*|\s*develop)$' -NotMatch -Raw | ForEach-Object {$_.Trim()})
    }

    foreach($branch in $branches) {
        $diff = -split (git rev-list --left-right --count HEAD)

        Write-Host "$branch [Ahead: $($diff[1]), Behind: $($diff[0])]"

        if($Remote) {
            $branch = $branch | Select-String -Pattern 'remotes/(.+?)/(.+)'
            $origin = $branch.Matches.Groups[1]
            $target = $branch.Matches.Groups[2]
            if($PSCmdlet.ShouldProcess("$origin/$target", "git push -d")){
                git push -d $origin $target
            }
        }
        else {
            if($PSCmdlet.ShouldProcess($branch, "git branch -d")){
                git branch -d $branch
            }
        }
    }
}

function Enter-Symlink {
    [CmdletBinding()]
    [Alias('Enter-Junction')]
    [Alias('Push-Symlink')]
    [Alias('Push-Junction')]
    param (
        # Specifies a path to one or more locations.
        [Parameter(Mandatory=$false,
                   Position=0,
                   ParameterSetName="Path",
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true,
                   HelpMessage="Path to one or more locations.")]
        [Alias("PSPath")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path
    )

    if([String]::IsNullOrWhiteSpace($Path)) {
        $Path = Get-Location
    }
    $Path = Resolve-Path $Path
    $parent = $Path

    $remaining = "/"
    while (-not (Get-Item -Path $parent).Target) {

        $remaining = Join-Path $(Split-Path $parent -Leaf) $remaining
        Write-Verbose $remaining
        $parent = Split-Path $parent -Parent
        Write-Verbose $parent
        if([String]::IsNullOrWhiteSpace($parent)) {
            Write-Verbose "No Symlink in $Path"
            Push-Location $Path
            return;
        }
    }
    $targetPath = Join-Path (Get-Item -Path $parent).Target $remaining
    Write-Host "From path: $Path"
    Write-Host "Target: $targetPath"
    Push-Location $targetPath
}

function Update-IISCredentials {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'High')]
    param(
        [Parameter()]
        [Switch]
        $Force
    )
    
    Import-Module WebAdministration
    $creds = Get-credential
    $pools = Get-IISAppPool 

    foreach ($pool in $pools)
    {
        $poolPath = 'IIS:\AppPools\'+$pool.Name
        if ($PSCmdlet.ShouldProcess($pool.Name, "Update Credentials")) {
            Set-ItemProperty $poolPath -name processModel -value @{userName=$creds.UserName;password=$($creds.GetNetworkCredential().password);identitytype=3}
        }
        Write-Host "Updated $($pool.Name) to user $($creds.UserName)"
    }
}

function Build-CryptographyKey {
    param (
        [Parameter(Mandatory=$true)]
        [int]
        $Size
    )

    if ($Size % 8 -ne 0) {
        Write-Error "Size parameter must be devisable by 8"
        return
    }

    $bufferSize = $Size / 8
    $random = [System.Security.Cryptography.RandomNumberGenerator]::Create();
    $buffer = New-Object byte[] $bufferSize;
    $random.GetBytes($buffer)
    [System.Convert]::ToBase64String($buffer)
}

Export-ModuleMember -Function Get-Base64Encoding
Export-ModuleMember -Function Get-Base64Decoding
Export-ModuleMember -Function Remove-UntrackedGit
Export-ModuleMember -Function Get-FileLocker
Export-ModuleMember -Function Remove-MergedBranches -Alias PruneGit
Export-ModuleMember -Function Enter-Symlink -Alias @("Push-Symlink", "Enter-Junction", "Push-Junction")
Export-ModuleMember -Function Update-IISCredentials
Export-ModuleMember -Function Build-CryptographyKey