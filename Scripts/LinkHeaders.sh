#!/bin/bash
#
# 参数：无
# 执行目录：仓库根目录
# 示例：sh Scripts/LinkHeaders.sh

# 创建目录，包括子目录。
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

# 为模块的 .h 文件，创建软链接。
# 参数一：头文件所在的目录
# 参数二：当前目录下的头文件类型，公开 Public 或私有 Private
CreateHeadersForType() {
    local MODULE_PATH="$1";
    local HEADER_TYPE="$2";
    # 如果存放软链接的目录不存在，则先创建该目录
    local HEADER_ROOT="Sources/ObjC/Headers/$HEADER_TYPE/XZKit"
    if [[ ! -d "$HEADER_ROOT" ]]; then
        CreatePath "$HEADER_ROOT"
        # 创建软链接前，再次判断存放目录是否存在
        if [[ ! -d "$HEADER_ROOT" ]]; then
            echo "🚫 \033[33m目录 $HEADER_ROOT 不存在，且无法创建\033[0m"
        fi
    fi
    # 遍历目录下的直接子目录或文件
    for path in "$MODULE_PATH"/*; do
        # 获得当前所遍历的子目录或文件的名字
        local name=$(basename "$path")
        # 判断当前遍历的是否为文件
        if [[ -f $path ]]; then
            # 判断当前遍历的文件是否为 .h 文件
            if [[ "$name" =~ ".h"$ ]]; then
                # 源文件的相对路径。
                local SOURCE_PATH="../../../Code/${path#*Sources/ObjC/Code/}"
                # 软链接的存放路径
                local HEADER_PATH="$HEADER_ROOT/$name"
                # 创建软链接
                ln -snf "$SOURCE_PATH" "$HEADER_PATH"
                echo "\033[32m[+] [$HEADER_TYPE] $SOURCE_PATH => $HEADER_PATH \033[0m"
            fi
        elif [[ -d $path ]]; then
            if [[ "$name" == "Private" ]]; then
                CreateHeadersForType "$path" "Private"
            else
                CreateHeadersForType "$path" "$HEADER_TYPE"
            fi
        fi
    done
    return 0
}

MODULE_NAME="XZKit"

# 检查脚本参数
if [[ -z "$MODULE_NAME" ]]; then
    echo "🚫 \033[33m请在第一个参数指定子模块名！\033[0m"
    exit 1;
fi

echo "☕️ \033[34m清理操作开始\033[0m"
if [[ -d "Sources/ObjC/Headers/Public/${MODULE_NAME}" ]]; then
    for path in "Sources/ObjC/Headers/Public/${MODULE_NAME}"/*; do
        rm -rf "$path"
        echo "\033[31m[-]  $path \033[0m"
    done
fi
if [[ -d "Sources/ObjC/Headers/Private/${MODULE_NAME}" ]]; then
    for path in "Sources/ObjC/Headers/Private/${MODULE_NAME}"/*; do
        rm -rf "$path"
        echo "\033[31m[-]  $path \033[0m"
    done
fi
echo "🎉 \033[34m清理操作结束\033[0m"

# 进入目录
CreatePath "Sources/ObjC/Headers/Public"
CreatePath "Sources/ObjC/Headers/Private"

echo "\033[34m☕️ 开始链接头文件\033[0m"
CreateHeadersForType "Sources/ObjC/Code" "Public"
echo "\033[34m🎉 链接头文件完成\033[0m"


# 为指定模块创建头文件软链接。（暂未使用）
CreateHeadersForModule() {
    local MODULE_NAME="$1";
    local MODULE_PATH="$2";
    local HEADER_TYPE="$3";
    for path in "$MODULE_PATH"/*; do
        # echo "path => $path"
        local name=$(basename "$path")
        if [[ -f $path ]]; then
            if [[ "$name" =~ ".h"$ ]]; then
                if [[ ! -d "Sources/ObjC/Headers/$HEADER_TYPE/$MODULE_NAME" ]]; then
                    CreatePath "Sources/ObjC/Headers/$HEADER_TYPE/$MODULE_NAME"
                fi
                if [[ -d "Sources/ObjC/Headers/$HEADER_TYPE/$MODULE_NAME" ]]; then
                    ln -s "../../../Code/${path#*Sources/ObjC/Code/}" "Sources/ObjC/Headers/$HEADER_TYPE/$MODULE_NAME/$name"
                    echo "\033[32m[+] [$HEADER_TYPE] $path \033[0m"
                else
                    echo "🚫 \033[33m目录 $HEADER_TYPE/$MODULE_NAME 不存在，且无法创建\033[0m"
                fi
            fi
        elif [[ -d $path ]]; then
            if [[ "$name" == "Private" ]]; then
                CreateHeadersForModule "$MODULE_NAME" "$path" "Private"
            else
                CreateHeadersForModule "$MODULE_NAME" "$path" "$HEADER_TYPE"
            fi
        fi
    done
    return 0
}


