#!/bin/bash

# 需要一个参数：模块名
module="$1"

root_path="XZKit/Headers/$module"

if [[ -d "$root_path" ]]; then
    echo "\033[32m🟢 目录 $root_path 检查通过\033[0m"
else
    mkdir -p "$root_path"
    if [[ -d "$root_path" ]]; then
    	echo "\033[32m🟢 目录 $root_path 创建成功\033[0m"
    else
    	echo "\033[31m🔴 目录 $root_path 创建失败，无法链接头文件\033[0m"
    	exit 0;
    fi
fi

LinkHeaders() {
    for path in "$1"/*; do
        name=$(basename "$path")
        if [[ -f $path ]]; then
            if [[ "$name" =~ ".h"$ ]]; then
                if [[ ! -d "$2" ]]; then
                    mkdir "$2"
                fi
                if [[ -d "$2" ]]; then
                    ln -s "../$1/$name" "$2/$name"
                    echo "🟢 [$2] ../$1/$name"
                else
                    echo "🔴 目录 $2 不存在，且无法创建"
                fi
            fi
        elif [[ -d $path ]]; then
            if [[ "$name" == "Private" ]]; then
                LinkHeaders "$1/$name" "Private"
            else
                LinkHeaders "$1/$name" "$2"
            fi
        fi
    done
    return 0
}

# 进入目录
cd "$(pwd)/$root_path"

echo "☕️ \033[32m开始清理旧的头文件\033[0m"
if [[ -d "Public" ]]; then
    for path in "./Public"/*; do
        rm -rf "$path"
        echo "🟡 $path "
    done
fi
if [[ -d "Private" ]]; then
    for path in "./Private"/*; do
        rm -rf "$path"
        echo "🟡 $path "
    done
fi
echo "☕️ \033[32m清理结束\033[0m"

echo "\033[32m☕️ 开始链接头文件\033[0m"
LinkHeaders "../../Code/$module" "Public"
echo "\033[32m☕️ 链接头文件完成\033[0m"
