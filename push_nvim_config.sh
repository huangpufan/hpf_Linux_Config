#!/bin/bash

rm -rf ./neovim/* 

root_dir="/home/$(whoami)"

# 源文件夹路径
source_folder_1=$root_dir"/.config/nvim"
source_folder_2=$root_dir"/.local/share/nvim"
# 目标压缩文件路径
target_file_1="./full_neovim/config_nvim.gz"
target_file_2="./full_neovim/local_share_nvim.gz"

# 压缩文件夹
tar -czf "$target_file_1" -C "$(dirname "$source_folder_1")" "$(basename "$source_folder_1")";
tar -czf "$target_file_2" -C "$(dirname "$source_folder_2")" "$(basename "$source_folder_2")";

echo "本机 nvim 配置已经成功更新至 neovim 文件夹";
