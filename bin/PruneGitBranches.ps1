[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $force
)

$branches = @(git branch --merged | Select-String -Pattern '^(\*.*|\s*develop)$' -NotMatch -Raw | ForEach-Object {$_.Trim()})

if ($force -and $branches) {
    git branch -d $branches
}
else {
    Format-List $branches
}