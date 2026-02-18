function Get-Platform {
    if ($IsWindows) { return 'windows' }
    if ($IsLinux)   { return 'linux' }
    if ($IsMacOS)   { return 'macos' }
    return 'unknown'
}

function Test-Platform([string]$Name) {
    return (Get-Platform) -eq $Name
}

# Create symlink with mkdir and force/skip logic
function Install-Link {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Target,
        [switch]$Force
    )
    $Target = $Target.Replace('~', $HOME)
    $parentDir = Split-Path -Parent $Target
    if (-not (Test-Path $parentDir)) {
        if ($PSCmdlet.ShouldProcess($parentDir, 'Create directory')) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
    }
    if ((Test-Path $Target) -and -not $Force) {
        Write-Host "[SKIP]  $Target already exists (use -Force to overwrite)"
        return
    }
    if ($PSCmdlet.ShouldProcess("$Target -> $Source", 'Create symlink')) {
        Write-Host "[LINK]  $Target -> $Source"
        New-Item -ItemType SymbolicLink -Path $Target -Value $Source -Force:$Force | Out-Null
    }
}

# Template substitution: read source, replace placeholder, write to target
function Install-Template {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][string]$Placeholder,
        [Parameter(Mandatory)][string]$Value,
        [switch]$Force
    )
    $Target = $Target.Replace('~', $HOME)
    if ((Test-Path $Target) -and -not $Force) {
        Write-Host "[SKIP]  $Target already exists (use -Force to overwrite)"
        return
    }
    $parentDir = Split-Path -Parent $Target
    if (-not (Test-Path $parentDir)) {
        if ($PSCmdlet.ShouldProcess($parentDir, 'Create directory')) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        }
    }
    if ($PSCmdlet.ShouldProcess("$Source -> $Target", 'Write templated file')) {
        Write-Host "[TMPL]  $Target <- $Source"
        (Get-Content $Source -Raw).Replace($Placeholder, $Value) | Set-Content $Target -NoNewline
    }
}

Export-ModuleMember -Function Get-Platform, Test-Platform, Install-Link, Install-Template
