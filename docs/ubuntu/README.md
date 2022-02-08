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
#### 2.5 Vim
1. Install Plugins
```sh
vim .
:PlugInstall<CR>
```

2. LSP/Language Server Client: ddc.vim
[lsp.vim](https://github.com/prabirshrestha/vim-lsp)
[asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)

For other language installations go to [this link](Link).

```sh
# depends on clangd for C/C++
sudo pacman -S clang

# depends on pyls for Python
pip install python-language-server

# many languages may depend on npm
# sudo pacman -S nodejs npm
```
3.
```sh
```

4.
```sh
```
#### 2.6 Reboot
1. Reboot
