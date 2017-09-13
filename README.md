INTRODUCTION
============
Install stow
```
    sudo pacman -S stow
    sudo apt-get install stow
    brew install stow
```

Checkout this repo to .dotfiles

```
    git clone git@github.com:minhhh/dotfiles.git .dotfiles
```

## Install bash
```
    cd ~/.dotfiles
    stow bash
```

Add the following line to your `.bashrc` or `.bash_profile`

    [[ -f ~/.bash/.mybash ]] && . ~/.bash/.mybash


CONVENIENT SETUP FOR DEV ENVIRONMENT
============

## Use Crontab to commit common repos


