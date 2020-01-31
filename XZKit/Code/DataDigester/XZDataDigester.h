//
//  XZDataDigester.h
//  XZKit
//
//  Created by M. X. Z. on 16/7/28.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//
//  Requires XZKitConstants

#import <Foundation/Foundation.h>
#import <XZKit/XZKit+Constants.h>

NS_ASSUME_NONNULL_BEGIN

/// 所有支持的数据摘要算法。
typedef NS_ENUM(NSInteger, XZDataDigesterAlgorithm) {
    XZDataDigesterAlgorithmMD2    NS_SWIFT_NAME(MD2) = 1,
    XZDataDigesterAlgorithmMD4    NS_SWIFT_NAME(MD4),
    XZDataDigesterAlgorithmMD5    NS_SWIFT_NAME(MD5),
    XZDataDigesterAlgorithmSHA1   NS_SWIFT_NAME(SHA1),
    XZDataDigesterAlgorithmSHA224 NS_SWIFT_NAME(SHA224),
    XZDataDigesterAlgorithmSHA256 NS_SWIFT_NAME(SHA256),
    XZDataDigesterAlgorithmSHA384 NS_SWIFT_NAME(SHA384),
    XZDataDigesterAlgorithmSHA512 NS_SWIFT_NAME(SHA512)
} NS_SWIFT_NAME(DataDigester.Algorithm);

/// XZDataDigester 提供了计算数据摘要的功能。
NS_SWIFT_NAME(DataDigester)
@interface XZDataDigester : NSObject

/// 便利方法，对一个数据直接进行信息摘要，适合对单数据进行信息摘要。
///
/// @param data 待摘要的数据。
/// @param algorithm 算法。
/// @return 摘要数据。
+ (NSData *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm;

/// 便利方法，以十六进制字符串的形式返回数据的摘要。
///
/// @param data 待摘要的数据。
/// @param algorithm 算法。
/// @param uppercase 十六进制是否大些。
/// @return 十六进制的字符串形式的数据摘要。
+ (NSString *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm hexadecimalEncoding:(XZCharacterCase)uppercase;

/// 当前 XZDataDigester 的算法。
@property (nonatomic, readonly) XZDataDigesterAlgorithm algorithm;

/// XZDataDigester 禁止继承。
- (instancetype)init NS_UNAVAILABLE;

/// 构造 XZDataDigester 的便利方法。
///
/// @param algorithm 算法。
/// @return XZDataDigester 对象。
+ (XZDataDigester *)digesterWithAlgorithm:(XZDataDigesterAlgorithm)algorithm NS_SWIFT_NAME(init(_:));

/// 将数据添加到摘要计算中。
/// @note 此方法被调用多次。
///
/// @param data 将 NSData 数据添加到摘要器中进行摘要。
- (void)digest:(NSData *)data;

/// 结束摘要计算，将当前已添加到摘要计算器中的数据的摘要以指定的形式输出。
///
/// @param block 构造摘要数据类型的 block 。
/// @return block 的返回值。
- (nullable id)finishByUsingBlock:(id _Nullable (^)(const unsigned char * _Nonnull output, NSUInteger length))block;

/// 获取当前已添加数据的摘要信息。
///
/// @return 数据的摘要。
- (nullable NSData *)data;

/// 以十六进制的形式返回当前摘要信息。
///
/// @return 十六进制形式的摘要信息。
- (nullable NSString *)hexadecimalEncodedString:(XZCharacterCase)characterCase;

@end

NS_ASSUME_NONNULL_END




