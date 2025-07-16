//
//  NSString+XZHexEncoding.h
//  XZKit
//
//  Created by 徐臻 on 2025/7/16.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/NSData+XZKit.h>
#else
#import "NSData+XZKit.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XZHexEncoding)

/// 对当前字符串的二进制数据，进行十六进制编码。
/// @param stringEncoding 字符串二进制形式的编码
/// @param hexEncoding 十六进制字符的大小写
- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding usingEncoding:(NSStringEncoding)stringEncoding NS_SWIFT_NAME(addingHexEncoding(_:using:));

/// 对当前字符串的二进制数据，使用小写字母，进行十六进制编码。
/// @param stringEncoding 字符串二进制形式的编码
- (NSString *)xz_stringByAddingHexEncodingUsingEncoding:(NSStringEncoding)stringEncoding NS_SWIFT_NAME(addingHexEncoding(using:));

/// 对当前字符串 UTF-8 编码形式的二进制数据，进行十六进制编码。
/// @param hexEncoding 十六进制字符的大小写
- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding NS_SWIFT_NAME(addingHexEncoding(_:));

/// 对当前字符串 UTF-8 编码形式的二进制数据，使用小写字母，进行十六进制编码。
@property (nonatomic, readonly) NSString *xz_stringByAddingHexEncoding NS_SWIFT_NAME(addingHexEncoding);

/// 对原始字符串的十六进制编码字符串进行解码。
/// @param dataEncoding 原始字符串的二进制编码
- (NSString *)xz_stringByRemovingHexEncodingUsingEncoding:(NSStringEncoding)dataEncoding NS_SWIFT_NAME(removingHexEncoding(using:));

/// 对使用 UTF-8 编码的原始字符串的十六进制编码字符串进行解码。
@property (nonatomic, readonly) NSString *xz_stringByRemovingHexEncoding NS_SWIFT_NAME(removingHexEncoding);

@end

NS_ASSUME_NONNULL_END
