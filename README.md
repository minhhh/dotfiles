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
You can add something like this to crontab to commit every 5 minutes.

```
*/5 * * * * (cd /pathtorepo && (git add -u && git commit -m "update") || echo "" && git pull --rebase && git push)
```

