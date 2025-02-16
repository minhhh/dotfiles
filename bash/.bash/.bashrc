[[ -f ~/.bash/.mybash ]] && . ~/.bash/.mybash

export PATH="$HOME/miniconda3/bin:$PATH"
source $HOME/miniconda3/bin/activate

. "$HOME/.cargo/env"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

eval "$(zoxide init bash)"

export PATH="$PATH:$HOME/go/bin"
