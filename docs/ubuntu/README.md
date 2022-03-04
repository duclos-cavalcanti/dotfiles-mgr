# Table of Contents
1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Maintenance](#maintenance)
3. [Alternate Systems](#alternate)

<a name="installation"/>

## 1. Installation Ubuntu System
Regular calamares installation.

<a name="configuration"/>

## 2. Configuration
```
TODO: automate ubunut debian installation with script
```

#### 2.1 Upgrade package base
```sh
sudo apt upgrade
```

#### 2.2 Install essential packages

1. Apt Packages
```
sudo apt install \
    vim git stow cmake ctags \
    fzf ripgrep arc-theme \
    pavucontrol plantuml
```

2. Snap Packages
```
sudo snap install alacritty spotify brave
```

#### 2.3  Enable necessary services
```sh
TODO
```

#### 2.4 System File structure

```sh
mkdir -p ~/Documents/work
mkdir -p ~/.config
mkdir -p ~/.bin

cd ~/Documents
git clone https://github.com/duclos-cavalcanti/dotfiles.git

# Stow the dotfiles
```
#### 2.6 Reboot
1. Reboot
