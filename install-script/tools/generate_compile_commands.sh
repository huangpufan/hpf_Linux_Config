#!/bin/bash

# 初始化compile_commands.json文件内容
echo "[" > compile_commands.json
FIRST=1

# 处理目录中的每个.c和.cpp文件
for SOURCE_FILE in *.c *.cpp; do
    # 跳过不存在的文件（如果没有匹配到任何.c或.cpp文件）
    [ -f "$SOURCE_FILE" ] || continue

    # 获取当前工作目录
    DIR=$(pwd)

    # 获取文件名（不含扩展名）
    FILENAME=$(basename -- "$SOURCE_FILE" .c)
    FILENAME=$(basename -- "$FILENAME" .cpp)

    # 根据文件扩展名确定是否是C或C++源文件
    EXTENSION="${SOURCE_FILE##*.}"

    # 选择编译器
    if [ "$EXTENSION" = "c" ]; then
        COMPILER="gcc"
    elif [ "$EXTENSION" = "cpp" ]; then
        COMPILER="g++"
    else
        echo "Unsupported file extension: $EXTENSION"
        continue
    fi

    # 如果不是第一个条目，添加逗号
    if [ "$FIRST" -ne 1 ]; then
        echo "," >> compile_commands.json
    else
        FIRST=0
    fi

    # 创建compile_commands.json条目
    cat << EOF >> compile_commands.json
  {
    "directory": "$DIR",
    "command": "$COMPILER -o $FILENAME $SOURCE_FILE",
    "file": "$SOURCE_FILE"
  }
EOF
done

# 结束JSON数组
echo "]" >> compile_commands.json

echo "compile_commands.json has been generated."
