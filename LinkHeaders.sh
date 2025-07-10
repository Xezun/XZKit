#!/bin/bash
# 参数1：模块名

CreatePath() {
    if [[ -d "$1" ]]; then
        echo "\033[34m🎉 目录 $1 检查通过\033[0m"
    else
        mkdir -p "$1"
        if [[ -d "$1" ]]; then
            echo "\033[34m🎉 目录 $1 创建成功\033[0m"
        else
            echo "\033[33m🚫 目录 $1 创建失败，无法链接头文件\033[0m"
            exit 10;
        fi
    fi
}

LinkModuleHeaders() {
    local moduleName="$1";
    local modulePath="$2";
    local headerType="$3";
    for path in "$modulePath"/*; do
        # echo "path => $path"
        local name=$(basename "$path")
        if [[ -f $path ]]; then
            if [[ "$name" =~ ".h"$ ]]; then
                if [[ ! -d "XZKit/Headers/$headerType/$moduleName" ]]; then
                    CreatePath "XZKit/Headers/$headerType/$moduleName"
                fi
                if [[ -d "XZKit/Headers/$headerType/$moduleName" ]]; then
                    ln -s "../../../../$path" "XZKit/Headers/$headerType/$moduleName/$name"
                    echo "\033[32m[+] [$headerType] $path \033[0m"
                else
                    echo "🚫 \033[33m目录 $headerType/$moduleName 不存在，且无法创建\033[0m"
                fi
            fi
        elif [[ -d $path ]]; then
            if [[ "$name" == "Private" ]]; then
                LinkModuleHeaders "$moduleName" "$path" "Private"
            else
                LinkModuleHeaders "$moduleName" "$path" "$headerType"
            fi
        fi
    done
    return 0
}

LinkXZKitHeaders() {
    local modulePath="$1";
    local headerType="$2";
    for path in "$modulePath"/*; do
        # echo "path => $path"
        local name=$(basename "$path")
        if [[ -f $path ]]; then
            if [[ "$name" =~ ".h"$ ]]; then
                if [[ ! -d "XZKit/Headers/$headerType/XZKit" ]]; then
                    CreatePath "XZKit/Headers/$headerType/XZKit"
                fi
                if [[ -d "XZKit/Headers/$headerType/XZKit" ]]; then
                    ln -s "../../../../$path" "XZKit/Headers/$headerType/XZKit/$name"
                    echo "\033[32m[+] [$headerType] $path \033[0m"
                else
                    echo "🚫 \033[33m目录 $headerType/XZKit 不存在，且无法创建\033[0m"
                fi
            fi
        elif [[ -d $path ]]; then
            if [[ "$name" == "Private" ]]; then
                LinkXZKitHeaders "$path" "Private"
            else
                LinkXZKitHeaders "$path" "$headerType"
            fi
        fi
    done
    return 0
}

MODULE_NAME="$1"

# 检查脚本参数
if [[ -z "$MODULE_NAME" ]]; then
    echo "🚫 \033[33m请在第一个参数指定子模块名！\033[0m"
    exit 1;
fi

echo "☕️ \033[34m清理操作开始\033[0m"
if [[ -d "XZKit/Headers/Public/${MODULE_NAME}" ]]; then
    for path in "XZKit/Headers/Public/${MODULE_NAME}"/*; do
        rm -rf "$path"
        echo "\033[31m[-]  $path \033[0m"
    done
fi
if [[ -d "XZKit/Headers/Private/${MODULE_NAME}" ]]; then
    for path in "XZKit/Headers/Private/${MODULE_NAME}"/*; do
        rm -rf "$path"
        echo "\033[31m[-]  $path \033[0m"
    done
fi
echo "🎉 \033[34m清理操作结束\033[0m"

# 进入目录
CreatePath "XZKit/Headers/Public"
CreatePath "XZKit/Headers/Private"

echo "\033[34m☕️ 开始链接头文件\033[0m"
if [[ "$MODULE_NAME" == "XZKit" ]]; then
    LinkXZKitHeaders "XZKit/Code/ObjC" "Public"
else
    # 检查 MODULE_PATH
    if [[ ! -d "XZKit/Code/ObjC/${MODULE_NAME}" ]]; then
        echo "🚫 \033[33m模块 ${MODULE_NAME} 不存在！\033[0m"
        exit 2;
    fi
    LinkModuleHeaders "$MODULE_NAME" "XZKit/Code/ObjC/${MODULE_NAME}" "Public"
fi
echo "\033[34m🎉 链接头文件完成\033[0m"




