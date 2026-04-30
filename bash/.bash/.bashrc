
[[ -f ~/.bash/.mybash ]] && . ~/.bash/.mybash

export NDK_ROOT=$HOME/android-ndk-r10d

. "$HOME/.cargo/env"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

eval "$(zoxide init bash)"

export PATH="$PATH:$HOME/go/bin"

# OpenClaw Completion
source "$HOME/.openclaw/completions/openclaw.bash"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!

__conda_setup="$('$HOME/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# <<< conda initialize <<<

#export PATH="$PATH:$HOME/miniconda3/bin"
#source $HOME/miniconda3/bin/activate

conda activate default

