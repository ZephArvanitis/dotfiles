# GENERAL
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/share/dotnet:$PATH"
export PATH="/Users/zeph/.local/bin:$PATH"
export PATH="/opt/homebrew/bin:$PATH"
export PATH="/Library/Tex/texbin:$PATH"
export PATH="/usr/local/Cellar/mssql-tools/14.0.5.0/bin/:$PATH"
export PYENV_ROOT=$(pyenv root)
export PATH="$PYENV_ROOT/shims:$PATH"
export PYENV_ROOT=$(pyenv root)
export PATH="$PYENV_ROOT/shims:$PATH"
eval "$(pyenv init -)"
export PATH="/usr/local/opt/gettext/bin:$PATH"

export PATH="/usr/local/opt:$PATH"

alias xclip='xclip -selection clipboard'
alias tcp='tmux show-buffer | xclip'

alias k=kubectl
alias g=git
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

# reverse history search
bindkey '^R' history-incremental-search-backward

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
# Share between different shells
setopt share_history

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
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES # for some reason necessary to avoid infinite errors in celery worker? https://stackoverflow.com/a/52230415

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

docker-login() {
    # Take a profile argument, do sso login if necessary and then pass
    # creds to docker
    set -x
    if ! aws sts get-caller-identity --profile $1; then
        aws sso login --profile $1
    fi

    ACCOUNT=$(aws sts get-caller-identity --query 'Account' --profile $1 --output text)
    REGION=$(aws configure get region --profile $1)

    aws --profile $1 ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr-fips.$REGION.amazonaws.com
    aws --profile $1 ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT.dkr.ecr.$REGION.amazonaws.com
}

run-claude() {
    ENV="ai-dev"
    SSO_ACCOUNT=$(aws sts get-caller-identity --query "Account" --profile $ENV)
    RET_VAL=$?

    if [[ "$RET_VAL" -eq 0 ]]; then
        echo "AWS SSO Session is active for account: $SSO_ACCOUNT"
    else
        echo "AWS SSO Session is inactive. Re-authenticating"
        aws --profile $ENV sso login
    fi

    # Enable Bedrock integration
    export CLAUDE_CODE_USE_BEDROCK=1
    export AWS_REGION=us-west-2
    export CLAUDE_CODE_MAX_OUTPUT_TOKENS=8192
    export MAX_THINKING_TOKENS=1024
    export AWS_PROFILE=ai-dev

    export ANTHROPIC_DEFAULT_HAIKU_MODEL='arn:aws:bedrock:us-west-2:804686432236:application-inference-profile/yuar18tste9m'
    export ANTHROPIC_DEFAULT_OPUS_MODEL='arn:aws:bedrock:us-west-2:804686432236:application-inference-profile/ev0b0i920cy1'
    export ANTHROPIC_DEFAULT_SONNET_MODEL='arn:aws:bedrock:us-west-2:804686432236:application-inference-profile/n4ktxl8fuuuf'
    export ANTHROPIC_SMALL_FAST_MODEL='arn:aws:bedrock:us-west-2:804686432236:application-inference-profile/yuar18tste9m'

    # if using subagents uncomment and set accordingly
    # export CLAUDE_CODE_SUBAGENT_MODEL='<sonnet app-inference-profile-arn-from-command-result-above>'

    claude
}

get-cnde-api-pod() {
    k get pods | grep web-api | cut -f 1 -d " "
}

get-cnde-celery-pod() {
    k get pods | grep celery-worker | cut -f 1 -d " "
}

deprod-grafana() {
    aws eks update-kubeconfig --region eu-central-1 --name deprod-infra --profile prod

    kubectl get secret --namespace platform-metrics grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    POD_NAME=$(kubectl get pods --namespace platform-metrics -l "app.kubernetes.io/name=grafana,app.kubernetes.io/instance=grafana" -o jsonpath="{.items[0].metadata.name}")

    kubectl --namespace platform-metrics port-forward $POD_NAME 3000
}
func prepend() {
  while read line; do echo "${1}${line}"; done
}

func git-grep-multi() {
  list=""
  dir="."
  pattern=""
  sep=": "
  local OPTIND
  while getopts 'lfd:p:' flag; do
    case "${flag}" in
      l) list='-l' ;;
      d) dir="${OPTARG}" ;;
      p) pattern="${OPTARG}" ;;
      f) sep="/" ;;
      *) "unknown option ${flag}"; return 1 ;;
    esac
  done

  if [ -z "$pattern" ]; then
    echo "Pattern not provided."
    return 1
  fi

  for repo in $(find ${dir} -maxdepth 2 -name ".git" | xargs dirname); do
    prefix="$(basename $repo)"
    if [ -n "$list" ]; then
      prefix=$repo
    fi

    (cd $repo && git --no-pager grep ${list} --color=always "${pattern}" | prepend "${prefix}${sep}")
  done
}

export RESCALE_ROOT_DIR=~/code/rescale

function rgrep() {
  list=""
  fullpath=""
  local OPTIND
  while getopts 'lf' flag; do
    case "${flag}" in
      l) list='-l' ;;
      f) fullpath='-f' ;;
      *) "unknown option ${flag}"; return 1 ;;
    esac
  done
  shift $((OPTIND-1))
  git-grep-multi ${list} ${fullpath} -d ${RESCALE_ROOT_DIR-~/rescale} -p $1
}

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

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/zeph/Downloads/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/zeph/Downloads/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/zeph/Downloads/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/zeph/Downloads/google-cloud-sdk/completion.zsh.inc'; fi
export PATH="/opt/homebrew/opt/haproxy@2.8/bin:$PATH"
