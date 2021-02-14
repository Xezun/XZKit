//
//  XZKitDEBUG.h
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

/// 当前是否为 DEBUG 模式，程序启动参数添加了 -XZKitDEBUG 参数。
FOUNDATION_EXTERN bool XZKIT_PROTECTED XZKitDebugMode NS_SWIFT_NAME(isDebugMode);

@interface NSObject (XZKitDEBUG)
@end

NS_ASSUME_NONNULL_END
