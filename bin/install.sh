#!/bin/bash

set -e

if ! [ -x "$(command -v ansible)" ]; then
  echo "You don't have ansible, install it!"
  exit 1
fi

DOTFILES=$HOME/.dotfiles

pushd $DOTFILES

ansible-galaxy collection install kewlfft.aur
ansible-playbook -i hosts --connection=local main.yml --ask-become-pass

popd
