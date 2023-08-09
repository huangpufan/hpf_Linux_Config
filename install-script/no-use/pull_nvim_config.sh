#!/bin/bash
root_dir="/home/$(whoami)"
rm -rf $root_dir/.config/nvim
rm -rf $root_dir/.local/share/nvim

# 压缩文件路径
archive_file_1="./full_neovim/config_nvim.gz"
archive_file_2="./full_neovim/local_share_nvim.gz"

# 目标解压目录
target_folder_1=$root_dir/.config
target_folder_2=$root_dir/.local/share
# 解压缩文件
tar -xzf $archive_file_1
mv ./nvim $target_folder_1
tar -xzf $archive_file_2
mv ./nvim $target_folder_2

echo "已将 github neovim 全量配置更新到本机目录"
