set -e

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

echo "Powerlevel10k installed! Restart your terminal or run 'source ~/.zshrc' to start using it."
echo "The first time you start zsh, Powerlevel10k will guide you through configuration."
