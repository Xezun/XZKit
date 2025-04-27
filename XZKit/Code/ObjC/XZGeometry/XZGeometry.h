//
//  XZGeometry.h
//  XZGeometry
//
//  Created by 徐臻 on 2025/4/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 在 size 范围内创建一个宽高比为 ratio 的 CGSize 结构体。
/// - Parameters:
///   - size: 待创建 CGSize 的宽高比
///   - aspect: 待创建 CGSize 的尺寸范围
UIKIT_EXTERN CGSize CGSizeMakeAspectRatioInside(CGSize size, CGSize aspect) NS_REFINED_FOR_SWIFT;

/// 保持宽高比，将 size 缩放到 aspect 范围内，如果 size 已经比 aspect 小，则不缩放。
/// - Parameters:
///   - size: 被缩放的 CGSize 值
///   - aspect: 缩放后的 CGSize 的宽高值范围
UIKIT_EXTERN CGSize CGSizeScaleAspectRatioInside(CGSize size, CGSize aspect) NS_REFINED_FOR_SWIFT;

/// 创建一个按 contentMode 模式在 aspect 区域适配大小为 size 内容的 CGRect 结构体。
///
/// 生成的 CGRect 优先保持 size 不变，但是由于 contentMode 模式的不同，也可能比 size 大或小。
///
/// - Parameters:
///   - size: 待创建 CGRect 的宽高比或大小
///   - aspect: 待创建 CGRect 所在的区域
///   - contentMode: 待创建 CGRect 在 aspect 区域中的适配模式
UIKIT_EXTERN CGRect CGRectMakeAspectRatioWithMode(CGSize size, CGRect aspect, UIViewContentMode contentMode) NS_REFINED_FOR_SWIFT;

/// 将 size 按 contentMode 缩放到 aspect 区域内。
/// 
/// - Parameters:
///   - size: 待创建 CGRect 的大小或宽高比
///   - aspect: 待创建 CGRect 所在的区域
///   - contentMode: 适配模式
UIKIT_EXTERN CGRect CGRectScaleAspectRatioWithMode(CGSize size, CGRect aspect, UIViewContentMode contentMode) NS_REFINED_FOR_SWIFT;

NS_ASSUME_NONNULL_END
