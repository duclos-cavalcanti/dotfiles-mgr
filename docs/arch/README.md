# Table of Contents
1. [Installation](#installation)
2. [Configuration](#configuration)
3. [Maintenance](#maintenance)

<a name="installation"/>

## 1. Installation Arch System

#### 1.1 Set Keyboard Layout
List keyboard layouts:
```sh
ls /usr/share/kbd/keymaps/**/*.map.gz
```

Load keyboard layout:

```sh
loadkeys us
```
Console fonts are located at `/usr/share/kbd/consolefonts/` and can be set by `setfont`.

#### 1.2 Verify Boot Mode
`ls /sys/firmware/efi/efivars/`

If directory is shown with no error, system has booted in UEFI mode.

#### 1.3 Connect to the internet
- Ensure network interface is listed and enabled through `ip link`. 
- Connection is verified with `ping archlinux.org`.

#### 1.4 Update System Clock
```sh
# systemctl enable systemd-timesyncd, could be done later in install
timedatectl set-ntp true
```

#### 1.5 Update Pacman
```
pacman -Syy archlinux-keyring
```

#### 1.6 Disk Partitioning
Use `lsblk` or `fdisk -l` to list available block devices. 

Optional disk partitions:

1. EFI   300 MB /dev/sda1
2. Swap  8   GB /dev/sda2
3. root  32  GB  /dev/sda3
4. home  --  GB  /dev/sda4

- The main block device can also be named sbd or nvme0n1p depending on block devices. \
- The `mnt/boot` or `/mnt/efi` should be at least 160 MiB. 
- Swap should be more than 512 MiB.


Commands for partitioning:
```sh
cfdisk --zero /dev/sda
```

Commands for formatting:
```sh
# Non-Swap Partitions
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4

# Swap Partitions
mkswap /dev/sda2
```

Commands for mounting:
```sh
mount /dev/sda3 /mnt
mkdir -p /mnt/boot/efi
mkdir -p /mnt/home
mount /dev/sda1 /mnt/boot/efi
mount /dev/sda4 /mnt/home

swapon /dev/sda2
```
Example final partitioning:
```sh
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda           8:0    1     0B  0 disk
nvme0n1     259:0    0 238.5G  0 disk
├─nvme0n1p1 259:1    0   286M  0 part /boot/efi
├─nvme0n1p2 259:2    0   7.5G  0 part
├─nvme0n1p3 259:3    0  29.8G  0 part /
└─nvme0n1p4 259:4    0 200.9G  0 part /home
```
#### 1.7 Mirrorlist 

Either edit the `mirrorlist` by hand or use `reflector`.
```sh
reflector \
--save /etc/pacman.d/mirrorlist \
--country France,Germany \
--protocol https \
--latest 5
```

#### 1.8 Install essential packages

```sh
pacstrap /mnt \
         base \
         base-devel \
         linux \
         linux-headers \
         linux-lts \
         linux-lts-headers \
         linux-firmware \
         networkmanager \
         grub \
         mkinitcpio \
         efibootmgr \
         sudo \
         vim \
         curl \
         git \
         stow \
         ansible \
         reflector
```

#### 1.9 Generate Fstab
```sh
genfstab -U /mnt >> /mnt/etc/fstab
```

Example configuration of file:
```sh
# <file system> <dir> <type> <options> <dump> <pass>
# /dev/nvme0n1p3
UUID=b06b22f6-0a75-4f76-acf3-82017d3dc4c4	/         	ext4      	rw,relatime	0 1

# /dev/nvme0n1p1
UUID=E60D-2AA8      	/boot/efi 	vfat      	rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro	0 2

# /dev/nvme0n1p4
UUID=d3a0e96c-0671-431c-95a8-7154c6f8ca20	/home     	ext4      	rw,relatime	0 2
```

#### 1.10 Chroot into Install
Change root into the new system.

```sh
arch-chroot /mnt
```

#### 1.11 Time zone
```sh
ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime
hwclock --systohc --utc
```

#### 1.12 Localization
1. Edit /etc/locale.gen 
2. Uncomment `en_US.UTF-8 UTF-8` and other needed locales. 
3. Generate the locales by running:
```sh
locale-gen
```
4. Go to or create `locale.conf` file and set the `LANG` variable accordingly:
```sh
# located at /etc/locale.conf
LANG=en_US.UTF-8
```
5. Make changes to keyboard layout persistent. Go to `/etc/vconsole.conf` and check for:
```sh
KEYMAP=us
FONT=
FONT_MAP=
```
#### 1.13 Network Configuration

1. Go to or create the `hostname` file at `/etc/hostname`. 
```sh
# located at /etc/hostname
archthink
```

2. Add matching entries to `hosts`.
```sh
# located at /etc/hosts


127.0.0.1	localhost
::1	        localhost
127.0.1.1	archthink.localdomain	archthink
```

#### 1.14 Password and Host User
1. Set root password:
```sh
passwd
```

2. Set user and user's password:
```sh
useradd -m <user>
passwd <user>
```

3. Adding host user to groups:
```sh
usermod -aG wheel,audio,video,optical,storage duclos
usermod -aG vboxusers duclos
```

4. Uncomment `%wheel ALL=(ALL)ALL`.
```sh
EDITOR=vim visudo
```
#### 1.15  Enable necessary services
```sh
systemctl enable NetworkManager
systemctl enable systemd-timesyncd
```

#### 1.16 Initramfs
```
# mkinitcpio -p linux
mkinitcpio -P
```

#### 1.17 Grub
```
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg
```

#### 1.18 Reboot
1. Type `exit` or press `Ctrl-D`.
2. Unmount with `umount -R /mnt`
3. Reboot

<a name="configuration"/>

## 2. Configuration

#### 2.1 System Packages
1. Hardware related packages:
```sh
sudo pacman -S \
            intel-media-driver \
            xf86-video-intel \
            intel-ucode \
            mesa-demos \
            mesa \
            usbutils \
            udiskie \
            net-tools \
            wireless_tools \
            brightnessctl \
            pulseaudio \
            pavucontrol \
            pasystray \
            pamixer \
            pulseaudio-bluetooth \
            blueman \
            bluez \
            bluez-utils \
            openssh \
            inetutils \
            dnsutils \
            networkmanager-openvpn \
            network-manager-applet \
            openvpn \
            tlp \
            acpi \
            ncdu
```
2. X11/Xorg related packages:
```sh
sudo pacman -S \
            xorg-server \
            xorg-xinit \
            xorg-xrdb \
            xorg-xrandr \
            xorg-xmodmap \
            xorg-setxkbmap
            xorg-xwininfo \
            xorg-xprop \
            xorg-xev \
            xorg-fonts-100dpi \
            xorg-fonts-75dpi \
            xautolock \
            xclip
```
3. Core Packages
```sh
sudo pacman -S \
            i3lock \
            i3-wm \
            i3status \
            picom \
            dunst \
            unclutter \
            parcellite \
            alacritty \
            vim \
            nano \
            tmux \
            ttf-dejavu \
            imagemagick \
            man-pages \
            nitrogen \
            stow \
            git \
            cmake \
            ctags \
            gdb \
            bat \
            exa \
            ripgrep \
            fd \
            arm-none-eabi-binutils \
            arm-none-eabi-gcc \
            arm-none-eabi-gdb \
            arm-none-eabi-newlib \
            ghdl-gcc \
            clang \
            python \
            python-pip \
            deno \
            doxygen \
            docker \
            nodejs \
            npm \
            rust \
            rustup \
            java-runtime-common \
            java-environment-common \
            ruby \
            ruby-bundler \
            graphviz \
            plantuml \
            valgrind \
            picocom \
            neomutt \
            notmuch \
            offlineimap \
            cron \
            pass
            
```

4. Desktop Packages
```sh
sudo pacman -S \
            libre-office \
            mousepad \
            zathura \
            zathura-pdf-poppler \
            poppler \
            pcmanfm \
            mpv \
            sxiv \
            gcolor3 \
            gimp \
            galculator \
            maim \
            arandr \
            ffmpeg \
            virtualbox \
            arc-gtk-theme \
            gnome-themes-extra \
            kvantum-qt5 \
            qt5ct \
            lxappearance
```

5. Printer Packages:
```sh
sudo pacman -S \
            cups \
            cups-pdf \
            hplip \
            system-config-printer \
            sane \
            xsane \
            python-pyqt5
```

6. Work Packages:
```sh
sudo pacman -S \
            tcpdump \
            xilinx-vivado-dummy \
            jitsi-meet-desktop-bin \
            jenkins \
            clang-format-static-bin \
            cppcheck
```
#### 2.2 AUR Packages
To be able to install packages from the AUR, one has to install a AUR-helper like `paru`.

1. Install paru.
```sh
cd /opt
sudo git clone https://aur.archlinux.org/paru.git
sudo chown -R duclos:duclos ./paru
cd paru
makepkg -si
```

2. Install the necessary AUR packages.
```sh
paru -S \
    zoom \
    brave-bin \
    spotify \
    pandoc-bin \
    shellcheck-bin \
    jitsi-meet-desktop-bin \
    teams \
    lcov \
    can-utils
```

#### 2.3 Python Packages

```sh
pip install compiledb pillow
pip install 'python-language-server[all]'
```

#### 2.4 Enable Newly Installed Services
```sh
sudo systemctl enable tlp
sudo systemctl enable docker
sudo systemctl enable bluetooth
sudo systemctl enable jenkins
# available at http://localhost:8090
```

#### 2.5 System File structure

```sh
cd ~
mkdir -p Desktop
mkdir -p Documents
mkdir -p Downloads
mkdir -p Music
mkdir -p Pictures
mkdir -p Programs
mkdir -p Videos

mkdir -p .config
mkdir -p .bin

cd ~/Documents
git clone https://github.com/duclos-cavalcanti/dotfiles.git
./scripts/.scripts/setup_env.sh

mkdir -p uni
mkdir -p work

mkdir -p projects
projects/
├── ai
│   ├── Coral-USB-Accelerator
│   └── Coral-USB-Accelerator.wiki
├── dsa
│   ├── starters_edx
│   ├── tree_height
│   └── UCSD-data-structures
├── embedded
│   ├── FreeRTOS-Emulator
│   ├── FreeRTOS-SpaceInvaders
│   ├── TI-SensorTag-IoT-Contiki
│   ├── TM4C123GXL-Cmake
│   └── XMC4500-Cmake
├── high-performance
│   ├── BarnsleyFern-Multithreaded
│   └── DynamicProgrammingOpenMPI
├── hw
│   ├── mips
│   ├── vhdl-entwurf
│   └── vhdl-praktikum
├── personal
│   └── duclos-cavalcanti.github.io
├── templates
│   ├── C-code-snippets
│   ├── CMake-Cpp-Template
│   ├── CMake-C-Template
│   ├── Docker-Template
│   ├── ex
│   ├── GoogleTestTemplate-Bazel
│   ├── GoogleTestTemplate-CMake
│   ├── Jenkins-CMake-Template
│   ├── Jenkins-Pipeline-Template
│   ├── TravisCI-Template
│   └── Vivado-Template
└── tutorials
    ├── Tcl-Tutorial
    └── TutorialPlantUML

```
#### 2.6 GPG / Pass
1. Generate GPG Key
```sh
gpg --full-gen-key
```

2. Initialize Pass
```sh
pass init <gpg email>
pass add <keyword for a service>
pass <keyword> # spits password
```
#### 2.7 Printer/Scanner Configuration
**Printer**

0. Check if these packages are installed.
```sh
hplip 
cups
cups-pdf
system-config-printer
```
1. `sudo systemctl enable cups`
2. `sudo systemctl start cups`
3. Check if printer is showing in `lsusb`
4. Go to web interface: [here](http://localhost:631/)
5. Click on **Administration** tab above (next to Home)
6. Add Printer
7. Choose Printer on Local Printers and follow the steps

**Scanner**

- Works out of the box. 

- The following steps are to use ipp-usb that should improve scanning
quality, but had issues with it the last time.

0. Check if these packages are installed
```sh
hplip 
sane 
xsane   # fronted for sane
ipp-usb # caused issues, uninstalled it
pillow  # Python packages, also wasn't needed
```
1. `sudo systemctl enable ipp-usb`
2. `sudo systemctl start ipp-usb`

#### 2.6 Snap
1. Install Snap
```sh
git clone https://aur.archlinux.org/snapd.git
cd snapd
makepkg -si
```

2. Enable it
```sh
sudo systemctl enable --now snapd.socket
```
3. Enable classic snap support
```sh
sudo ln -s /var/lib/snapd/snap /snap
```

4. Install snap packages
```sh
sudo snap install travis
```

#### 2.7 Vim
1. Install Plugins
```sh
vim .
:PlugInstall<CR>
```

2. Install Plugin Dependencies
    1. LSP/Language Server Client:
    - [lsp.vim](https://github.com/prabirshrestha/vim-lsp)
    - [asyncomplete.vim](https://github.com/prabirshrestha/asyncomplete.vim)
    - [asyncomplete-lsp.vim](https://github.com/prabirshrestha/asyncomplete-lsp.vim)
    
    For other language installations go to [this link](https://github.com/prabirshrestha/vim-lsp/wiki/Servers).
    
    ```sh
    #################################
    # SHOULDVE BEEN INSTALLED ALREADY
    #################################
    
    # depends on clangd for C/C++
    sudo pacman -S clang
    
    # depends on pyls for Python
    pip install python-language-server
    
    # depends on ghdl for VHDL
    sudo pacman -S ghdl-gcc
    pip install pyGHDL
    
    # many languages may depend on npm
    sudo pacman -S nodejs npm
    ```
    2. Tagbar
    ```sh
    #################################
    # SHOULDVE BEEN INSTALLED ALREADY
    #################################
    
    sudo pacman -S ctags
    ```
    
    3. Ultisnips
    ```sh
    TODO
    ```
    
    4. Vimspector
    ```sh
    TODO
    ```

#### 2.8 Jenkins
1. If needed, add Jenkins as a sudo user
```sh
sudo visudo
jenkins ALL=(ALL) NOPASSWD: ALL # add this line
```

2. Install following packages for Xilinx CI/CD
```sh
sudo pacman -S xorg-server-xvfb
sudo pacman -S xorg-xlsclients
```

3. Plugins
- Delivery Pipeline

<a name="maintenance"/>

### 3. Maintenance
#### 3.1 SysAd / Cron Jobs

Create cron jobs to periodically perform actions within the system. 

Examples:

```sh
*/25 * * * * /home/duclos/Documents/dotfiles/cron/scripts/cleanup.sh
# performs every 25 minutes
*/10 * * * * offlineimap -u quiet -c ~/.config/offlineimap/offlineimaprc ; notmuch new
# performs every 10 minutes
5 * */5 * * /usr/bin/pacman -Syuw --noconfirm
# performs every 5 hours at the 5th minute
```
#### 3.2 Package Management
List Orphan Packages
```
pacman -Qqdt
```
List AUR Packages
```
pacman -Qqm
```
