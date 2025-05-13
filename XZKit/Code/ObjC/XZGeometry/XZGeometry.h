//
//  XZGeometry.h
//  XZGeometry
//
//  Created by 徐臻 on 2025/4/27.
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

/// 在 size 范围内创建一个宽高比为 ratio 的 CGSize 结构体。
/// - Parameters:
///   - size: 待创建 CGSize 的尺寸范围
///   - ratio: 待创建 CGSize 的宽高比
UIKIT_EXTERN CGSize CGSizeMakeAspectRatioInside(CGSize size, CGSize ratio) NS_REFINED_FOR_SWIFT;

/// 在 size 范围内，保持宽高比，将 aspect 缩放到范围以内，如果 aspect 已经在范围内，则不缩放。
/// - Parameters:
///   - size: 缩放的范围
///   - aspect: 被缩的 CGSize 值
UIKIT_EXTERN CGSize CGSizeScaleAspectRatioInside(CGSize size, CGSize aspect) NS_REFINED_FOR_SWIFT;

/// 在 rect 区域内，按 contentMode 适配模式，创建一个适配大小为 aspect 的 CGRect 结构体。
///
/// - Parameters:
///   - rect: 适配区域
///   - aspect: 适配大小
///   - contentMode: 适配模式
UIKIT_EXTERN CGRect CGRectMakeAspectRatioWithMode(CGRect rect, CGSize aspect, UIViewContentMode contentMode) NS_REFINED_FOR_SWIFT;

/// 在 rect 区域内，按 contentMode 模式，创建一个宽高比为 ratio 内容的 CGRect 结构体。
///
/// - Parameters:
///   - rect: 待创建 CGRect 所在的区域
///   - ratio: 待创建 CGRect 的宽高比，根据 contentMode 模式，函数返回值结构体宽高比可能并非与此参数相同
///   - contentMode: 待创建 CGRect 在 aspect 区域中的适配模式
UIKIT_EXTERN CGRect CGRectMakeAspectRatioInsideWithMode(CGRect rect, CGSize ratio, UIViewContentMode contentMode) NS_REFINED_FOR_SWIFT;

/// 在 rect 区域内，按 contentMode 模式，将 aspect 缩放到区域范围内。
///
/// 生成的 CGRect 优先保持 aspect 不变，但是由于 contentMode 模式的不同，也可能比 aspect 大或小。
///
/// - Parameters:
///   - rect: 待创建 CGRect 所在的区域
///   - aspect: 待创建 CGRect 的大小或宽高比
///   - contentMode: 适配模式
UIKIT_EXTERN CGRect CGRectScaleAspectRatioInsideWithMode(CGRect rect, CGSize aspect, UIViewContentMode contentMode) NS_REFINED_FOR_SWIFT;

NS_ASSUME_NONNULL_END
