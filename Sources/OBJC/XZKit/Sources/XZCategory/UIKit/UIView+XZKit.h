//
//  UIView.h
//  XZKit
//
//  Created by Xezun on 2019/3/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (XZKit)

/// 获取当前视图的图片快照。
///
/// @param afterUpdates 是否等待视图执行已添加但是未执行的更新。
/// @return 视图快照图片。
- (nullable UIImage *)xz_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates NS_SWIFT_NAME(snapshotImage(afterScreenUpdates:));

@end

NS_ASSUME_NONNULL_END
