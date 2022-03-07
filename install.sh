#!/bin/bash

SSHKEY="${HOME}/.ssh/id_ed25519.pub"
PROJECTS="${HOME}/Documents/projects"
GITHUB="git@github.com:duclos-cavalcanti"

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
"${HOME}/Documents/projects/langs/c"
"${HOME}/Documents/projects/langs/cpp"
"${HOME}/Documents/projects/langs/lisp"
"${HOME}/Documents/projects/langs/haskell"
"${HOME}/Documents/projects/langs/go"
"${HOME}/Documents/projects/langs/rust"
"${HOME}/Documents/projects/langs/lua"
"${HOME}/Documents/projects/langs/python"
"${HOME}/Documents/projects/personal"
"${HOME}/Documents/projects/templates"
"${HOME}/Documents/projects/tutorials"
)

# debugging
# set -e

function greeting() {
    echo -ne "
     _______________________________ 
    |  ___________________________  |
    | |  Automated Arch Installer | |
    | |___________________________| |
    |_______________________________|

    Welcome!
    "
    sleep 5s
    echo "Checking Dependencies..."; sleep 0.5s
    if ! [ -f $SSHKEY ]; then
        echo "ssh key is needed to pull down git repos!"
        exit -1
    fi
    
    for file in $BASE_PACKAGES $HARDWARE_PACKAGES $XORG_PACKAGES $CORE_PACKAGES $DEV_PACKAGES $DESKTOP_PACKAGES; do 
        if ! [ -f $file ]; then
            echo "package file $f doesn't exist!"
            exit -1
        fi
    done
    
    echo "All Good!"
}

function step() {
    number="$1"
    title="$2"

    clear
    echo -ne "
    --------------------> ${number}: ${title}\n
    "
    sleep 5s
}

function sub_step() {
    number="$1"
    title="$2"

    clear
    echo -ne "
    --------> ${number}: ${title}\n
    "
    sleep 2s
}

function install_packages() {
    step 1 "Installing Packages"

    local function get_packages() {
        # package list
        cat $1 | \
        while read pkg ; do
            if [[ $pkg =~ '^#' ]]; then
                continue
            else
                echo "Installing $pkg ..."
                sudo pacman -S --noconfirm --needed $pkg
                sleep 0.5
            fi
        done
    }

    sub_step "1.1" "Base"
    get_packages $BASE_PACKAGES

    sub_step "1.2" "Hardware"
    get_packages $HARDWARE_PACKAGES

    sub_step "1.3" "Xorg"
    get_packages $XORG_PACKAGES

    sub_step "1.4" "Core"
    get_packages $CORE_PACKAGES

    sub_step "1.5" "Dev"
    get_packages $DEV_PACKAGES

    sub_step "1.6" "Desktop"
    get_packages $DESKTOP_PACKAGES

    sub_step "1.7" "Language-Related"
    echo "Installing Python Packages..."

    if command -v pip; then
        pip install compiledb pyright ipython ipdb
        pip install --user wpgtk
    else 
        echo "Pip isn't installed? Skipping Python..."
    fi
    
    echo "Installing Rust Packages..."

    if command -v rustup; then
        echo "Installing Rust Packages..."
        rustup update stable
        rustup component add rls rust-analysis rust-src
        
        rustup toolchain install nightly
        rustup component add rls rust-analysis rust-src --toolchain nightly
        rustup override set nightly
        # cargo install spotify-tui
        if [ -d ~/.local/bin ]; then
            pushd ~/.local/bin
                curl -L https://github.com/rust-analyzer/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz | gunzip -c - > ~/.local/bin/rust-analyzer
                chmod +x rust-analyzer
            popd
        else
            echo "Need .local/bin to install rust-analyzer..."
        fi
    else 
        echo "Rustup isn't installed? Skipping Rust..."
    fi

    if command -v go; then 
        echo "Installing Go Packages..."
        go install golang.org/x/tools/gopls@latest
    else 
        echo "Go isn't installed? Skipping Go..."
    fi

    if command -v npm; then 
        echo "Installing Npm Packages..."
        sudo npm i -g bash-language-server
    fi
}

function install_aur() {
    step 2 "Installing AUR"

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
        paru -S zoom
    popd
}

function start_services() {
    step 3 "Starting Services"
    cat $SERVICES | \
    while read service; do
        if [[ $service =~ '^#' ]]; then
            continue
        else
            status=$(systemctl is-active $service)
            if [ "$status" = "active" ]; then 
                echo "No need to set service $service ..."
                continue
            else
                echo "Setting $service ..."
                sudo systemctl enable $service
                sleep 0.5
            fi
        fi
    done
}

function create_filesystem() {
    step 4 "Filesystem"
    for p in ${FILESYSTEM[@]}; do 
        if ! [ -d $p ]; then
            echo "Creating $p!"
            mkdir -p $p
            sleep 0.5
        else 
            echo "$p already exists!"
        fi
    done

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
}

function install_dotfiles() {
    step 5 "Dotfiles"
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
}

function farewell() {
    echo -ne "
     _______________________ 
    |  ___________________  |
    | | Installation Done | |
    | |___________________| |
    |_______________________|
    "
}

function main() {
    greeting # says hi and checks for dependencies for this script
    install_packages
    install_aur
    start_services
    create_filesystem
    install_dotfiles 
    farewell # bye
}

main "$@"
