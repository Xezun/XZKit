//
//  UIView.h
//  XZKit
//
//  Created by 徐臻 on 2019/3/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (XZKit)

/// 获取当前 keyWindow 的屏幕快照，包括 status bar 。
///
/// @param afterUpdates 是否等待屏幕执行已添加但是未执行的更新。
/// @return 屏幕快照。
+ (nullable UIView *)xz_snapshotViewAfterScreenUpdates:(BOOL)afterUpdates NS_SWIFT_NAME(snapshotView(afterScreenUpdates:));

/// 获取当前视图的图片快照。
///
/// @param afterUpdates 是否等待视图执行已添加但是未执行的更新。
/// @return 视图快照图片。
- (nullable UIImage *)xz_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates NS_SWIFT_NAME(snapshotImage(afterScreenUpdates:));

@end

NS_ASSUME_NONNULL_END
