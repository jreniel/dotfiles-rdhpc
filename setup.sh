#!/bin/bash

# ----------------------
# Setup proxy
# ----------------------
if ! [[ -v http_proxy ]]; then
    export http_proxy=http://localhost:11598
fi

if ! [[ -v https_proxy ]]; then
    export https_proxy=http://localhost:11598
fi

if ! [[ -v ftp_proxy ]]; then
    export ftp_proxy=http://localhost:11598
fi

# --------------------------
# Check internet connection
# --------------------------
wget -q --spider http://google.com
if [ $? -eq 0 ]; then :
else
    echo "No internet connection"
    exit -1    
fi

mkdir -p $HOME/.local

# ---------------------------
# zsh setup and configuration
# ---------------------------

# download and install zsh if not available
if ! [ -x "$(command -v zsh)" ]; then
    wget -O zsh.tar.xz https://sourceforge.net/projects/zsh/files/latest/download
    mkdir zsh && unxz zsh.tar.xz && tar -xvf zsh.tar -C zsh --strip-components 1
    cd zsh
    ./configure --prefix=$HOME/.local
    make -j$(nproc)
    make install
   cd ..
   rm -rf zsh
fi

# set zsh with oh-my-zsh as default shell
if ! [ -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Check if zsh is default shell, if not set it
read -r -d '' DEFAULT_LOGIN << "EOF"
if [[ $- == *i* ]]; then
    if [ -z ${SLURM_SUBMIT_DIR+x} ]; then
        exec zsh -l
    else
        test -s ~/.alias && . ~/.alias || true
        export PS1="\n\[$(tput sgr0)\]\[\033[38;5;2m\]\d\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;33m\]\t\[$(tput sgr0)\]\[\033[38;5;15m\]\n\[$(tput sgr0)\]\[\033[38;5;11m\]\w\[$(tput sgr0)\]\[\033[38;5;15m\]\n\[$(tput sgr0)\]\[\033[38;5;49m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\]@\[$(tput sgr0)\]\[\033[38;5;9m\]\H\[$(tput sgr0)\]\[\033[38;5;15m\]: \[$(tput sgr0)\]"     
    fi
fi
EOF
if ! grep -q $DEFAULT_LOGIN $HOME/.bashrc; then
    echo "$DEFAULT_LOGIN" >> $HOME/.bashrc
fi

# set zshrc file for hera/jet
if ! [[ -z $1 ]]; then
    if [ -f "$HOME/.zshrc" ]; then
        mv $HOME/.zshrc $HOME/.zshrc.$(date +%Y-%m-%dT%H:%M:%S)
    fi
    if [ $1 == 'hera' ]; then
        git clone https://gist.github.com/jreniel/70bbae3fce761ad263f418134d4b2e4f zshrc
        mv zshrc/hera.zsh $HOME/.zshrc
    fi
    if [ $1 == 'jet' ]; then
        echo "Jet zshrc is not set!!"
        exit -1
    fi
    rm -rf zshrc
fi

# ---------------------------------------
# Check for tmux and dependencies
# ---------------------------------------

if ! [ -x "$(command -v tmux)" ]; then
    if [ -d "c79688739f1cf25e99346ce7533c73f9" ]; then
        rm -rf c79688739f1cf25e99346ce7533c73f9
    fi   
    git clone https://gist.github.com/jreniel/c79688739f1cf25e99346ce7533c73f9
    bash c79688739f1cf25e99346ce7533c73f9/tmux_local_install.sh
    rm -rf c79688739f1cf25e99346ce7533c73f9
fi

# ----------------------------------------
# deploy tmux package manager
# ----------------------------------------
if ! [ -d $HOME/.tmux/plugins/tmux ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
git clone https://gist.github.com/jreniel/1d794a2e1ae05e35570031ec2e7b6a96 tmux
mv tmux/.tmux.conf $HOME/.tmux.conf
rm -rf tmux




# --------------------------------------------
# Deploy vimrc
# --------------------------------------------
if [ -d vimrc ]; then
    rm -rf vimrc
fi
git clone https://gist.github.com/jreniel/9a22f971ce081da54fc6ee1fcba7445c vimrc
mv vimrc/.vimrc $HOME/.vimrc
rm -rf vimrc
vim +'PlugInstall --sync' +qa


