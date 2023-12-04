#!/bin/bash

# Exit on any error
set -e

# Check if GIT_USER and GIT_EMAIL environment variables are set
if [ -z "$GIT_USER" ] || [ -z "$GIT_EMAIL" ]; then
    echo "Error: GIT_USER and GIT_EMAIL environment variables are not set."
    echo "Usage: export GIT_USER='Your Name'; export GIT_EMAIL='your_email@example.com'; ./setup-server.sh"
    exit 1
fi

# Update and upgrade the system
echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y

# Install common packages
echo "Installing common packages..."
sudo apt install -y vim git curl wget ufw fail2ban htop zsh

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Setting zsh as the default shell..."
chsh -s $(which zsh)

echo "Installing plugins..."
# Install zsh-autosuggestions
echo "Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# Install zsh-syntax-highlighting
echo "Installing zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# Add plugins to .zshrc
echo "Adding zsh-autosuggestions and zsh-syntax-highlighting to .zshrc..."
sed -i '/^plugins=(git)/ a plugins+=(zsh-autosuggestions zsh-syntax-highlighting)' ~/.zshrc

# Set Git username and email using the provided environment variables
echo "Setting Git username and email..."
git config --global user.name "$GIT_USER"
git config --global user.email "$GIT_EMAIL"
# Set Vim as the default Git editor
git config --global core.editor "vim"

# Install pyenv
echo "Installing pyenv..."
curl https://pyenv.run | bash

# The following lines are added to .zshrc instead of .bashrc for Zsh configuration
echo "Setting up pyenv..."
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init --path)"' >> ~/.zshrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
# Apply the changes to the current session
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

# Set up a firewall with UFW
echo "Setting up the firewall..."
sudo ufw allow OpenSSH
sudo ufw --force enable
sudo ufw status

# Install and configure SSH
echo "Installing and configuring SSH..."
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

# Install Docker
echo "Installing Docker and Docker Compose..."
# Add Docker's official GPG key and repository, then install Docker
sudo apt update
sudo apt install -y ca-certificates gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the current user to the Docker group
echo "Adding user to the Docker group..."
sudo usermod -aG docker $USER

# Output Docker and Docker Compose versions
echo "Docker and Docker Compose installed:"
docker --version
docker-compose --version

# Additional setup can go here...

echo "Home server setup script has completed."
echo "You will need to log out and back in for the usermod and default shell changes to take effect."
echo "Please restart your shell or run 'source ~/.zshrc' to apply pyenv and Oh My Zsh settings."