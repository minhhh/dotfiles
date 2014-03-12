[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -f ~/.dotfiles/.mybash ]] && . ~/.dotfiles/.mybash

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

export PATH=/usr/local/sbin:$PATH
