# dotfiles — bash customizations
# Sourced from ~/.bashrc via the bash dotfiles module

# oh-my-posh prompt
if command -v oh-my-posh &>/dev/null; then
    eval "$(oh-my-posh init bash --config "$(dirname "${BASH_SOURCE[0]}")/../config/oh-my-posh.toml")"
fi
