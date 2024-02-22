#!/bin/bash

# 传入参数检查
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory A> <repository B>"
    exit 1
fi

# 读取参数
DIR_A=$1
REPO_B=$2

# 检查目录A是否存在
if [ ! -d "$DIR_A" ]; then
    echo "Error: Directory $DIR_A does not exist."
    exit 1
fi

# 进入目录A
cd "$DIR_A"

# 删除目录中现有的.git目录，如果存在的话
rm -rf .git

# 重新初始化Git仓库
git init

# 添加所有文件
git add .

# 创建一个新的初始commit
git commit -m "Init"

# 添加远程仓库B
git remote add origin "$REPO_B"

# 强制推送到远程仓库B的master分支
# 这将覆盖远程仓库B的历史，请谨慎操作
git push -u --force origin master

echo "Pushed code from $DIR_A to $REPO_B with new history successfully."
