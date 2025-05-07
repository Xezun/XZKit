//
//  UIKit+XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/4/29.
//

#import <UIKit/UIKit.h>
#import "XZToast.h"

NS_ASSUME_NONNULL_BEGIN

@class XZToastTask;

@interface UIResponder (XZToast)

- (nullable XZToastTask *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(void (^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(showToast(_:duration:position:exclusive:completion:));

- (nullable XZToastTask *)xz_showToast:(XZToast *)toast NS_SWIFT_NAME(showToast(_:));

- (void)xz_hideToast:(nullable XZToastTask *)task completion:(nullable void (^)(void))completion;
- (void)xz_hideToast:(nullable void (^)(void))completion;

/// 刷新 toast 的布局。
///
/// 如果在展示 toast 的期间，控制器的大小发生了改变，需要调用此方法来刷新布局。
- (void)xz_setNeedsLayoutToastViews;

@property (nonatomic, setter=xz_setMaximumNumberOfToasts:) NSUInteger xz_maximumNumberOfToasts;

- (void)xz_setOffset:(CGFloat)offset forToastInPosition:(XZToastPosition)position;
- (CGFloat)xz_offsetForToastInPosition:(XZToastPosition)position;

@end

NS_ASSUME_NONNULL_END
