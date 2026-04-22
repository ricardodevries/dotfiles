if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
  tmux new -A -s main
fi

eval "$(starship init zsh)"
source <(fzf --zsh)

alias cat="bat --paging=never"

# Set the DOTNET_ROOT environment variable to the correct path for Zed
export DOTNET_ROOT=/opt/homebrew/opt/dotnet/libexec
export DOTNET_ROOT_ARM64=/opt/homebrew/opt/dotnet/libexec

export PATH=/opt/homebrew/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:$HOME/.lmstudio/bin:$DOTNET_ROOT:$PATH
export NVM_DIR="$HOME/.nvm"

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

nvm() {
  unfunction nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}
node() { nvm --version > /dev/null 2>&1; unfunction node 2>/dev/null; node "$@"; }
npm()  { nvm --version > /dev/null 2>&1; unfunction npm  2>/dev/null; npm  "$@"; }
npx()  { nvm --version > /dev/null 2>&1; unfunction npx  2>/dev/null; npx  "$@"; }
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
