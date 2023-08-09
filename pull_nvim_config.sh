#!/bin/bash

rm -rf ~/.config/nvim
rm -rf ~/.local/share/nvim

# 压缩文件路径
archive_file_1="./neovim/config_nvim.gz"
archive_file_2="./neovim/local_share_nvim.gz"

# 目标解压目录
target_folder_1="~/.config/nvim"
target_folder_2="~/.local/share/nvim"
# 解压缩文件
tar -xzf "$archive_file_1" -C "$target_folder_1"
tar -xzf "$archive_file_2" -C "$target_folder_2"
