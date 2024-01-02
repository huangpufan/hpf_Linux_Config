#!/bin/bash

# 递归函数，用于打印一个目录下所有文件的行数
# $1: 当前目录路径
# $2: 缩进字符串
function print_tree() {
    local directory=$1
    local indent=$2
    local is_first=1

    # 遍历当前目录下的所有文件和文件夹
    for file in "$directory"/*; do
        # 如果是目录，则递归调用此函数
        if [ -d "$file" ]; then
            if [ "$is_first" -eq 1 ]; then
                is_first=0
                echo "${indent}$(basename "$file")/"
            else
                echo "${indent}│"
                echo "${indent}├── $(basename "$file")/"
            fi
            # 递归调用，增加缩进
            print_tree "$file" "$indent│   "
        elif [ -f "$file" ]; then
            # 检查是否是文本文件
            if file "$file" | grep -q text; then
                # 计算文件的行数
                local lines=$(wc -l < "$file")
                echo "${indent}│"
                echo "${indent}├── $(basename "$file") - $lines lines"
            else
                echo "${indent}│"
                echo "${indent}├── $(basename "$file") - Binary file"
            fi
        fi
    done
    # 调整末尾的树枝显示
    if [ "$is_first" -ne 1 ]; then
        echo "${indent}│"
    fi
}

# 开始脚本，从当前目录开始，不带缩进
print_tree "." ""
