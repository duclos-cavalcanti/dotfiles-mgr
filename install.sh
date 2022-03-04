#!/bin/bash

BASE_PACKAGES="packages/base.txt"
HARDWARE_PACKAGES="packages/hardware.txt"
XORG_PACKAGES="packages/xorg.txt"
CORE_PACKAGES="packages/core.txt"
DEV_PACKAGES="packages/dev.txt"
DESKTOP_PACKAGES="packages/desktop.txt"

local FILESYSTEM = (
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

set -e

echo -ne "
--------------------------------------------------------------------------
                    Automated Arch Linux Installer
--------------------------------------------------------------------------
"

echo -ne "
--------------------------------------------------------------------------
                    1. Installing Packages
--------------------------------------------------------------------------
"

function install_package_list() {
    # package list
    cat $1 | \
    while read pkg ; do
        if [[ $pkg ~= ^# ]]; then
            # is a comment
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
1.5 Language-related
*****************************
"
echo "Installing Python Packages..."
pip install compiledb pyright ipython ipdb

echo "Installing Rust Packages..."
rustup update stable
rustup component add rls rust-analysis rust-src

echo -ne "
--------------------------------------------------------------------------
                    2. AUR
--------------------------------------------------------------------------
"
local owner=$(stat -c "%U" /opt)
if [[ "$owner" != "$(whoami)" ]]; then
    echo "Owning /opt directory..."
    local user=$(whoami)
    sudo chown -R ${user}:${user} /opt
fi

pushd /opt
    if ! command -v paru; then
        git clone https://aur.archlinux.org/paru.git
        pushd paru 
            makepkg -si
        popd
        
        paru -S zoom spotify
    fi
popd

echo -ne "
--------------------------------------------------------------------------
                    3. Starting Services
--------------------------------------------------------------------------
"
cat $1 | \
while read service ; do
    if [[ $service ~= ^# ]]; then
        # is a comment
    else
        echo "Setting $service ..."
        sudo systemctl enable $service
    fi
done

echo -ne "
--------------------------------------------------------------------------
                    4. Filesystem
--------------------------------------------------------------------------
"
for p in ${FILESYSTEM[@]}; do 
    mkdir -pv $p
done


if [ -f $SSHKEY ]; then
    pushd ${PROJECTS}
        pushd personal
            local personal_repos=(duclos-cavalcanti duclos-cavalcanti.github.io curriculum-vitae)
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
        fi
    popd
else
    echo "Can't pull down git project with no SSH credentials!"
    exit -1
fi
