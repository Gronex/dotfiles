# dotfiles

Cross-platform dotfiles managed with PowerShell Core.

## Requirements

- [PowerShell Core (pwsh)](https://github.com/PowerShell/PowerShell#get-powershell)

## Usage

```pwsh
# Install all modules
./install.ps1

# Install specific modules
./install.ps1 -Modules git, PowerShell

# Overwrite existing files
./install.ps1 -Force

# Dry run
./install.ps1 -WhatIf
```
