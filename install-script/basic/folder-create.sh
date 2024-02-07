#!/bin/bash

directories=("project" "install" "download" "bin" ".config" ".config/nvim")

for dir in "${directories[@]}"
do
  if [ ! -d "$HOME/$dir" ]; then
    mkdir -p "$HOME/$dir"
    echo "Created directory: $HOME/$dir"
  else
    echo "Directory already exists: $HOME/$dir"
  fi
done
