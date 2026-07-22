## dotfiles

My personal dotfiles.

> [!WARNING]
> Caution: I use dotfiles managed through symlinks. The commands below are required to set them up on a new macOS installation:

```sh
brew bundle --file=~/Developer/dotfiles/Brewfile
echo '/opt/homebrew/bin/zsh' | sudo tee -a /etc/shells > /dev/null
chsh -s /opt/homebrew/bin/zsh
mkdir -p ~/.config/tmux ~/.claude
ln -sfn ~/Developer/dotfiles/.gitconfig ~/.gitconfig
ln -sfn ~/Developer/dotfiles/.gitignore_global ~/.gitignore_global
ln -sfn ~/Developer/dotfiles/.zshrc ~/.zshrc
ln -sfn ~/Developer/dotfiles/.zshenv ~/.zshenv
ln -sfn ~/Developer/dotfiles/.tmux.conf ~/.tmux.conf
ln -sfn ~/Developer/dotfiles/.config/tmux ~/.config
ln -sfn ~/Developer/dotfiles/.config/starship.toml ~/.config/starship.toml
ln -sfn ~/Developer/dotfiles/.config/zed ~/.config/zed
ln -sfn ~/Developer/dotfiles/.claude/hook-bg.sh ~/.claude/hook-bg.sh
ln -sfn ~/Developer/dotfiles/.claude/hook-pretool.sh ~/.claude/hook-pretool.sh
ln -sfn ~/Developer/dotfiles/.claude/statusline-command.sh ~/.claude/statusline-command.sh
ln -sfn ~/Developer/dotfiles/.claude/settings.json ~/.claude/settings.json
```

To apply macOS system preferences:

```sh
~/Developer/dotfiles/.macos
```
