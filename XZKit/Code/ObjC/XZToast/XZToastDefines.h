//
//  XZToastDefines.h
//  Pods
//
//  Created by 徐臻 on 2025/5/10.
//

#import <UIKit/UIKit.h>

/// 显示或隐藏 toast 的动画时长，0.35 秒。
FOUNDATION_EXPORT NSTimeInterval const XZToastAnimationDuration NS_REFINED_FOR_SWIFT;

/// XZToast 的显示位置。
typedef NS_ENUM(NSInteger, XZToastPosition) {
    /// XZToast 显示在顶部。
    XZToastPositionTop = 0, // 会被用作数组 index 必须从 0 开始
    /// XZToast 显示在中部。
    XZToastPositionMiddle,
    /// XZToast 显示在底部。
    XZToastPositionBottom,
} NS_REFINED_FOR_SWIFT;

/// 展示提示信息完成后的回调块函数类型。
///
/// 该块函数，会被呈现它的控制器强持有，直接捕获控制器可能会造成循环引用。比如，对于常显 XZToast 类型，即展示时长`duration`为零的类型，如果没有`hideToast`操作可能会造成内存泄漏。
///
/// @param finished 如果 XZToast 在 duration 之前被取消，该参数为 NO 值，所以对于常显类型，此参数肯定为 NO 值
typedef void (^XZToastCompletion)(BOOL finished) NS_REFINED_FOR_SWIFT;



