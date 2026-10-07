# =============================================================================
# Profile.ps1 - Windows PowerShell 5.1, per-user, ALL hosts
#   C:\Users\hamin\Documents\WindowsPowerShell\Profile.ps1
#
# Git/tool aliases ported from: dotfiles/bash/.bash/.myalias
#
# Why functions instead of Set-Alias: a PowerShell alias can only map a name
# to a command, it cannot carry arguments. So every bash `alias x='cmd --flag'`
# becomes a function here. `@args` is splatted through, which keeps the bash
# behaviour:  mga file.txt   ->   git add file.txt
# =============================================================================

# --- git ---------------------------------------------------------------------
function mga   { git add @args }
function mgau  { git add -u @args }
function mgaa  { git add -A @args }
function mgb   { git branch @args }
function mgbr  { git branch -r @args }
function mgc   { git commit @args }
function mgcz  { git cz @args }
function mgcm  { git commit -m @args }
function mgcl  { git clean @args }
function mgco  { git checkout @args }
function mgcod { git checkout develop @args }
function mgcom { git checkout main @args }
function mgcob { git checkout -b @args }
function mgcp  { git cherry-pick @args }
function mgd   { git diff @args }
function mgdd  { git diff develop @args }
function mgdm  { git diff main @args }
function mgdh  { git diff HEAD @args }
function mgf   { git fetch @args }
function mgfp  { git fetch -p @args }
function mgfa  { git fetch --all @args }
function mgl   { git log --graph --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%cI) %C(bold blue)<%an>%Creset' --abbrev-commit @args }
function mglm  { git log --graph --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%cI) %C(bold blue)<%an>%Creset' --abbrev-commit main @args }
function mgld  { git log --graph --pretty=format:'%Cred%h -%C(yellow)%d%Creset %s %Cgreen(%cI) %C(bold blue)<%an>%Creset' --abbrev-commit develop @args }
function mglh  { mgl | Select-Object -First 10 }
function mgm   { git merge @args }
function mgmd  { git merge develop @args }
function mgmm  { git merge main @args }
function mgp   { git pull @args }
function mgpu  { git push @args }
function mgr   { git reset @args }
function mgrhh { git reset --hard HEAD~10 @args }
function mgrh1 { git reset --hard HEAD~1 @args }
function mgrh2 { git reset --hard HEAD~2 @args }
function mgrh3 { git reset --hard HEAD~3 @args }
function mgrb  { git rebase @args }
function mgst  { git stash @args }
function mgt   { git tag @args }
# bash: alias mgs="git status --short --branch"  (the old GitStatus helper only
# ran a bare `git status`; this matches the bash alias instead)
function mgs   { git status --short --branch @args }

# --- multipass ---------------------------------------------------------------
function mp   { multipass @args }
function mps  { multipass start @args }
function mpst { multipass stop @args }

# --- dotnet / terraform ------------------------------------------------------
function mdr { dotnet run @args }
function mt  { terraform @args }

# --- listing / fuzzy find ----------------------------------------------------
# bash used `exa`; eza is the maintained fork. Falls back to Get-ChildItem.
function l {
    if (Get-Command eza -ErrorAction SilentlyContinue)      { eza -lagB --time-style long-iso @args }
    elseif (Get-Command exa -ErrorAction SilentlyContinue)  { exa -lagB --time-style long-iso @args }
    else                                                    { Get-ChildItem -Force @args }
}
function ff { fzf @args }
# bash: fzf --print0 | xargs -0 -o vim  -> pick one path, open it in vim
function f {
    $sel = fzf @args
    if ($sel) { vim -- $sel }
}

# --- navigation --------------------------------------------------------------
# bash: cd "$@" && pushd . && ls -a    /    alias d-="popd"
function d  { Push-Location @args; Get-ChildItem -Force }
function d- { Pop-Location }
function .. { d .. }

# bash: which Vim && alias vimn="Vim -u NONE -N"  (MacVim's CLI shim)
if (Get-Command Vim -ErrorAction SilentlyContinue) {
    function vimn { Vim -u NONE -N @args }
}

# --- deliberately NOT ported (bash/macOS-only, left in .myalias) --------------
#   mis, mis6 : macOS Xcode iPhone Simulator
#   crone     : macOS `crontab -e` with VIM_CRONTAB=true
#   lm        : depends on the external `walk` binary
#   mux       : tmux session restore
#   acommit / gpr / glpr : bash functions wrapping opencode + jq + gh/glab
#   cm        : from .mybash, cats $MYBASH_DIR/.cc

#region conda initialize
# !! Contents within this block are managed by 'conda init' !!
If (Test-Path "C:\Users\hamin\miniconda3\Scripts\conda.exe") {
    (& "C:\Users\hamin\miniconda3\Scripts\conda.exe" "shell.powershell" "hook") | Out-String | ?{$_} | Invoke-Expression
}
#endregion

conda activate default
