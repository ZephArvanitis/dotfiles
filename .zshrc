# Get colors and extensions and run them
autoload colors && colors
# Make TeX behave
export TEXINPUTS=".:~/myLaTeX:"
# Use coreutils instead of whatever mac provides
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
export PATH="/Users/narvanitis/Library/Haskell/bin:$PATH"
# Enable autocompletion inside git repositories
fpath=(~/.zsh $fpath)
zstyle ':completion:*:*:git:*' script ~/.git-completion.sh
# Make autojump work
[[ -s `brew --prefix`/etc/autojump.zsh ]] && . `brew --prefix`/etc/autojump.zsh
# Make colors a thing
alias ls='ls --color=auto'
alias -g @='&> /dev/null &!'
alias notes='vim ~/.notes'
alias logs='vim ~/.logs'
# And vi mode as well
bindkey -v
bindkey -M viins '^a' beginning-of-line
bindkey -M vicmd '^a' beginning-of-line
bindkey -M viins '^e' end-of-line
bindkey -M vicmd '^e' end-of-line

# Function to clear the screen, and allow it to happen repeatedly
function clear-screen {
    zle -I
    repeat $((LINES - 1)) echo "\n"
    clear
}
# Turn the function into a widget and bind to ^l in any mode
zle -N clear-screen
bindkey -M viins '^l' clear-screen
bindkey -M vicmd '^l' clear-screen

# Make history more or less arbitrarily large.
HISTFILE=~/.histfile
HISTSIZE=10000000
SAVEHIST=10000000

# Store timestamps and time elapsed in history.
set extendedhistory

# Incrementally append to history, as soon as things are entered.
setopt incappendhistory

# Don't have duplicates in history.
setopt histignoredups

# Get rid of extraneous whitespace in history commands.
setopt hist_reduce_blanks

# Don't store 'history' and 'fc' commands into the history.
setopt histnostore




# Update prompt every time it's run
setopt prompt_subst

# Make colors behave themselves
green="%{$fg[green]%}"
red="%{$fg[red]%}"
blue="%{$fg[blue]%}"
cyan="%{$fg[cyan]%}"
bold_cyan="%{$fg_bold[cyan]%}"
bold_blue="%{$fg_bold[blue]%}"
color_reset="%{$reset_color%}"


# %? is the return code of the process.
# %U/%u is start and stop underline, respectively.
# %) = ')'
return_code="(%Uret %?%u%)"  

# The syntax for conditional expressions is %n(X.true-text.false-text), where n is an integer
# (defaulting to 0 if not provided) and X is a test character. The different tests are detailed
# at www.acm.uiuc.edu/workshops/zsh/prompt/conditionals.html, but the ? test is true if the exit
# static of the previous process was equal to the integer n.
#  
# Color the prompt green normally, and red if the command fails. If it fails, print the return code.
exit_color="%0(?.$green.$red)"
exit_code_color="%0(?.$green.$red$return_code )"

# History number: %! is the current command in the history.
history_num="[%!]"

# Current time, in 24 hour format, with seconds.
cur_time="%*"

# The user@hostname part.
prompt_user="%n@%m"

# Use a different prompt character if I'm inside a git repository.
function prompt_char {
    # = means it ignores aliases, apparently... (uses original thing)
    BRANCH=`=git branch 2> /dev/null | grep '*' | sed 's/* //'`
    BRANCH_NAME=${BRANCH:0:15}...
    =git branch >/dev/null 2>/dev/null && echo "($BRANCH_NAME) ⇒" && return
    echo '$'
}

# Use a special version of the working directory.
function working_dir {
    # Get the actual directory, replacing $HOME with ~.
    REAL_PWD=$(pwd | sed s,$HOME,~,);

    # Break up directory into lines.
    DIRS=$(echo $REAL_PWD | tr '/' '\n')

    # How many directories to leave unshortened.
    UNSHORTENED=2

    # How many character to reduce shortened directories to.
    SHORT_LENGTH=2

    # Get unshortened directories.
    UNSHORTENED_DIRS=`echo $DIRS | tail -n $UNSHORTENED`

    # If the unshortened directories are all of them, don't bother with the rest.
    if [[ `echo $DIRS | wc -l` -le $UNSHORTENED ]]; then
        echo $UNSHORTENED_DIRS | head -c-1 | tr '\n' '/'
        return
    fi

    # Get all pieces that need to be shortened.
    SHORTENED_DIRS=`echo $DIRS | cut -c-$SHORT_LENGTH | head -n-$UNSHORTENED`

    # Print out the directory. Make sure not to include trailing /, which is why we cut off that newline using head.
    (echo $SHORTENED_DIRS; echo $UNSHORTENED_DIRS | head -c-1) | tr '\n' '/'
}
prompt_cwd='$(working_dir)'

# Store current keymap magically
function zle-keymap-select {
    CURRENT_KEYMAP=$KEYMAP
    zle reset-prompt
}
zle -N zle-keymap-select

# Color code bits based on mode
function vimode_color {
    if [[ $CURRENT_KEYMAP == "vicmd" ]]; then
        echo -n $bold_cyan
    else
        echo -n $bold_blue
    fi
}
vimode='$(vimode_color)'

# The final prompt! Ain't it adorable?
PROMPT="$exit_code_color$history_num $vimode\[*_*]/$color_reset$exit_color $cur_time $prompt_user $prompt_cwd "'$(prompt_char)'" $color_reset"
