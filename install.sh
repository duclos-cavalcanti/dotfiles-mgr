#!/bin/bash

BASE_PACKAGES="packages/base.txt"
HARDWARE_PACKAGES="packages/hardware.txt"
XORG_PACKAGES="packages/xorg.txt"
CORE_PACKAGES="packages/core.txt"
DEV_PACKAGES="packages/dev.txt"
DESKTOP_PACKAGES="packages/desktop.txt"

SERVICES="services/services.txt"

local FILESYSTEM=(
"${HOME}/Desktop"
"${HOME}/Documents"
"${HOME}/Downloads"
"${HOME}/Music"
"${HOME}/Pictures"
"${HOME}/Programs"
"${HOME}/Videos"
"${HOME}/.config"
"${HOME}/.bin"
"${HOME}/Documents/uni"
"${HOME}/Documents/work"
"${HOME}/Documents/projects"
"${HOME}/Documents/projects/ai"
"${HOME}/Documents/projects/dsa"
"${HOME}/Documents/projects/embedded"
"${HOME}/Documents/projects/hw"
"${HOME}/Documents/projects/langs"
"${HOME}/Documents/projects/langs/cpp"
"${HOME}/Documents/projects/langs/rust"
"${HOME}/Documents/projects/langs/lua"
"${HOME}/Documents/projects/langs/python"
"${HOME}/Documents/projects/personal"
"${HOME}/Documents/projects/templates"
"${HOME}/Documents/projects/tutorials"
)

SSHKEY="${HOME}/.ssh/id_ed25519.pub"

PROJECTS="${HOME}/Documents/projects"
GITHUB="git@github.com:duclos-cavalcanti"

# debugging
# set -e

echo -ne "
--------------------------------------------------------------------------
                    Automated Arch Linux Installer
--------------------------------------------------------------------------
"
echo "Checking Dependencies..."
if ! [ -f $SSHKEY ]; then
    echo "ssh key is needed to pull down git projects!"
    exit -1
fi

for file in $BASE_PACKAGES $HARDWARE_PACKAGES $XORG_PACKAGES $CORE_PACKAGES $DEV_PACKAGES $DESKTOP_PACKAGES; do 
    if ! [ -f $file ]; then
        echo "package file $f doesn't exist!"
        exit -1
    fi
done

echo "All Good!"
echo -ne "
--------------------------------------------------------------------------
                    1. Installing Packages
--------------------------------------------------------------------------
"

function install_package_list() {
    # package list
    cat $1 | \
    while read pkg ; do
        if [[ $pkg =~ '^#' ]]; then
            continue
        else
            echo "Installing $pkg ..."
            sudo pacman -S --noconfirm --needed $pkg
        fi
    done
}


echo -ne "
*****************************
1.1 Base
*****************************
"
install_package_list $BASE_PACKAGES

echo -ne "
*****************************
1.2 Hardware
*****************************
"
install_package_list $HARDWARE_PACKAGES

echo -ne "
*****************************
1.3 Xorg
*****************************
"
install_package_list $XORG_PACKAGES

echo -ne "
*****************************
1.4 Core
*****************************
"
install_package_list $CORE_PACKAGES

echo -ne "
*****************************
1.5 Dev
*****************************
"
install_package_list $DEV_PACKAGES

echo -ne "
*****************************
1.6 Desktop
*****************************
"
install_package_list $DESKTOP_PACKAGES

echo -ne "
*****************************
1.7 Language-related
*****************************
"
echo "Installing Python Packages..."
pip install compiledb pyright ipython ipdb

echo "Installing Rust Packages..."
rustup update stable
rustup component add rls rust-analysis rust-src

rustup toolchain install nightly
rustup component add rls rust-analysis rust-src --toolchain nightly
rustup override set nightly

if [ -d ~/.local/bin ]; then
    pushd ~/.local/bin
        curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
        chmod +x rust-analyzer
    popd
else
    echo "Need .local/bin to install rust-analyzer"
fi

echo "Installing Go Packages..."
go install golang.org/x/tools/gopls@latest

echo "Installing Npm Packages..."
sudo npm i -g bash-language-server

echo -ne "
--------------------------------------------------------------------------
                    2. AUR
--------------------------------------------------------------------------
"
owner=$(stat -c "%U" /opt)
if [[ "$owner" != "$(whoami)" ]]; then
    echo "Owning /opt directory..."
    user=$(whoami)
    sudo chown -R ${user}:${user} /opt
fi

pushd /opt
    if ! command -v paru; then
        git clone https://aur.archlinux.org/paru.git
        pushd paru 
            makepkg -si
        popd
    fi
    # paru -S zoom spotify
popd

echo -ne "
--------------------------------------------------------------------------
                    3. Starting Services
--------------------------------------------------------------------------
"
cat $SERVICES | \
while read service; do
    if [[ $service =~ '^#' ]]; then
        continue
    else
        echo "Setting $service ..."
        status=$(systemctl is-active $service)
        if [ "$status" = "active" ]; then 
            continue
        else
            echo "$service"
            sudo systemctl enable $service
        fi
    fi
done

echo -ne "
--------------------------------------------------------------------------
                    4. Filesystem
--------------------------------------------------------------------------
"
for p in ${FILESYSTEM[@]}; do 
    if ! [ -d $p ]; then
        mkdir -pv $p
    else 
        echo "$p already exists!"
    fi
done


if [ -f $SSHKEY ]; then
    pushd ${PROJECTS}
        pushd personal
            personal_repos=(duclos-cavalcanti duclos-cavalcanti.github.io curriculum-vitae)
            for repo in ${personal_repos[@]}; do
                if ! [ -d $repo ]; then
                    git clone "${GITHUB}/${repo}.git"
                fi
            done
        popd
    popd
else
    echo "Can't pull down git project with no SSH credentials!"
    exit -1
fi

echo -ne "
--------------------------------------------------------------------------
                    5. Dotfiles
--------------------------------------------------------------------------
"
if [ -f $SSHKEY ]; then
    pushd ${HOME}
        if ! [ -d .dotfiles ]; then
            git clone "${GITHUB}/dotfiles.git" .dotfiles
            if [ $? -eq 0 ]; then
                pushd .dotfiles 
                    ./install.sh pc install
                popd
                if command -v nvim; then
                    echo "Updating nvim..."
                    nvim . +PackerSync +qa!
                fi
            else
                echo "Dotfiles pull down hasnt worked!"
                exit -1
            fi
        else
            echo "dotfiles aleady installed!"
        fi
    popd
else
    echo "Can't pull down git project with no SSH credentials!"
    exit -1
fi
