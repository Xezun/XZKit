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

/// 当前是否为 DEBUG 模式，即启动参数添加了 -XZKitDEBUG 标记。
FOUNDATION_EXTERN BOOL XZ_CONST XZKitDebugMode XZ_OBJC_ONLY;

@interface NSObject (XZKitDEBUG)
@end

NS_ASSUME_NONNULL_END
