#!/bin/bash

# 保存当前工作目录
CWD=$(pwd)

# 遍历当前工作目录下的所有第一级子目录
for subdir in "$CWD"/*/; do
    # 确保它是一个目录
    if [ -d "$subdir" ]; then
        # 遍历第一级子目录下的所有第二级子目录
        for d in "$subdir"*/; do
            # 检查第二级子目录中是否存在.git目录
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
    fi
done

echo "Git pull done for all second-level subdirectories in the current working directory."
