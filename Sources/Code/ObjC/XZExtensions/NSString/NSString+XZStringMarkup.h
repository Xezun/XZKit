//
//  NSString+XZStringMarkup.h
//  XZKit
//
//  Created by 徐臻 on 2025/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 字符串标记符，标记字符串开始和结束的一对特殊符号。
///
/// 字符串标记符用于标记字符串中的子字符串，以方便查找、替换等操作。
///
/// ### 标记符语法规则
///
/// 下面以自定义格式化字符串为例，列举字符串标记的使用方法。
///
/// - 支持使用任意标记符，提供了默认使用花括号作为标记符的方法。
/// ```objc
/// + (instancetype)xz_stringWithMarkup:(XZStringMarkup)markup format:(NSString *)format, ...;
/// + (instancetype)xz_stringWithBracesFormat:(NSString *)format, ...;
/// ```
/// - 自定义字符串格式化，以自然数（从 1 开始）作为参数列表中指定位置的参数。
/// ```objc
/// // produces: @"ABA"
/// [NSString xz_stringWithBracesFormat:@"{1}{2}{1}", @"A", @"B"]
/// ```
/// - 支持附加 c 字符串格式，且格式会继承前一个。
/// ```objc
/// // produces @"3.14"
/// [NSString xz_stringWithBracesFormat:@"{1%.2f}", M_PI];
/// // produces: @"3.14 3.14"
/// [NSString xz_stringWithBracesFormat:@"{1%.2f} {1}", M_PI];
/// // produces: @"3.14 3.14 3.142 3.142"
/// [NSString xz_stringWithBracesFormat:@"{1%.2f} {1} {1%.3f} {1}", M_PI];
/// ```
/// - 两个连续的标记字符，将作为一个普通字符逃逸，且按照“开始标记左结合，结束标记右结合”的结合性规则进行逃逸。
/// ```objc
/// // produces: @"{1}"
/// [NSString xz_stringWithBracesFormat:@"{{1}}", @"abc"]
/// // produces: @"{abc}"
/// [NSString xz_stringWithBracesFormat:@"{{{1}}}", @"abc"]
/// ```
/// - 标记字符必须使用逃逸，无法闭合的标记字符会被忽略。
/// ```objc
/// // produces: @"123abc"
/// [NSString xz_stringWithBracesFormat:@"{123{1}", @"abc"]
/// // produces: @"abc123"
/// [NSString xz_stringWithBracesFormat:@"{1}123}", @"abc"]
/// ```
typedef struct XZStringMarkup {
    /// 开始字符。两个连续的开始字符，视为一个逃逸了的开始字符。
    char start;
    /// 结束字符。没有匹配开始字符的结束字符，作为普通字符处理。
    char end;
} XZStringMarkup;

/// 构造占位分隔符。
/// - Parameters:
///   - start: 起始字符
///   - end: 终止字符
FOUNDATION_STATIC_INLINE XZStringMarkup XZStringMarkupMake(char start, char end) {
    return (XZStringMarkup){ start, end };
}

/// 本地化字符串中，默认以大括号 `{}` 作为参数分隔符。
FOUNDATION_EXPORT XZStringMarkup const XZStringMarkupBraces;

@interface NSString (XZMarkupReplacing)

/// 替换字符串中被指定标记符包裹的字符串。
///
/// - SeeAlso: ``XZStringMarkup``
///
/// - Parameters:
///   - predicate: 标记符
///   - transform: 被标记包裹的字符串
- (NSString *)xz_stringByReplacingMatchesOfMarkup:(XZStringMarkup)markup usingBlock:(NSString *(^NS_NOESCAPE)(NSString *matchedString))transform NS_SWIFT_NAME(replacingMatches(of:using:));

/// 替换字符串中被指定标记符包裹的字符串。
///
/// - SeeAlso: ``XZStringMarkup``
///
/// - Parameters:
///   - predicate: 标记符
///   - aDictionary: key 为被标记符包裹的字符串，value 为待替换的内容
- (NSString *)xz_stringByReplacingMatchesOfMarkup:(XZStringMarkup)markup usingDictionary:(NSDictionary<NSString *, NSString *> *)aDictionary NS_SWIFT_NAME(replacingMatches(of:using:));

@end

@interface NSString (XZMarkupFormatting)

/// 使用标记符进行格式化字符串构造字符串。
///
/// - SeeAlso: ``XZStringMarkup``
/// 
/// - Parameters:
///   - markup: 标记符
///   - format: 字符串格式
///   - arguments: 参数列表
+ (instancetype)xz_stringWithMarkup:(XZStringMarkup)markup format:(NSString *)format arguments:(va_list)arguments NS_SWIFT_UNAVAILABLE("Swift Not Support");

/// 使用标记字符作为占位符的字符串格式化创建方式。
///
/// - SeeAlso: ``XZStringMarkup``
///
/// - Parameters:
///   - predicate: 标记字符
///   - format: 字符串格式
+ (instancetype)xz_stringWithMarkup:(XZStringMarkup)markup format:(NSString *)format, ...;

/// 使用花括号作为标记的字符串格式。
///
/// - SeeAlso: ``XZStringMarkup``
///
/// - Parameter format: 字符串格式
+ (instancetype)xz_stringWithBracesFormat:(NSString *)format, ...;

@end

NS_ASSUME_NONNULL_END
