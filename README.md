# 󰌃 Dotfiles

> My personal dotfiles for macOS/Linux - Neovim, Tmux, Bash, Karabiner, and more.

## 󰒲 Installation

### 1. Install GNU Stow

```bash
# macOS
brew install stow

# Arch Linux
sudo pacman -S stow

# Ubuntu/Debian
sudo apt-get install stow
```

### 2. Clone the Repository

```bash
git clone git@github.com:minhhh/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### 3. Install Configurations

```bash
# Install specific configs
stow bash
stow nvim
stow tmux
stow karabiner

# Or install all
stow */
```

## 󰌢 What's Included

| Tool | Description |
|------|-------------|
| 󰌃 nvim | Neovim with Lua, LSP, treesitter, cmp, and more |
| 󰤈 Tmux | Terminal multiplexer configuration |
| 󰉖 Bash | Shell aliases and functions |
| 󰌨 Karabiner | Keyboard remapping for macOS |
| 󰡦 Emacs | Editor configuration |
| 󰟊 Sublime Text | Keymaps and snippets |
| 󰌹 WeeChat | IRC client theming |
| 󰕧 Ack | Search configuration |
| 󰌽 Screen | Screenrc configuration |
| 󰌜 Nix | Nix environment configuration |

## 󰌢 Shell Setup

Add the following to your `.bashrc` or `.zshrc`:

```bash
[[ -f ~/.bash/.mybash ]] && source ~/.bash/.mybash
```

## 󰌢 Development Tips

### Vim Sessions with Tmux

1. Open vim and use `:Obsession` to create a session file
2. Create `~/.vim/sessions` folder and move the session file there
3. Open vim with: `vim -S ~/.vim/sessions/<session_name>.vim`
4. Vim will restore the session when opened from tmux

### Auto-commit Repos with Crontab

```bash
# Add to crontab to commit every 5 minutes
*/5 * * * * (cd /path/to/repo && (git add -u && git commit -m "update") || echo "" && git pull --rebase && git push)
```

## 󰌢 License

MIT
