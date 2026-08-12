fpath=(/opt/homebrew/opt/zsh/share/zsh/functions $fpath)
eval "$(starship init zsh)"
source <(fzf --zsh)

alias cat="bat --paging=never"
alias tmux-main="tmux new -A -s main"
alias tmux-ai="tmux new -A -s AI"

# Set the DOTNET_ROOT environment variable to the correct path for Zed
export DOTNET_ROOT=/opt/homebrew/opt/dotnet/libexec
export DOTNET_ROOT_ARM64=/opt/homebrew/opt/dotnet/libexec

export PATH=/opt/homebrew/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.lmstudio/bin:$DOTNET_ROOT:$HOME/.cargo/bin:$HOME/Library/pnpm/bin:$PATH

claude-local() {
  if [ $# -lt 1 ]; then
    echo "Error: model name required" >&2
    return 1
  fi

  local model="$1"
  shift

  CLAUDE_CODE_SUBAGENT_MODEL="$model" \
  ANTHROPIC_BASE_URL=http://192.168.1.2:8000 \
  ANTHROPIC_AUTH_TOKEN=dummy \
  ANTHROPIC_DEFAULT_OPUS_MODEL="$model" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="$model" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="$model" \
  claude --append-system-prompt 'Language policy: Use English for all user-visible text, including thinking summaries, plans, tool commentary, and final answers. Never infer a language change.' --model "$model" "$@"
}

autoload -Uz compinit && compinit

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
