//
//  XZImageLineDash+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageLineDash.h>
#import <XZKit/XZImageAttribute+Extension.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZImageLineDash ()
/// 从另一个 lineDash 复制属性。如果 lineDash 为自身则不复制。
/// @note 该方法不触发事件。
- (void)updateWithLineDash:(nullable XZImageLineDash *)lineDash;
@end

NS_ASSUME_NONNULL_END
