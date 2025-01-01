//
//  NSData+XZKit.h
//  XZExtensions
//
//  Created by 徐臻 on 2024/6/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 十六进制编码。
typedef NS_ENUM(NSUInteger, XZHexEncoding) {
    /// 小写字母十六进制编码。
    XZLowercaseHexEncoding NS_SWIFT_NAME(lowercase),
    /// 大写字母十六进制编码。
    XZUppercaseHexEncoding NS_SWIFT_NAME(uppercase),
};

@interface NSData (XZKit)

/// 解码十六进制编码的字符串为二进制数据。
/// @discussion 如果字符串不合法，转换会提前结束，返回已完成部分的结果。
/// @discussion 十六进制编码，将一个二进制字节用两个十六进制字符表示，因此十六进制编码字符串的长度为必然是偶数，所以本方法会舍弃最后一个在奇数位上的字符，不论它是否为合法的十六进制编码字符。
/// @param hexEncodedString 十六进制编码字符串
/// @return NSData
+ (instancetype)xz_dataWithHexEncodedString:(NSString *)hexEncodedString NS_SWIFT_NAME(init(hexEncodedString:));

/// 对当前二进制数据进行十六进制编码。
/// @discussion 编码将完全反映数据的二进制形式，这可能与某些规则不同，例如某些Unicode编码方式，虽然也是十六进制编码，但是可能会添加额外的间隔符来分割字符，也可能会省略前置为 0 的空位。
/// @param hexEncoding 大写或小写
/// @return 十六进制编码字符串
- (NSString *)xz_hexEncodedString:(XZHexEncoding)hexEncoding NS_SWIFT_NAME(hexEncodedString(_:));

/// 以十六进制编码小写格式，对当前数据进行编码。
@property (nonatomic, readonly) NSString *xz_hexEncodedString NS_SWIFT_NAME(hexEncodedString);

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
FOUNDATION_EXPORT BOOL XZHexDecoder(unichar character, UInt8 * const byte) __attribute__((enable_if(byte, "byte can not be NULL")));


@interface NSData (XZJSON)

/// 将对象 object 转换为 JSON 二进制数据。
/// @param object 可转换为 JSON 的对象
/// @param options 序列化选项
+ (nullable instancetype)xz_dataWithJSONObject:(nullable id)object options:(NSJSONWritingOptions)options NS_SWIFT_NAME(init(JSONObject:options:));

/// 将对象 object 转换为 JSON 数据。
/// @note 使用 NSJSONWritingFragmentsAllowed 选项。
/// @param object 可转换为 JSON 的对象
+ (nullable instancetype)xz_dataWithJSONObject:(nullable id)object NS_SWIFT_NAME(init(JSONObject:));

@end

NS_ASSUME_NONNULL_END
