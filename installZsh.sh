echo "install zsh and git"
echo ""
sudo apt install zsh -y
sudo apt-get install git -y
git clone https://github.com/robbyrussell/oh-my-zsh.git ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

echo ""
echo "Set custom oh-my-zsh settings"
sed -i 's/robbyrussell/agnoster/g' $HOME/.zshrc
sed -i 's/prompt_segment blue $CURRENT_FG/prompt_segment red white/g' ~/.oh-my-zsh/themes/agnoster.zsh-theme
sed -i 's/prompt_segment black/prompt_segment blue/g' ~/.oh-my-zsh/themes/agnoster.zsh-theme
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh-syntax-highlighting" --depth 1

echo ""
echo "Install Syntax Highlighting"
echo "source $HOME/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$HOME/.zshrc"

echo ""
echo "Set oh-my-zsh as default shell"
sudo chsh -s /bin/zsh $1
