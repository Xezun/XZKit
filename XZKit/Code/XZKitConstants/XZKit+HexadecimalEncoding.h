//
//  XZKit+NSString.h
//  XZKit
//
//  Created by 徐臻 on 2019/3/30.
//  Copyright © 2019 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZKitConstants.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HexadecimalEncoding)

/// 将字节内容转换成十六进制的字符串。
+ (NSString *)xz_hexadecimalEncodedStringWithBytes:(const void *)bytes length:(NSUInteger)length characterCase:(XZCharacterCase)characterCase NS_SWIFT_NAME(init(hexadecimalEncoding:length:characterCase:));
/// 将字节内容转换成十六进制的字符串，默认使用大写。
+ (NSString *)xz_hexadecimalEncodedStringWithBytes:(const void *)bytes length:(NSUInteger)length NS_SWIFT_NAME(init(hexadecimalEncoding:length:));

@end

@interface NSData (HexadecimalEncoding)

/// 用十六进制的数字字符串构造 NSData 对象。
///
/// @note 字符串长度是偶数。
/// @note 为了提高性能，请确保字符串且不能包含除 /0-9A-Fa-f/ 以外的字符。
///
/// @param hexadecimalEncodedString 十六进制数字的字符串。
/// @return NSData
+ (NSData *)xz_dataWithHexadecimalEncodedString:(NSString *)hexadecimalEncodedString NS_SWIFT_NAME(init(hexadecimalEncoded:));

/// 按指定大小写形式，返回数据的十六进制字符串形式。
///
/// @param characterCase 大写或小写。
/// @return 数据的十进制形式。
- (nullable NSString *)xz_hexadecimalEncodedStringWithCharacterCase:(XZCharacterCase)characterCase NS_SWIFT_NAME(hexadecimalEncodedString(with:));

/// 返回数据的十六进制字符串形式，默认大写字母。
@property (nonatomic, readonly) NSString *xz_hexadecimalEncodedString NS_SWIFT_NAME(hexadecimalEncodedString);

@end

NS_ASSUME_NONNULL_END
