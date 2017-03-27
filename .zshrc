# .zshrc

# Unlike bash, an interactive zsh sources /etc/zshrc, and hence 
# /etc/profile.d without any help from $HOME/.zshrc

# Initialize the desres garden in-shell function
garden() { { eval "$(/usr/bin/garden-exec --shell=zsh "$@")"; } 3>&1; }

# ----------------------PERSONALIZATION STARTS HERE -----------------
# Environment variables, aliases, functions, key bindings, options and
# other personal preferences can be set here.  They will take effect
# in any interactive shell (assuming ~/.zprofile dots this file).

# An OS-specific 'personal garden' can be used with:
#case $DESRES_OS in
#CentOS6) garden use $HOME/dprA;;
#esac

# Set up a personal/private garden
garden use /u/nyc/arvaniti/dpr
# garden modules can be loaded like so
garden load git/2.1.0-11A/bin
garden load git-review/1.24-07A/bin
garden load flake8/2.5.1-02A/bin
garden load pep8/1.7.0-01A/bin
# Debatable whether I should actually do this, but I need autopep8 from
# somewhere, and it's not in the garden
# You can 'append' to an environment variable, e.g., PATH, with:
#garden append-path PATH ~/bin

# Make xclip work
PATH=$PATH:/u/nyc/arvaniti/local/bin
alias xclip='xclip -selection clipboard'
alias tcp='tmux show-buffer | xclip'

# Always use python 2.7
garden load Python/2.7.9-05st/bin
export SQUEUE_FORMAT="%.20i %.13P %.40j %.8u %.2t %.10M %.6D %R"

# Much of this is shamelessly stolen from gibiansky/dotfiles
# Use a pythonrc file
export PYTHONSTARTUP="$HOME/.pythonrc"
# various shortcuts
alias -g @='&> /dev/null &!'
alias notes='vim ~/.notes'
alias raventree='rdesktop -a16 -P -g 1920x1050 -r sound:remote raventree @'
alias en='ssh drdlogin0060'
alias hgrep='history 0 | grep'
alias useful-dir='echo `pwd` " - " $1 >> ~/useful-dirs'
alias io="inout | grep 'arvaniti\|hargus\|greisman\|klepeis\|donchev\|mcgibbon\|yuku'"
# alias testthing="if ! [ \"$VIRTUAL_ENV\" = \"/u/en/arvaniti/env\" ]; then; echo 'no venv'; else; echo 'venv'; fi;"
alias activate="source /u/en/arvaniti/env/bin/activate"

# Remap caps lock to escape
xmodmap -e "keycode 66 = Escape NoSymbol Escape"
xmodmap -e "clear lock"

# Get colors and extensions and run them
autoload colors && colors
# Make TeX behave
export TEXINPUTS=".:~/myLaTeX:"
# Use coreutils instead of whatever mac provides
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
export PATH="/Users/narvanitis/Library/Haskell/bin:$PATH"
export PATH="$(brew --prefix)/bin:$PATH"
# Binutils (installed by hand)
export PATH=/usr/local/i386-elf/bin:$PATH
alias ls='ls --color=auto'
# Color tab/^D completion like ls
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
autoload -Uz compinit
compinit
# Enable autocompletion inside git repositories
fpath=(~/.zsh $fpath)
zstyle ':completion:*:*:git:*' script ~/.git-completion.sh
# Garden autocompletion - call bash autocomplete script
autoload bashcompinit
bashcompinit
# garden autocompletion
# TODO: allow this to work for four-part garden modules
# TODO: don't break after running "garden keep-env-only --help" (sed error
# literally every time the prompt prints)
_garden_complete()
{
    local cur
    cur="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=()
    if [ ${#cur} -ge 2 ]; then
        COMPREPLY=($(garden avail "$cur*" | sed "/^#/d" | cut -d "/" -f1-$(echo $cur | sed 's/[^\/]//g' | wc -m) | uniq | sed 's/$/\//g' | sed "s/\///3" ))
    fi
    return 0
}
complete -F _garden_complete -o nospace -df garden
# And vi mode as well
bindkey -v
bindkey -M viins '^a' beginning-of-line
bindkey -M vicmd '^a' beginning-of-line
bindkey -M viins '^e' end-of-line
bindkey -M vicmd '^e' end-of-line
# Set short timeout to reduce jarring lag after <ESC>
export KEYTIMEOUT=1
# Handle deletion of old text gracefully
bindkey -M viins "^?" backward-delete-char
bindkey -M viins "^H" backward-delete-char

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
setopt extendedhistory

# Incrementally append to history, as soon as things are entered.
setopt appendhistory

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
    BRANCH_NAME=${BRANCH:0:15}
    =git branch >/dev/null 2>/dev/null && echo "($BRANCH_NAME) ⇒" && return
    =git branch >/dev/null 2>/dev/null && echo "⇒" && return
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

# Also offer visual difference based on vi mode
function vimode_symbol {
    if [[ $CURRENT_KEYMAP == "vicmd" ]]; then
        echo -n ☆☆☆
    else
        echo -n ★★★
    fi
}
vimodesym='$(vimode_symbol)'

# The final prompt! Ain't it adorable?
# Old prompt with time
# PROMPT="$exit_code_color$history_num $vimode$vimodesym$color_reset$exit_color $cur_time $prompt_user $prompt_cwd "'$(prompt_char)'" $color_reset"
PROMPT="$vimode$vimodesym$color_reset$exit_code_color$history_num $cur_time $prompt_user $prompt_cwd"$'\n''$(prompt_char)'" $color_reset"

