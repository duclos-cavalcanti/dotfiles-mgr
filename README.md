# dotfiles

<p>
  <img alt="Linux" src="https://img.shields.io/badge/-Linux-FCC624?style=flat-square&logo=Linux&logoColor=black" />
  <img alt="Arch Linux" src="https://img.shields.io/badge/-Arch Linux-1793D1?style=flat-square&logo=Arch Linux&logoColor=black" />
  <img alt="Stow" src="https://img.shields.io/badge/-Stow-A42E2B?style=flat-square&logo=GNU&logoColor=white?" />
  <img alt="Ansible" src="https://img.shields.io/badge/-Ansible-EE0000?style=flat-square&logo=Ansible&logoColor=white" />
</p>

- Dotfiles manager *repo* that uses [stow](https://www.gnu.org/software/stow/) and [ansible](https://www.ansible.com/) to automate
and enable a quick installation of my system configurations on an `Arch` or `Debian` based
system.

## Installation
The following script checks if `Ansible` is installed on the current system, in case it is
it installed some extra modules and runs the `main.yml` playbook.

1. Run: 
```sh
./bin/install.sh
```
2. Enjoy :)

## Software
|  Role             |    		            |
| -------------	    |-------------          |
|    wm		        |    i3                 |
|    bar		    |    i3bar / i3status   |
|    notifications	|    dunst              |
|    pdf		    |    zathura            |
|    shell		    |    bash               |
|    editor		    |    vim                |
|    terminal		|    alacritty          |
|    compositor		|    picom              |
|    menu		    |    rofi               |
|    mail		    |    mutt               |

