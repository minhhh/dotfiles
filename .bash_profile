# Get the aliases and functions
if [ -f ~/.bashrc ]; then
         . ~/.bashrc
fi

export PATH=$PATH:$HOME/bin:$HOME/android/tools:$HOME/android/platform-tools:$HOME/android
#export PATH=$PATH:$HOME/play-2.0.4
#export PATH=$PATH:$HOME/play-2.1.3
export PATH=$PATH:$HOME/play-2.2.0
export PATH=/usr/local/bin:$PATH
export NDK_ROOT=$HOME/android-ndk-r8c
export ANDROID_HOME=$HOME/android
export ANDROID_SDK=$HOME/android
export ANDROID_SDK_ROOT=$HOME/android
export VERSIONER_PYTHON_PREFER_32_BIT=yes
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
HISTFILESIZE=2500

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

[[ -s /Users/minhha/.nvm/nvm.sh ]] && . /Users/minhha/.nvm/nvm.sh # This loads NVM

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

# push this into your .bashrc
function cd {
    builtin cd "$@" && ls
}
