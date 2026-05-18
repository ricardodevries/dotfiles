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

if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux new -A -s main
fi
