#!/bin/zsh
#
# 编译宏模块，生成 CocoaPods 可引用的二进制文件。
# 执行目录，在本仓库根目录执行，即当前目录的上层目录
# sh Scripts/LinkMacros.sh Debug,Test Beta,Release

if [[ ! -d "Products" ]]; then
    mkdir "Products";
fi

cd "Projects/XZKitMacros"

swift build -c debug
mv ".build/debug/XZKitMacros-tool" "../../Products/XZKitMacros-Debug"
swift build -c release
mv ".build/release/XZKitMacros-tool" "../../Products/XZKitMacros-Release"

cd "../../Products"

# echo "DEBUG_CONFIGS => ${1}";

OFS=${IFS};
IFS=',';
DEBUG_CONFIGS=(${1});
for CONFIG in ${DEBUG_CONFIGS[@]}; do
    if [[ "${CONFIG}" == "Debug" ]]; then
        continue;
    fi
    if [[ ! -f "XZKitMacros-${CONFIG}" ]]; then
        ln -s -n "XZKitMacros-Debug" "XZKitMacros-${CONFIG}"
    fi
done

# echo "RELEASE_CONFIGS => ${2}"

RELEASE_CONFIGS=(${2})
for CONFIG in ${RELEASE_CONFIGS[@]}; do
    if [[ "${CONFIG}" == "Release" ]]; then
        continue;
    fi
    if [[ ! -f "XZKitMacros-${CONFIG}" ]]; then
        ln -s -n "XZKitMacros-Release" "XZKitMacros-${CONFIG}"
    fi
done
IFS=${OFS};
