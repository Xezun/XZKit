//
//  XZDataDigester.h
//  XZKit
//
//  Created by M. X. Z. on 16/7/28.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//
//  Requires XZKitDefines

#import <Foundation/Foundation.h>
#import <XZKit/XZCharacterCase.h>

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
+ (NSString *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm hexEncoding:(XZCharacterCase)uppercase;

/// 当前 XZDataDigester 的算法。
@property (nonatomic, readonly) XZDataDigesterAlgorithm algorithm;
/// 摘要的长度。
@property (nonatomic, readonly) NSUInteger length;

/// XZDataDigester 禁止继承。
- (instancetype)init NS_UNAVAILABLE;

/// 构造 XZDataDigester 的便利方法。
///
/// @param algorithm 算法。
/// @return XZDataDigester 对象。
+ (XZDataDigester *)digesterWithAlgorithm:(XZDataDigesterAlgorithm)algorithm NS_SWIFT_NAME(init(_:));

/// 将二进制数据进行摘要计算。
/// @param bytes 二进制数据
/// @param length 数据的长度
- (void)update:(const void *)bytes length:(NSUInteger)length;

/// 对 NSData 二进制数据进行摘要计算。
/// @note 此方法被调用多次。
/// @param data NSData
- (void)update:(NSData *)data;

/// 摘要结果。
/// @note 获取摘要数据，即表示当前摘要计算结束；再次开始摘要计算前，此属性可获取多次。
/// @return 数据摘要的二进制形式
@property (nonatomic, readonly) void *digest NS_RETURNS_INNER_POINTER;

/// 获取已进行摘要计算的数据的摘要。
/// @note 获取摘要数据，即表示当前摘要计算结束；再次开始摘要计算前，此属性可获取多次。
@property (nonatomic, readonly) NSData *digestData;

/// 获取已进行摘要计算的数据的摘要，十六进制编码形式。
/// @note 获取摘要数据，即表示当前摘要计算结束；再次开始摘要计算前，此属性可获取多次。
/// @param characterCase 十六进制编码的大小写
- (NSString *)digestStringWithCharacterCase:(XZCharacterCase)characterCase;

/// 获取已进行摘要计算的数据的摘要，小写字母形式。
/// @note 获取摘要数据，即表示当前摘要计算结束；再次开始摘要计算前，此属性可获取多次。
@property (nonatomic, readonly) NSString *digestString;

@end

NS_ASSUME_NONNULL_END




