export PATH=/usr/local/sbin:$PATH

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -f ~/.dotfiles/.mybash ]] && . ~/.dotfiles/.mybash

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

# Add environment variable COCOS_CONSOLE_ROOT for cocos2d-x
export COCOS_CONSOLE_ROOT=/Users/ha.minh/work/cocos2d-js/tools/cocos2d-console/bin
export PATH=$COCOS_CONSOLE_ROOT:$PATH
