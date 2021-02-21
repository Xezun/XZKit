//
//  XZImageLineDash+Extension.h
//  XZKit
//
//  Created by Xezun on 2021/2/21.
//

#import <XZKit/XZImageLineDash.h>

NS_ASSUME_NONNULL_BEGIN

@class XZImageLineDash;

@protocol XZImageLineDashDelegate <NSObject>

- (void)lineDashDidUpdate:(XZImageLineDash *)lineDash;

@end

@interface XZImageLineDash ()
@property (nonatomic, weak) id<XZImageLineDashDelegate> delegate;
/// 从另一个 lineDash 复制属性。如果 lineDash 为自身则不复制。
- (void)updateWithLineDash:(nullable XZImageLineDash *)lineDash;
@end

NS_ASSUME_NONNULL_END
