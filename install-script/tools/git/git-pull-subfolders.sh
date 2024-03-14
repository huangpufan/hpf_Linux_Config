#!/bin/bash

# 保存当前工作目录
CWD=$(pwd)

# 函数定义：git_pull_recursive
# 参数：$1 - 目录路径
# 参数：$2 - 当前深度
# 参数：$3 - 目标深度
git_pull_recursive() {
    local current_dir=$1
    local current_depth=$2
    local target_depth=$3

    # 如果当前深度等于目标深度，检查并更新git仓库
    if [ "$current_depth" -eq "$target_depth" ]; then
        if [ -d "$current_dir/.git" ]; then
            echo "Entering $current_dir"
            cd "$current_dir" || return
            git pull
            cd "$CWD" || return
        fi
    else
        # 否则，递归到每一个子目录
        for subdir in "$current_dir"*/; do
            if [ -d "$subdir" ]; then
                git_pull_recursive "$subdir" $((current_depth + 1)) "$target_depth"
            fi
        done
    fi
}

# 检查是否有参数，如果没有，则默认为1
if [ $# -eq 0 ]; then
    DEPTH=1
else
    DEPTH=$1
fi

# 检查DEPTH是否为数字
if ! [[ "$DEPTH" =~ ^[0-9]+$ ]]; then
    echo "Error: The depth level must be a number"
    exit 1
fi

# 执行git_pull_recursive函数
git_pull_recursive "$CWD" 0 "$DEPTH"

echo "Git pull done for all subdirectories at level $DEPTH in the current working directory."
