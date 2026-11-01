TMUX
====

* Link the config for your platform (stow will not do this, every
  variant is suffixed):

```bash
# macOS
ln -sf ~/.dotfiles/tmux/.tmux.conf.mac ~/.tmux.conf
# Ubuntu
ln -sf ~/.dotfiles/tmux/.tmux.conf.ubuntu ~/.tmux.conf
```

* Clone tpm
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

* Install plugins `prefix + I`

* Update plugins `prefix + U`
