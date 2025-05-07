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

- (nullable XZToast *)xz_showToast:(XZToast *)toast duration:(NSTimeInterval)duration position:(XZToastPosition)position exclusive:(BOOL)exclusive completion:(void (^_Nullable)(BOOL finished))completion NS_SWIFT_NAME(showToast(_:duration:position:exclusive:completion:));

- (nullable XZToast *)xz_showToast:(XZToast *)toast NS_SWIFT_NAME(showToast(_:));

- (void)xz_hideToast:(nullable XZToast *)toast completion:(nullable void (^)(void))completion;
- (void)xz_hideToast:(nullable void (^)(void))completion;

/// 刷新 toast 的布局。
///
/// 如果在展示 toast 的期间，控制器的大小发生了改变，需要调用此方法来刷新布局。
- (void)xz_setNeedsLayoutToastViews;

/// 可同时展示的 toast 的数量。
@property (nonatomic, setter=xz_setMaximumNumberOfToasts:) NSUInteger xz_maximumNumberOfToasts NS_SWIFT_NAME(maximumNumberOfToasts);

/// 设置指定位置的 toast 的偏移值。
/// - Parameters:
///   - offset: 偏移值
///   - position: toast 展示位置
- (void)xz_setOffset:(CGFloat)offset forToastInPosition:(XZToastPosition)position NS_SWIFT_NAME(setOffset(_:forToastIn:));

/// 获取指定位置 toast 的偏移值。
/// - Parameter position: toast 展示位置
- (CGFloat)xz_offsetForToastInPosition:(XZToastPosition)position NS_SWIFT_NAME(offset(forToastIn:));

@end

NS_ASSUME_NONNULL_END
