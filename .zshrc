eval "$(starship init zsh)"
source <(fzf --zsh)

alias cat="bat --paging=never"

# Set the DOTNET_ROOT environment variable to the correct path for Zed
export DOTNET_ROOT=/opt/homebrew/opt/dotnet/libexec
export DOTNET_ROOT_ARM64=/opt/homebrew/opt/dotnet/libexec

export PATH=/opt/homebrew/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.lmstudio/bin:$DOTNET_ROOT:$PATH

claude-local() {
  if [ $# -lt 1 ]; then
    echo "Error: model name required" >&2
    return 1
  fi

  local model="$1"
  shift

  ANTHROPIC_BASE_URL=http://localhost:1234 \
  ANTHROPIC_AUTH_TOKEN=lmstudio \
  claude --model "$model" "$@"
}

autoload -Uz compinit && compinit

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

_ssh_tmux_pane_title() {
  emulate -L zsh

  local destination host configured_host arg option_arg
  local -a ssh_config_args

  while [ $# -gt 0 ]; do
    arg="$1"
    shift

    case "$arg" in
      --)
        [ $# -gt 0 ] && destination="$1"
        break
        ;;
      -[46AaCfGgKkMNnqsTtVvXxYy])
        ssh_config_args+=("$arg")
        ;;
      -[BCbcDEeFIiJLlmOoPpQRSWw])
        if [ $# -gt 0 ]; then
          option_arg="$1"
          shift
          ssh_config_args+=("$arg" "$option_arg")
        else
          ssh_config_args+=("$arg")
        fi
        ;;
      -[BCbcDEeFIiJLlmOoPpQRSWw]*)
        ssh_config_args+=("$arg")
        ;;
      -*)
        ssh_config_args+=("$arg")
        ;;
      *)
        destination="$arg"
        break
        ;;
    esac
  done

  [ -n "$destination" ] || return 1

  host="${destination##*@}"
  host="${host#\[}"
  host="${host%\]}"

  configured_host="$(command ssh -G "${ssh_config_args[@]}" -- "$destination" 2>/dev/null | awk '$1 == "hostname" { print $2; exit }')"
  [ -n "$configured_host" ] && host="$configured_host"

  print -r -- "$host"
}

ssh() {
  emulate -L zsh

  local pane_id previous_title previous_allow_set_title ssh_title ssh_status

  if [ -n "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
    pane_id="$(command tmux display-message -p '#{pane_id}' 2>/dev/null)"
    if [ -z "$pane_id" ]; then
      command ssh "$@"
      return $?
    fi

    previous_title="$(command tmux display-message -p -t "$pane_id" '#{pane_title}' 2>/dev/null)"
    previous_allow_set_title="$(command tmux show-option -pqv -t "$pane_id" allow-set-title 2>/dev/null)"
    ssh_title="$(_ssh_tmux_pane_title "$@")"

    if [ -n "$ssh_title" ]; then
      command tmux set-option -pq -t "$pane_id" allow-set-title off
      command tmux select-pane -t "$pane_id" -T "$ssh_title" 2>/dev/null
    fi

    command ssh "$@"
    ssh_status=$?

    if [ -n "$ssh_title" ]; then
      command tmux select-pane -t "$pane_id" -T "$previous_title" 2>/dev/null
      if [ -n "$previous_allow_set_title" ]; then
        command tmux set-option -pq -t "$pane_id" allow-set-title "$previous_allow_set_title"
      else
        command tmux set-option -pqu -t "$pane_id" allow-set-title
      fi
    fi

    return "$ssh_status"
  fi

  command ssh "$@"
}
