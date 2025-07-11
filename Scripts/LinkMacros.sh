#!/bin/bash
# 
# 编译宏模块，生成 CocoaPods 可引用的二进制文件。
# 执行目录，在本仓库根目录执行，即当前目录的上层目录
# sh Scripts/LinkMacros.sh

cd "Projects/XZKitMacros"

swift build -c debug
swift build -c release

cp ".build/debug/XZKitMacros-tool"   "../../Products/XZKitMacros-debug"
cp ".build/release/XZKitMacros-tool" "../../Products/XZKitMacros-release"
