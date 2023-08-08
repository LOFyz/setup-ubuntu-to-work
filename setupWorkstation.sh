sudo apt-get update
sudo apt-get upgrade -y

sudo apt-get install git zsh sed curl openjdk-18-jdk -y

# setup zsh
if [ -d ~/.oh-my-zsh ]; then
    echo "oh-my-zsh already installed"
else
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions  zsh-syntax-highlighting)/g' ~/.zshrc
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' ~/.zshrc
    chsh -s $(which zsh)
    echo "please re-run this script with zsh"
    exit 0
fi

# setup node
if [ -d ~/.nvm ]; then
    echo "nvm already installed"
else
    curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
fi

if grep -q 'nvm' ~/.zshrc; then
    echo "nvm already setted in .zshrc"
else
    echo "export NVM_DIR=\"\$HOME/.nvm\"" >>~/.zshrc
    echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\"" >>~/.zshrc
    echo "[ -s \"\$NVM_DIR/bash_completion\" ] && \. \"\$NVM_DIR/bash_completion\"" >>~/.zshrc
fi

. ~/.zshrc || echo "please re-run this script with zsh"

if which node >/dev/null; then
    echo "node already installed"
else
    nvm install --lts
fi

if which yarn >/dev/null; then
    echo "yarn already installed"
else
    npm install -g yarn
fi

# setup docker
if [ -d /etc/docker ]; then
    echo "docker already installed"
else
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
    sudo apt-get install ca-certificates curl gnupg

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
        "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |
        sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo groupadd docker
    sudo usermod -aG docker $USER
    newgrp docker

    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    sudo systemctl start docker.service
    sudo systemctl start containerd.service
fi

# setup maven
if [ -d /opt/apache-maven-3.9.4 ]; then
    echo "maven already installed"
else
    wget https://dlcdn.apache.org/maven/maven-3/3.9.4/binaries/apache-maven-3.9.4-bin.tar.gz
    tar -xvf apache-maven-3.9.4-bin.tar.gz
    rm apache-maven-3.9.4-bin.tar.gz
    sudo mv apache-maven-3.9.4 /opt/
fi

if grep -q 'maven' ~/.zshrc; then
    echo "maven already setted in .zshrc"
else
    echo "M2_HOME='/opt/apache-maven-3.9.4'" >>~/.zshrc
    echo "PATH=\"\$M2_HOME/bin:\$PATH\"" >>~/.zshrc
    echo "export PATH" >>~/.zshrc
fi

# setup github cli
if which gh >/dev/null; then
    echo "githubcli already installed"
else
    type -p curl >/dev/null || (sudo apt update && sudo apt install curl -y)
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &&
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg &&
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null &&
        sudo apt update &&
        sudo apt install gh -y
fi

# verify if gh is logged
if [ -d ~/.config/gh ]; then
    echo "githubcli already logged"
else
    gh auth login
fi
