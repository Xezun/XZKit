//
//  NSString+XZStringMarkup.h
//  XZKit
//
//  Created by Xezun on 2025/7/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 字符串标记符：标记字符串起始位置和结束为止的字符。
///
/// 任意 ASCII 字符都可以作为标记符。
///
/// 比如在字符串 `"I'm {name}"` 中，子字符串 `"{name}"` 的标记字符：
/// - `"{"`：开始字符。
/// - `"}"`：结束字符。
typedef struct XZStringMarkup {
    /// 开始字符。
    char start;
    /// 结束字符。
    char end;
} XZStringMarkup;

/// 构造字符串标记符结构体。
/// - Parameters:
///   - start: 起始字符
///   - end: 结束字符
FOUNDATION_STATIC_INLINE XZStringMarkup XZStringMarkupMake(char start, char end)  __attribute__((enable_if(start != end, "start and end must not be same"))) {
    return (XZStringMarkup){ start, end };
}

/// 用花括号 `"{}"` 作为开始字符和结束字符的字符串标记符。
///
/// 在 `XZLocale` 中，本地化字符串中的表示参数的字符串，以此为标记符。
FOUNDATION_EXPORT XZStringMarkup const XZStringMarkupBraces NS_SWIFT_NAME(XZStringMarkup.braces);

@interface NSString (XZMarkupReplacing)

// 带标记字符的字符串，可能无法作为普通字符串使用，因为其可能包含逃逸的标记字符，因此暂不提供遍历的方法。
//- (void)xz_enumerateSubstringsWithMarkup:(XZStringMarkup)markup usingBlock:(void (^NS_NOESCAPE)(NSRange range))block;

/// 替换字符串中，被指定标记符标记的子字符串。
///
/// 此方法常用于替换字符串中的参数。
///
/// ```objc
/// [@"I'm {name}, {age} years old." xz_stringByReplacingOccurrencesWithMarkup:(XZStringMarkupBraces) usingBlock:^NSString *(NSString *substring) {
///     if ([substring isEqualToString:@"name"]) {
///         return @"John";
///     }
///     return @"17";
/// }];
/// // equals: I'm John, 17 years old.
/// ```
///
/// 在字符串支持对标记符号进行逃逸，规则为：
/// - 两个连续相同的标记符，视为一次逃逸，比如 `@"{{key}}"` 无法匹配到任何子字符串，因为标记符逃逸了。
/// - 连续的开始字符，左边的优先逃逸，比如 `@"{{{key}}}"` 中的开始字符，从左边开始计算，每两个开始字符，算一次逃逸。
/// - 连续的结束字符，右边的优先逃逸，比如 `@"{{{key}}}"` 中的结束字符，从右边开始计算，每两个结束字符，算一次逃逸。
///
/// - Parameters:
///   - markup: 标记符
///   - transform: 字符串匹配替换映射函数，此块函数返回值不能为 `nil` 且必须为 `NSString` 类型。
- (NSString *)xz_stringByReplacingOccurrencesWithMarkup:(XZStringMarkup)markup usingBlock:(NSString *(^NS_NOESCAPE)(NSString *substring))transform NS_SWIFT_NAME(replacingOccurrences(with:using:));

/// 将指定标记符标记的字符串，替换为字典中以该字符串为键的值。
///
/// 字典的值建议为 NSString 对象，否则会使用其`description`属性作为替换内容。
///
/// ```objc
/// [@"I'm {name}, {age} years old." xz_stringByReplacingOccurrencesWithMarkup:(XZStringMarkupBraces) usingDictionary:@{
///     @"name": @"John",
///     @"age": @"17"
/// }];
/// // equals: I'm John, 17 years old.
/// ```
///
/// - Parameters:
///   - markup: 标记符
///   - aDictionary: key 为被标记的子字符串，value 为待替换的内容
- (NSString *)xz_stringByReplacingOccurrencesWithMarkup:(XZStringMarkup)markup usingDictionary:(NSDictionary<NSString *, id> *)aDictionary NS_SWIFT_NAME(replacingOccurrences(with:using:));

@end

@class NSArray;

@interface NSString (XZMarkupFormatting)

/// 使用以标记符构成字符串的模版，构造字符串。
///
/// - Parameters:
///   - markup: 标记符
///   - format: 字符串格式
///   - arguments: 参数列表
+ (instancetype)xz_stringWithMarkup:(XZStringMarkup)markup format:(NSString *)format arguments:(va_list)arguments NS_SWIFT_NAME(init(markup:format:arguments:));

/// 使用以标记符构成字符串的模版，构造字符串。
///
/// - SeeAlso: ``init(braces:)``
///
/// - Parameters:
///   - predicate: 标记字符
///   - format: 字符串格式
+ (instancetype)xz_stringWithMarkup:(XZStringMarkup)markup format:(NSString *)format, ... NS_SWIFT_NAME(init(markup:format:));

/// 使用以花括号标记符构成字符串的模版，构造字符串。
///
/// ### 标记符模版规则
///
/// 下面以自定义格式化字符串为例，列举字符串标记的使用方法。
///
/// - 默认以自然数（从 1 开始）作为参数列表中指定位置的参数，参数类型默认为对象。
///
/// ```objc
/// // produces: @"ABA"
/// [NSString xz_stringWithBracesFormat:@"{1}{2}{1}", @"A", @"B"]
/// ```
///
/// - 支持指定参数类型，在数字后拼接 c 格式即可，且 c 格式只需要指定一次。另，字符串中其它的 `%` 字符需要逃逸。
///
/// ```objc
/// [NSString xz_stringWithBracesFormat:@"{1%.2f}", M_PI];
/// // produces @"3.14"
/// [NSString xz_stringWithBracesFormat:@"{1%.2f} {1}", M_PI];
/// // produces: @"3.14 3.14"
/// [NSString xz_stringWithBracesFormat:@"{1%.2f} {1} {1%.3f} {1}", M_PI];
/// // produces: @"3.14 3.14 3.142 3.142"
/// [NSString xz_stringWithBracesFormat:@"{1%.2f}%%", 32.156];
/// // produces: @"32.16%"
/// ```
///
/// - 逃逸规则，连续两个相同的标记字符，视为一次逃逸，且按照“开始标记左结合，结束标记右结合”的结合性进行逃逸。
///
/// ```objc
/// // produces: @"{1}"
/// [NSString xz_stringWithBracesFormat:@"{{1}}", @"abc"]
/// // produces: @"{abc}"
/// [NSString xz_stringWithBracesFormat:@"{{{1}}}", @"abc"]
/// ```
///
/// - 无法闭合的标记字符会被忽略，所以要输出单个标记字符，必须使用逃逸，。
///
/// ```objc
/// // produces: @"123abc"
/// [NSString xz_stringWithBracesFormat:@"{123{1}", @"abc"]
/// // produces: @"abc123"
/// [NSString xz_stringWithBracesFormat:@"{1}123}", @"abc"]
/// ```
///
/// - SeeAlso: ``XZStringMarkup``
///
/// - Parameter format: 字符串格式
+ (instancetype)xz_stringWithBracesFormat:(NSString *)format, ... NS_SWIFT_NAME(init(braces:));

@end

NS_ASSUME_NONNULL_END
