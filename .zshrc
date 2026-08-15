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
  if [ $# -lt 2 ]; then
    echo "Usage: claude-local <model-name> <context-length> [claude-args...]" >&2
    return 1
  fi

  local model="$1"
  local context_length="$2"
  shift 2

  CLAUDE_CODE_SUBAGENT_MODEL="$model" \
  CLAUDE_CODE_MAX_CONTEXT_TOKENS="$context_length" \
  ANTHROPIC_BASE_URL=http://192.168.1.2:8000 \
  ANTHROPIC_AUTH_TOKEN=dummy \
  ANTHROPIC_DEFAULT_OPUS_MODEL="$model" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="$model" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="$model" \
  claude --append-system-prompt '• Communicate in English using a natural, consistent tone. • Do not include disclaimers or apologies; avoid filler, fluff, or “as an AI”. • Prioritize accuracy, clear logic, and actionable results. • When uncertain, ask clarifying questions before generating a response. • Prefer responses in structured formats: bullets, code + test blocks, tables where applicable. Do not use emojis. • If a task requires multi-step reasoning, explicitly break it into steps. • When outputting technical content (e.g., code or commands), include self-checking instructions or simple validation examples.' --model "$model" "$@"
}

autoload -Uz compinit && compinit

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
