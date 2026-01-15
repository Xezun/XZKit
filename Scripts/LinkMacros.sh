#!/bin/zsh
#
# 编译宏模块，生成 CocoaPods 可引用的二进制文件。
# 执行目录，在本仓库根目录执行，即当前目录的上层目录
# sh Scripts/LinkMacros.sh Debug,Test Beta,Release

if [[ ! -d "Products" ]]; then
    mkdir "Products";
fi

cd "Projects/XZKitMacros";

swift build -c debug;
mv ".build/debug/XZKitMacros-tool" "../../Products/XZKitMacros-Debug";
swift build -c release;
mv ".build/release/XZKitMacros-tool" "../../Products/XZKitMacros-Release";

cd "../../Products";

# echo "DEBUG_CONFIGURATIONS => ${1}";

OFS=${IFS};
IFS=',';

DEBUG_CONFIGURATIONS=(${1});
for CONFIGURATION in ${DEBUG_CONFIGURATIONS[@]}; do
    if [[ "${CONFIGURATION}" == "Debug" ]]; then
        continue;
    fi
    if [[ ! -f "XZKitMacros-${CONFIGURATION}" ]]; then
        ln -s -n "XZKitMacros-Debug" "XZKitMacros-${CONFIGURATION}";
    fi
done

# echo "RELEASE_CONFIGURATIONS => ${2}"

RELEASE_CONFIGURATIONS=(${2});
for CONFIGURATION in ${RELEASE_CONFIGURATIONS[@]}; do
    if [[ "${CONFIGURATION}" == "Release" ]]; then
        continue;
    fi
    if [[ ! -f "XZKitMacros-${CONFIGURATION}" ]]; then
        ln -s -n "XZKitMacros-Release" "XZKitMacros-${CONFIGURATION}";
    fi
done

IFS=${OFS};
