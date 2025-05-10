//
//  XZToastDefines.h
//  Pods
//
//  Created by 徐臻 on 2025/5/10.
//

#import <UIKit/UIKit.h>

/// 显示或隐藏 toast 的动画时长，0.3 秒。
FOUNDATION_EXPORT NSTimeInterval const XZToastAnimationDuration NS_SWIFT_NAME(XZToast.animationDuration);

/// XZToast 的显示位置。
typedef NS_ENUM(NSUInteger, XZToastPosition) {
    /// XZToast 显示在顶部。
    XZToastPositionTop = 0, // 会被用作数组 index 必须从 0 开始
    /// XZToast 显示在中部。
    XZToastPositionMiddle,
    /// XZToast 显示在底部。
    XZToastPositionBottom,
} NS_SWIFT_NAME(XZToast.Position);

/// 显示或隐藏提示信息的回调块函数类型。
/// @param finished 如果 toast 在 duration 之前被取消，该参数为 NO 值
typedef void (^XZToastCompletion)(BOOL finished) NS_SWIFT_NAME(XZToast.Completion);
