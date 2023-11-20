# GENERAL
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/share/dotnet:$PATH"
export PATH="/Users/zeph/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/Library/Tex/texbin:$PATH"
export PATH="/usr/local/Cellar/mssql-tools/14.0.5.0/bin/:$PATH"
export PYENV_ROOT=$(pyenv root)
export PATH="$PYENV_ROOT/shims:$PATH"

export PATH="/usr/local/opt:$PATH"

alias xclip='xclip -selection clipboard'
alias tcp='tmux show-buffer | xclip'

alias k=kubectl
alias tf=terraform

alias now="date +'%Y-%m-%d-%H.%M.%S'"

# Use a pythonrc file
export PYTHONSTARTUP="$HOME/.pythonrc"
# various shortcuts
alias hgrep='history 0 | grep'
# use virtualenv version of ipython if present
alias ipy="python -c 'import IPython; IPython.terminal.ipapp.launch_new_instance()'"

# Get colors and extensions and run them
autoload colors && colors
# Make TeX behave
export TEXINPUTS=".:~/myLaTeX:"
# Use coreutils instead of whatever mac provides
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
export PATH="$(brew --prefix)/bin:$PATH"

# Custom ls colors
export LS_COLORS="di=1;34:ln=1;35:so=31:pi=31:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
alias ls='ls -F --color=auto'

# Color tab/^D completion like ls
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
autoload -Uz compinit
compinit

# Enable autocompletion inside git repositories
fpath=(~/.zsh $fpath)
autoload -Uz compinit && compinit
# zstyle ':completion:*:*:git:*' script ~/.git-completion.sh
#
# enable auto-completion (requires brew install bash-completion)
if [ -f /opt/local/etc/profile.d/bash_completion.sh ]; then
    . /opt/local/etc/profile.d/bash_completion.sh
fi

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

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Use starship for command prompt
eval "$(starship init zsh)"

# zoxide is a really fancy and fun replacement for cd
# configuration described here: https://github.com/ajeetdsouza/zoxide
eval "$(zoxide init zsh)"

# bat is a nice replacement for cat
export BAT_THEME='OneHalfLight'

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)


###########
# RESCALE #
###########
# Get all django endpoints from web
alias endpoints='source ~/code/rescale/venv/bin/activate && cd ~/code/rescale/rescale-platform-web/ && ./manage.py show_urls'

# boundary aliases
alias boundary-build=rescale-boundary-proxy-build-server
alias boundary-ssh=rescale-boundary-ssh

# API keys stored in a separate file so I can version control this one.
source ~/.apikey_script

export RESCALE_METADATA_BASE=/Users/zeph/code/rescale/rescale-platform-metadata

function awsenv {
    pushd /Users/zeph/code/rescale/support-tools/aws-cli-wrappers
    source aws-cli-environment $1 $2
    popd
}

# Use lnav on local platform
alias lnav-local='lnav ~/.pm2/logs/celery*.log ~/.pm2/logs/django*.log ~/.pm2/logs/jobstarter*.log ~/.pm2/logs/service*.log ~/.pm2/logs/watch-web*.log'
alias start-java='pm2 start jobstarter service'
alias stop-java='pm2 stop jobstarter service'
alias restart-java='pm2 restart jobstarter service'
alias start-python='pm2 start celery celery-beat django watch-web'
alias stop-python='pm2 stop celery celery-beat django watch-web'
alias restart-python='pm2 restart celery celery-beat django watch-web'
alias start-tunnel='pm2 start tunnel-cluster tunnel-web'
alias stop-tunnel='pm2 stop tunnel-cluster tunnel-web'
alias restart-tunnel='pm2 restart tunnel-cluster tunnel-web'
alias restart-build='pm2 stop build;sudo kill $(sudo lsof -i :443 | grep boundary | awk "{print $2}"); sudo -k;pm2 start build'
alias stop-build='pm2 stop build;sudo kill $(sudo lsof -i :443 | grep boundary | awk "{print $2}"); sudo -k'
alias start-build='pm2 start build'

# Enable us-east-2 for linden enablement on local platform
export RESCALE_REGIONS='us-east-1 us-east-2'

export RESCALE_INFRA_USER=zeph

# Boundary config
export RESCALE_BOUNDARY_UTILS=$HOME/code/rescale/infrastructure-access/boundary/utils
source $RESCALE_BOUNDARY_UTILS/rescale-boundary-helper-functions.sh
export RESCALE_BOUNDARY_JOB_SERVICE_PORT=8005
export RESCALE_BOUNDARY_CLUSTER_SERVICE_PORT=8006

###############################################
# Everything below here was added by a script #
###############################################

export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
