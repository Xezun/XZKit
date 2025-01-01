//
//  XZDebugMode.h
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZDefines.h>

NS_ASSUME_NONNULL_BEGIN

/// 当前是否为 DEBUG 模式，即启动参数添加了 -XZKitDEBUG 标记。
FOUNDATION_EXPORT BOOL XZ_READONLY XZKitDebugMode NS_SWIFT_NAME(isDebugMode);

/// 初始化函数
FOUNDATION_EXPORT void __XZKIT_MODE_INIT__(void) XZ_INIT NS_UNAVAILABLE;

NS_ASSUME_NONNULL_END
