#!/bin/bash

# 传入参数检查
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <directory A> <repository B>"
    exit 1
fi
echo "You must checkout to master branch before running this script."
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

# 检查是否有Git仓库
if [ ! -d ".git" ]; then
    echo "Error: No git repository found in $DIR_A"
    exit 1
fi

# 获取当前的主分支名称
MAIN_BRANCH=$(git rev-parse --abbrev-ref HEAD)

# 删除除当前主分支外的所有本地分支
for branch in $(git branch | grep -v "*"); do
    git branch -D "$branch"
done

# 删除远程跟踪的分支的本地引用
# 注意：这不会删除远程仓库的分支
git fetch --prune

# 重新设置远程仓库
git remote remove origin
git remote add origin "$REPO_B"

# 推送当前分支到远程仓库B的同名分支，并设置为跟踪分支
# 如果远程分支不存在，它将被创建
git push -u origin "$MAIN_BRANCH"

# 删除远程仓库中除了主分支之外的所有分支
# 注意：这是一个危险的操作，请确保你知道自己在做什么
REMOTE_BRANCHES=$(git branch -r | grep -v "$MAIN_BRANCH" | sed 's/origin\///')
for branch in $REMOTE_BRANCHES; do
    git push origin --delete "$branch"
done

echo "Pushed code from $DIR_A to $REPO_B with preserved history on the main branch successfully."
