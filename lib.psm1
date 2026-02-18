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

# Append a source line to a file, using a marker comment to detect/update it
function Install-SourceLine {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)][string]$Target,
        [Parameter(Mandatory)][string]$SourcePath,
        [string]$Marker = '# dotfiles-managed',
        [switch]$Force
    )
    $Target = $Target.Replace('~', $HOME)
    $sourceLine = "source $SourcePath"

    if (Test-Path $Target) {
        $lines = Get-Content $Target
        $markerIndex = [array]::FindIndex($lines, [Predicate[object]]{ param($l) $l -eq $Marker })

        if ($markerIndex -ge 0) {
            $nextIndex = $markerIndex + 1
            if ($nextIndex -lt $lines.Count -and $lines[$nextIndex] -eq $sourceLine) {
                if (-not $Force) {
                    Write-Host "[SKIP]  $Target already sources $SourcePath"
                    return
                }
            }
            # Update existing source line
            if ($PSCmdlet.ShouldProcess($Target, "Update source line to '$sourceLine'")) {
                Write-Host "[UPDT]  $Target -> $sourceLine"
                $lines[$nextIndex] = $sourceLine
                $lines | Set-Content $Target
            }
            return
        }
    }

    # Append marker + source line
    if ($PSCmdlet.ShouldProcess($Target, "Append source line '$sourceLine'")) {
        Write-Host "[SRCE]  $Target <- $sourceLine"
        "`n$Marker`n$sourceLine" | Add-Content $Target
    }
}

Export-ModuleMember -Function Get-Platform, Test-Platform, Install-Link, Install-Template, Install-SourceLine
