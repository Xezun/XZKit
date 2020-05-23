//
//  XZKit+NSString.h
//  XZKit
//
//  Created by 徐臻 on 2019/3/30.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZKitDefines.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (XZEncoding)

/// 通过用十六进制字符串表示的二进制数据来构造 NSData 对象。
/// @note 如果字符串不合法，转换会提前结束，返回已完成部分的结果。
/// @note 一般情况下，二进制数据的十六进制形式字符串长度是偶数，且为二进制数据长度的二倍。
/// @param hexadecimalEncodedString 十六进制数字的字符串。
/// @return NSData
+ (NSData *)xz_dataWithHexadecimalEncodedString:(NSString *)hexadecimalEncodedString NS_SWIFT_NAME(init(hexadecimalEncoded:));

/// 返回当前二进制数据的十六进制字符串形式。
///
/// @param characterCase 大写或小写。
/// @return 数据的十六进制形式。
- (NSString *)xz_hexadecimalEncodedStringWithCharacterCase:(XZCharacterCase)characterCase NS_SWIFT_NAME(hexadecimalEncodedString(with:));

/// 返回数据的十六进制字符串形式，默认大写字母。
@property (nonatomic, readonly) NSString *xz_hexadecimalEncodedString NS_SWIFT_NAME(hexadecimalEncodedString);

@end

@interface NSString (XZEncoding)

/// 将二进制数据的十六进制形式，转换成字符串。
/// @param bytes 二进制字节数据。
/// @param length 数据的长度。
/// @param characterCase 十六进制字母的大小写格式。
+ (NSString *)xz_stringHexadecimalEncodedWithBytes:(const void *)bytes length:(NSUInteger)length characterCase:(XZCharacterCase)characterCase NS_SWIFT_NAME(init(hexadecimalEncoded:length:characterCase:));

/// 将 NSData 格式的二进制数据构造成十六进制的字符串。
/// @param data NSData对象。
/// @param characterCase 十六进制字母的大小写格式。
+ (NSString *)xz_stringHexadecimalEncodedWithData:(NSData *)data characterCase:(XZCharacterCase)characterCase NS_SWIFT_NAME(init(hexadecimalEncoded:characterCase:));

@end

NS_ASSUME_NONNULL_END
