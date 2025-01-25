#!/bin/bash
# 参数1：模块名

CreatePath() {
    if [[ -d "$1" ]]; then
        echo "\033[32m🎉 目录 $1 检查通过\033[0m"
    else
        mkdir -p "$1"
        if [[ -d "$1" ]]; then
            echo "\033[32m🎉 目录 $1 创建成功\033[0m"
        else
            echo "\033[31m⚠️ 目录 $1 创建失败，无法链接头文件\033[0m"
            exit 10;
        fi
    fi
}

LinkHeaders() {
    local moduleName="$1";
    local modulePath="$2";
    local headerType="$3";
    for path in "$modulePath"/*; do
        # echo "path => $path"
        name=$(basename "$path")
        if [[ -f $path ]]; then
            if [[ "$name" =~ ".h"$ ]]; then
                if [[ ! -d "XZKit/Headers/$headerType/$moduleName" ]]; then
                    CreatePath "XZKit/Headers/$headerType/$moduleName"
                fi
                if [[ -d "XZKit/Headers/$headerType/$moduleName" ]]; then
                    ln -s "../../../../$path" "XZKit/Headers/$headerType/$moduleName/$name"
                    echo "🔗 [$headerType] $path"
                else
                    echo "⚠️ \033[31m目录 $headerType/$moduleName 不存在，且无法创建\033[0m"
                fi
            fi
        elif [[ -d $path ]]; then
            if [[ "$name" == "Private" ]]; then
                LinkHeaders "$moduleName" "$path" "Private"
            else
                LinkHeaders "$moduleName" "$path" "$headerType"
            fi
        fi
    done
    return 0
}

MODULE_NAME="$1"

# 检查脚本参数
if [[ -z "$MODULE_NAME" || "$MODULE_NAME" == "XZKit" ]]; then
    echo "🚫 \033[31m请在第一个参数指定子模块名！\033[0m"
    exit 1;
fi

# 检查 MODULE_PATH
if [[ ! -d "XZKit/Code/ObjC/${MODULE_NAME}" ]]; then
    echo "🚫 \033[31m模块 ${MODULE_NAME} 不存在！\033[0m"
    exit 2;
fi

# 进入目录
CreatePath "XZKit/Headers/Public"
CreatePath "XZKit/Headers/Private"

echo "☕️ \033[32m清理操作开始\033[0m"
if [[ -d "XZKit/Headers/Public/${MODULE_NAME}" ]]; then
    for path in "XZKit/Headers/Public/${MODULE_NAME}"/*; do
        rm -rf "$path"
        echo "⛓️‍💥 $path "
    done
fi
if [[ -d "XZKit/Headers/Private/${MODULE_NAME}" ]]; then
    for path in "XZKit/Headers/Private/${MODULE_NAME}"/*; do
        rm -rf "$path"
        echo "⛓️‍💥 $path "
    done
fi
echo "🎉 \033[32m清理操作结束\033[0m"

echo "\033[32m☕️ 开始链接头文件\033[0m"
LinkHeaders "$MODULE_NAME" "XZKit/Code/ObjC/${MODULE_NAME}" "Public"
echo "\033[32m🎉 链接头文件完成\033[0m"
