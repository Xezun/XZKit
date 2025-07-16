//
//  NSString+XZExtendedEncoding.h
//  XZKit
//
//  Created by 徐臻 on 2025/7/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XZExtendedEncoding)

/// 将字符串中除字母和数字以外的字符，都应用 URI 百分号编码。
/// @attention 因为不被编码的字符范围较少，因此需考虑新字符串长度增加可能会带来的影响。
/// @discussion 本方法一般用于构造 JavaScript 代码时，避免特殊字符带来的语义问题。
@property (nonatomic, readonly) NSString *xz_stringByAddingPercentEncoding NS_SWIFT_NAME(addingPercentEncoding);

/// URI 编码，与 `JavaScript.encodeURI()` 函数作用相同。
/// @discussion 使用 `-stringByRemovingPercentEncoding` 方法移除 URI 编码。
/// @discussion 在不清楚 URL 保留字符是否会造成影响的情况下，推荐使用更安全的 `-xz_stringByAddingPercentEncoding` 方法。
/// @discussion 本方法一般用于转义 URL 中的非法字符，使 URL 变得可用。
@property (nonatomic, readonly) NSString *xz_stringByAddingURIEncoding NS_SWIFT_NAME(addingURIEncoding);

/// URI 编码，与 `JavaScript.encodeURIComponent()` 函数作用相同。
/// @discussion 使用 `-stringByRemovingPercentEncoding` 方法移除 URI 编码。
/// @discussion 在不清楚 URL 保留字符是否会造成影响的情况下，推荐使用更安全的 `-xz_stringByAddingPercentEncoding` 方法。
/// @discussion 本方法一般用于将字符串拼接到 URL 参数中。
@property (nonatomic, readonly) NSString *xz_stringByAddingURIComponentEncoding NS_SWIFT_NAME(addingURIComponentEncoding);

/// URI 解码，所有 URI 编码的字符都会被解码。
@property (nonatomic, readonly) NSString *xz_stringByRemovingURIEncoding NS_SWIFT_NAME(removingURIEncoding);

/// URI 解码，所有 URI 编码的字符都会被解码。
@property (nonatomic, readonly) NSString *xz_stringByRemovingURIComponentEncoding NS_SWIFT_NAME(removingURIComponentEncoding);

/// 中文转拼音，不带音标。
@property (nonatomic, readonly) NSString *xz_stringByTransformingMandarinToLatin NS_SWIFT_NAME(transformingMandarinToLatin);

/// 中文转拼音。
/// - Parameter removesDiacriticMarkings: 是否溢出音标
- (NSString *)xz_stringByTransformingMandarinToLatin:(BOOL)removesDiacriticMarkings NS_SWIFT_NAME(transformingMandarinToLatin(_:));

@end

NS_ASSUME_NONNULL_END
