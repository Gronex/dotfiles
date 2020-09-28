[CmdletBinding()]
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