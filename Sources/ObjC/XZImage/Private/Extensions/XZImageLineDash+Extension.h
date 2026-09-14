//
//  XZImageLineDash+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#if __has_include("XZKit.h")
#import "XZImageLineDash.h"
#import "XZImageAttribute+Extension.h"
#import "XZImageLine+Extension.h"
#else
#import <XZKit/XZImageLineDash.h>
#import <XZKit/XZImageAttribute+Extension.h>
#import <XZKit/XZImageLine+Extension.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZImageLineDash ()

/// 从另一个 lineDash 复制属性。如果 lineDash 为自身则不复制。
/// @note 该方法不触发事件。
- (void)updateLineDashValue:(nullable XZImageLineDash *)lineDash;

- (instancetype)initWithLine:(nullable XZImageLine *)line;

@end

NS_ASSUME_NONNULL_END
