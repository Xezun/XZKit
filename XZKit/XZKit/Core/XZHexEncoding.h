//
//  XZHexEncoding.h
//  XZKit
//
//  Created by Xezun on 2019/3/30.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZDefines.h>

NS_ASSUME_NONNULL_BEGIN

/// 十六进制编码。
typedef NS_ENUM(NSUInteger, XZHexEncoding) {
    /// 小写字母十六进制编码。
    XZHexEncodingLowercase,
    /// 大写字母十六进制编码。
    XZHexEncodingUppercase,
};

@interface NSData (XZHexEncoding)

/// 解码十六进制编码的字符串为二进制数据。
/// @note 如果字符串不合法，转换会提前结束，返回已完成部分的结果。
/// @note 十六进制编码，将一个二进制字节用两个十六进制字符表示，因此十六进制编码字符串的长度为必然是偶数，
///       所以本方法会舍弃最后一个在奇数位上的字符，不论它是否为合法的十六进制编码字符。
/// @param hexEncodedString 十六进制编码字符串
/// @return NSData
+ (instancetype)xz_dataWithHexEncodedString:(NSString *)hexEncodedString;

/// 对当前二进制数据进行十六进制编码。
/// @discussion 编码将完全反映数据的二进制形式，这可能与某些规则不同，例如某些Unicode编码方式，
///       虽然也是十六进制编码，但是可能会添加额外的间隔符来分割字符，也可能会省略前置为 0 的空位。
/// @param hexEncoding 大写或小写
/// @return 十六进制编码字符串
- (NSString *)xz_hexEncodedString:(XZHexEncoding)hexEncoding;

/// 以十六进制编码小写格式，对当前数据进行编码。
@property (nonatomic, readonly) NSString *xz_hexEncodedString;

@end


@interface NSString (XZHexEncoding)

/// 使用十六进制编码将二进制数据转换成字符串。
/// @param bytes 二进制数据
/// @param length 数据长度
/// @param hexEncoding 十六进制编码的大小写
+ (nullable instancetype)xz_stringWithBytes:(const void *)bytes length:(NSUInteger)length hexEncoding:(XZHexEncoding)hexEncoding;

/// 使用十六进制编码将二进制数据转换成字符串。
/// @note 对于不连续的 NSData 二进制数据，本方法比用 `-xz_initWithBytes:length:hexEncoding:` 更高效。
/// @param data 二进制数据 NSData 对象
/// @param hexEncoding 十六进制编码的大小写
+ (nullable instancetype)xz_stringWithData:(NSData *)data hexEncoding:(XZHexEncoding)hexEncoding;

/// 对当前字符串的二进制数据，进行十六进制编码。
/// @param stringEncoding 字符串二进制形式的编码
/// @param hexEncoding 十六进制字符的大小写
- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding usingEncoding:(NSStringEncoding)stringEncoding;

/// 对当前字符串的二进制数据，使用小写字母，进行十六进制编码。
/// @param stringEncoding 字符串二进制形式的编码
- (NSString *)xz_stringByAddingHexEncodingUsingEncoding:(NSStringEncoding)stringEncoding;

/// 对当前字符串 UTF-8 编码形式的二进制数据，进行十六进制编码。
/// @param hexEncoding 十六进制字符的大小写
- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding;

/// 对当前字符串 UTF-8 编码形式的二进制数据，使用小写字母，进行十六进制编码。
@property (nonatomic, readonly) NSString *xz_stringByAddingHexEncoding;

/// 对原始字符串的十六进制编码字符串进行解码。
/// @param dataEncoding 原始字符串的二进制编码
- (NSString *)xz_stringByRemovingHexEncodingUsingEncoding:(NSStringEncoding)dataEncoding;

/// 对使用 UTF-8 编码的原始字符串的十六进制编码字符串进行解码。
@property (nonatomic, readonly) NSString *xz_stringByRemovingHexEncoding;

@end


/// 返回二进制字节数据对应的十六进制编码。
/// @discussion 编码，一般指的是将“可读的字符”编码为“二进制数据”的过程，而十六进制编码，则是将数据二进制形式通过可读的十六进制字符形式呈现出来。
/// @discussion 因此对字符串进行十六进制编码，需先将其用其它编码转换成二进制数据，然后将每四位转换为一个对应的十六进制字符。
/// @param byte 四位二进制数据
/// @param hexEncoding 十六进制编码的大小写形式
/// @return 十六进制编码的字符
FOUNDATION_EXPORT unsigned char XZHexEncoder(UInt8 byte, XZHexEncoding hexEncoding);

/// 对字符进行十六进制解码，还原为原始二进制数据。
/// @param character 十六进制编码的字符
/// @param byte 如果读取成功，二进制数据通过此参数输出，此参数不可为 NULL
/// @return 返回 NO 表示读入的字符不是十六进制编码字符
FOUNDATION_EXPORT BOOL XZHexDecoder(unichar character, UInt8 * const byte) XZ_GUARD(byte, "byte can not be NULL");


NS_ASSUME_NONNULL_END
