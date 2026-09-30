fpath=(/opt/homebrew/opt/zsh/share/zsh/functions $fpath)

eval "$(/opt/homebrew/bin/brew shellenv zsh)"
eval "$(starship init zsh)"

autoload -Uz compinit && compinit

source <(fzf --zsh)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias cat="bat --paging=never"
alias container-prune-all='container delete --all --force && container image delete --all && container volume delete --all && container network delete --all'
alias mlx='source "$HOME/local-llm/.venv/bin/activate"'
alias tmux-ai="tmux new -A -s AI"
alias tmux-main="tmux new -A -s main"

export PATH="$HOME/.cargo/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

[ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh"

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
  ANTHROPIC_AUTH_TOKEN="$VLLM_API_KEY" \
  ANTHROPIC_DEFAULT_OPUS_MODEL="$model" \
  ANTHROPIC_DEFAULT_SONNET_MODEL="$model" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="$model" \
  claude --append-system-prompt '• Communicate in English using a natural, consistent tone. • Do not include disclaimers or apologies; avoid filler, fluff, or “as an AI”. • Prioritize accuracy, clear logic, and actionable results. • When uncertain, ask clarifying questions before generating a response. • Prefer responses in structured formats: bullets, code + test blocks, tables where applicable. Do not use emojis. • If a task requires multi-step reasoning, explicitly break it into steps. • When outputting technical content (e.g., code or commands), include self-checking instructions or simple validation examples.' --model "$model" "$@"
}

mlx-update() {
  local py="$HOME/local-llm/.venv/bin/python"

  if [[ ! -x "$py" ]]; then
    printf 'Virtual environment not found: %s\n' "$py" >&2
    return 1
  fi

  "$py" -m pip install --upgrade pip &&
  "$py" -m pip install --upgrade --upgrade-strategy eager mlx mlx-lm 'mlx-vlm[ui]' &&
  "$py" -m pip check
}

mlx-server() {
  local server="$HOME/local-llm/.venv/bin/mlx_lm.server"

  if [[ ! -x "$server" ]]; then
    printf 'MLX server executable not found: %s\n' "$server" >&2
    return 1
  fi

  "$server" \
    --model mlx-community/Qwen3.8-27B-8bit \
    --host 127.0.0.1 \
    --port 8081 \
    --max-tokens 4096 \
    --temp 0.7 \
    --top-p 0.8 \
    --top-k 20 \
    --prompt-cache-size 1 \
    --chat-template-args '{"enable_thinking":false}' \
    "$@"
}
