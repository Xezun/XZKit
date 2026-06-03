//
//  XZGeometry.h
//  XZGeometry
//
//  Created by Xezun on 2025/4/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 将 UIEdgeInsets 结构体转换为 NSDirectionalEdgeInsets 结构体。
/// - Parameters:
///   - edgeInsets: UIEdgeInsets 结构体
///   - layoutDirection: 布局方向
UIKIT_EXTERN NSDirectionalEdgeInsets NSDirectionalEdgeInsetsFromUIEdgeInsets(UIEdgeInsets edgeInsets, UIUserInterfaceLayoutDirection layoutDirection) NS_REFINED_FOR_SWIFT;

/// 将 NSDirectionalEdgeInsets 结构体转换为 UIEdgeInsets 结构体。
/// - Parameters:
///   - edgeInsets: NSDirectionalEdgeInsets 结构体
///   - layoutDirection: 布局方向
UIKIT_EXTERN UIEdgeInsets UIEdgeInsetsFromNSDirectionalEdgeInsets(NSDirectionalEdgeInsets edgeInsets, UIUserInterfaceLayoutDirection layoutDirection) NS_REFINED_FOR_SWIFT;

/// 判断点 point 是否在矩形区域 rect 的边距 edgeInsets 内。
/// - Parameters:
///   - rect: 矩形区域
///   - edgeInsets: 边距
///   - point: 待判定的点
UIKIT_EXTERN BOOL CGRectContainsPointInEdgeInsets(CGRect rect, UIEdgeInsets edgeInsets, CGPoint point) NS_REFINED_FOR_SWIFT;

/// 返回在 size 范围内，范围最大、宽高比为 ratio 的区域的 CGSize 值。
/// - Parameters:
///   - size: 待创建 CGSize 的范围
///   - ratio: 待创建 CGSize 的宽高比
UIKIT_EXTERN CGSize CGSizeMakeAspectRatioInside(CGSize size, CGSize ratio) NS_REFINED_FOR_SWIFT;

/// 保持宽高比，将 aspect 缩放到 size 范围以内，如果 aspect 已经在范围内，则不缩放。
/// - Parameters:
///   - size: 缩放的范围
///   - aspect: 被缩的 CGSize 值
UIKIT_EXTERN CGSize CGSizeScaleAspectRatioInside(CGSize size, CGSize aspect) NS_REFINED_FOR_SWIFT;

/// 缩放，宽高分别乘以 scale 。
FOUNDATION_STATIC_INLINE CGSize CGSizeApplyScale(CGSize size, CGFloat scale) NS_REFINED_FOR_SWIFT {
    return CGSizeMake(size.width * scale, size.height * scale);
};

/// 生成按 contentMode 模式，大小为 size 的范围，在 rect 内的适配区域。
///
/// - Parameters:
///   - rect: 适配区域
///   - size: 适配大小
///   - contentMode: 适配模式
UIKIT_EXTERN CGRect CGRectAdjustSizeWithMode(CGRect rect, CGSize size, UIViewContentMode contentMode) NS_REFINED_FOR_SWIFT;

/// 保持宽高比，在 rect 区域内，按 contentMode 模式创建一个宽高比为 ratio 的最大区域。
///
/// 内容模式 `.scaleToFill`、`.scaleAspectFit`、`.scaleAspectFill`、`.redraw`、 的效果与 `.center` 相同。
///
/// - Parameters:
///   - rect: 待创建 CGRect 所在的区域
///   - ratio: 待创建 CGRect 的宽高比，根据 contentMode 模式，函数返回值结构体宽高比可能并非与此参数相同
///   - contentMode: 待创建 CGRect 在 aspect 区域中的适配模式
UIKIT_EXTERN CGRect CGRectMakeAspectRatioInsideWithMode(CGRect rect, CGSize ratio, UIViewContentMode contentMode) NS_REFINED_FOR_SWIFT;

/// 保持宽高比，将大小为 aspect 的内容，按 contentMode 模式，缩放到 rect 区域内。
///
/// 如果 aspect 比 rect 小，那么它在 rect 中保持大小不变。
///
/// 内容模式 `.scaleToFill`、`.scaleAspectFit`、`.scaleAspectFill`、`.redraw`、 的效果与 `.center` 相同。
///
/// - Parameters:
///   - rect: 待创建 CGRect 所在的区域
///   - aspect: 待创建 CGRect 的大小或宽高比
///   - contentMode: 适配模式
UIKIT_EXTERN CGRect CGRectScaleAspectRatioInsideWithMode(CGRect rect, CGSize aspect, UIViewContentMode contentMode) NS_REFINED_FOR_SWIFT;

/// 设置 rect 的 size 值。
FOUNDATION_STATIC_INLINE CGRect CGRectSetSize(CGRect rect, CGSize size) {
    rect.size = size;
    return rect;
}

/// 设置 rect 的 origin 值。
FOUNDATION_STATIC_INLINE CGRect CGRectSetOrigin(CGRect rect, CGPoint origin) {
    rect.origin = origin;
    return rect;
}

/// 设置 rect 的 origin.x 值。
FOUNDATION_STATIC_INLINE CGRect CGRectSetX(CGRect rect, CGFloat x) {
    rect.origin.x = x;
    return rect;
}

/// 设置 rect 的 origin.y 值。
FOUNDATION_STATIC_INLINE CGRect CGRectSetY(CGRect rect, CGFloat y) {
    rect.origin.y = y;
    return rect;
}

/// 设置 rect 的 size.width 值。
FOUNDATION_STATIC_INLINE CGRect CGRectSetWidth(CGRect rect, CGFloat width) {
    rect.size.width = width;
    return rect;
}

/// 设置 rect 的 size.height 值。
FOUNDATION_STATIC_INLINE CGRect CGRectSetHeight(CGRect rect, CGFloat height) {
    rect.size.height = height;
    return rect;
}

NS_ASSUME_NONNULL_END
