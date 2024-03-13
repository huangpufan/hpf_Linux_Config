#!/bin/bash

# 保存当前工作目录
CWD=$(pwd)

# 遍历当前工作目录下的所有子目录
for d in "$CWD"/*; do
    # 检查目录中是否存在.git目录
    if [ -d "$d/.git" ]; then
        echo "Entering $d"
        # 进入Git仓库目录
        cd "$d" || continue
        # 执行git pull
        git pull
        # 返回到原始工作目录
        cd "$CWD" || exit
    fi
done

echo "Git pull done for all repositories in $(pwd)"
