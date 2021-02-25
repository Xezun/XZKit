//
//  XZKitGeometry.h
//  XZKit
//
//  Created by 徐臻 on 2019/3/27.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XZKit/XZKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

/// 与 UIEdgeInsets 相同，只不过方便适配 LTR/RTL 布局。
typedef struct XZ_BOXABLE XZEdgeInsets {
    /// 上边距。
    CGFloat top;
    /// 前边距。
    CGFloat leading;
    /// 底边距。
    CGFloat bottom;
    /// 后边距。
    CGFloat trailing;
} XZEdgeInsets;

/// 与 UIRectEdge 相同，只不过方便适配 LTR/RTL 布局。
typedef NS_OPTIONS(NSUInteger, XZRectEdge) {
    XZRectEdgeTop      = 1 << 0,
    XZRectEdgeLeading  = 1 << 1,
    XZRectEdgeBottom   = 1 << 2,
    XZRectEdgeTrailing = 1 << 3
};

/// 边距全部为零的常量。
UIKIT_EXTERN XZEdgeInsets const XZEdgeInsetsZero NS_SWIFT_NAME(XZEdgeInsets.zero);

/// 判断两个 XZEdgeInsets 是否相等。
/// @param edgeInsets1 XZEdgeInsets
/// @param edgeInsets2 XZEdgeInsets
/// @return 是否相等。
UIKIT_EXTERN BOOL XZEdgeInsetsEqualToEdgeInsets(XZEdgeInsets edgeInsets1, XZEdgeInsets edgeInsets2);

/// 构造 XZEdgeInsets 。
/// @param top 上边距。
/// @param leading 前边距。
/// @param bottom 底边距。
/// @param trailing 后边距。
/// @return XZEdgeInsets 值。
UIKIT_EXTERN XZEdgeInsets XZEdgeInsetsMake(CGFloat top, CGFloat leading, CGFloat bottom, CGFloat trailing) NS_SWIFT_UNAVAILABLE("Use EdgeInsets.init(top:leading:bottom:trailing:) instead.");

/// 将 UIEdgeInsets 转换为 XZEdgeInsets 。
/// @param edgeInsets 待转换的 UIEdgeInsets 值。
/// @param layoutDirection UIEdgeInsets 值的布局方向。
/// @return XZEdgeInsets 值。
UIKIT_EXTERN XZEdgeInsets XZEdgeInsetsFromUIEdgeInsets(UIEdgeInsets edgeInsets, UIUserInterfaceLayoutDirection layoutDirection) NS_SWIFT_UNAVAILABLE("Use EdgeInsets.init(_:layoutDirection:) instead.");

/// 将 XZEdgeInsets 转换为 UIEdgeInsets 。
/// @param edgeInsets 待转换的 XZEdgeInsets 值。
/// @param layoutDirection 指定布局方向。
/// @return UIEdgeInsets 值。
UIKIT_EXTERN UIEdgeInsets UIEdgeInsetsFromXZEdgeInsets(XZEdgeInsets edgeInsets, UIUserInterfaceLayoutDirection layoutDirection) NS_SWIFT_UNAVAILABLE("Use UIEdgeInsets.init(_:layoutDirection:) instead.");

/// 判断某点是否在指定的区域点边缘内。
/// @param bounds CGRect
/// @param edgeInsets UIEdgeInsets
/// @param point CGPoint
/// @return YES or NO
UIKIT_EXTERN BOOL CGRectContainsPointInEdgeInsets(CGRect bounds, UIEdgeInsets edgeInsets, CGPoint point) NS_SWIFT_UNAVAILABLE("Use CGRect.contains(_:in:) instead.");


FOUNDATION_EXPORT NSString *NSStringFromXZEdgeInsets(XZEdgeInsets edgeInsets);
FOUNDATION_EXPORT XZEdgeInsets XZEdgeInsetsFromString(NSString * _Nullable aString);
FOUNDATION_EXPORT NSString *NSStringFromXZRectEdge(XZRectEdge rectEdge);
FOUNDATION_EXPORT XZRectEdge XZRectEdgeFromString(NSString * _Nullable aString);

@interface NSValue (XZKitGeometry)

+ (NSValue *)valueWithXZEdgeInsets:(XZEdgeInsets)edgeInsets NS_SWIFT_NAME(init(_:));
@property (nonatomic, readonly) XZEdgeInsets XZEdgeInsetsValue;

@end

@interface NSCoder (XZKitGeometry)

- (void)encodeXZEdgeInsets:(XZEdgeInsets)insets forKey:(NSString *)key NS_SWIFT_NAME(encode(_:forKey:));
- (XZEdgeInsets)decodeXZEdgeInsetsForKey:(NSString *)key NS_SWIFT_NAME(decode(forKey:));

@end


/// 计算 size 在 rect 区域，以 contentMode 模式适配时的大小和位置。
/// @param size 待适配的大小
/// @param rect 适配的区域
/// @param contentMode 适配模式
FOUNDATION_EXPORT CGRect CGSizeFitingInRectWithContentMode(CGSize size, CGRect rect, UIViewContentMode contentMode);

NS_ASSUME_NONNULL_END
