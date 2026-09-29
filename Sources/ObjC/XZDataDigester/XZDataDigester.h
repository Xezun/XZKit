//
//  XZDataDigester.h
//  XZKit
//
//  Created by M. X. Z. on 16/7/28.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//
//  Requires XZKitDefines

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/NSData+XZKit.h>
#import <XZKit/NSData+XZDataDigester.h>
#import <XZKit/NSString+XZDataDigester.h>
#else
#import "NSData+XZKit.h"
#import "NSData+XZDataDigester.h"
#import "NSString+XZDataDigester.h"
#endif

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const XZDataDigesterErrorDomain;

/// 所有支持的数据摘要算法。算法枚举值会用于数组索引，不可修改顺序。
///
/// @warning MD2、MD4、MD5 已不具备抗碰撞性，SHA1 也已不推荐用于安全场景；
///          这四种算法仅用于兼容历史数据的完整性校验，禁止用于签名、口令存储等安全场景。
///          安全场景请选用 SHA-2 系列（SHA224/SHA256/SHA384/SHA512）。
typedef NS_ENUM(NSUInteger, XZDataDigesterAlgorithm) {
    /// @warning 已破解，仅用于兼容历史数据校验。
    XZDataDigesterAlgorithmMD2    NS_SWIFT_NAME(MD2) = 0,
    /// @warning 已破解，仅用于兼容历史数据校验。
    XZDataDigesterAlgorithmMD4    NS_SWIFT_NAME(MD4),
    /// @warning 已不具备抗碰撞性，禁止用于安全场景，仅用于兼容历史数据校验。
    XZDataDigesterAlgorithmMD5    NS_SWIFT_NAME(MD5),
    /// @warning 已不推荐用于安全场景，仅用于兼容历史数据校验。
    XZDataDigesterAlgorithmSHA1   NS_SWIFT_NAME(SHA1),
    XZDataDigesterAlgorithmSHA224 NS_SWIFT_NAME(SHA224),
    XZDataDigesterAlgorithmSHA256 NS_SWIFT_NAME(SHA256),
    XZDataDigesterAlgorithmSHA384 NS_SWIFT_NAME(SHA384),
    XZDataDigesterAlgorithmSHA512 NS_SWIFT_NAME(SHA512),
    /// 未知/不受支持的算法。仅用于标识非法取值，传入计算接口会失败并通过 error 返回错误。
    XZDataDigesterAlgorithmUnknown  NS_SWIFT_NAME(unknown),
} NS_SWIFT_NAME(XZDataDigester.Algorithm);

/// XZDataDigester 提供了计算数据摘要的功能。
/// @note 实例内部持有可变的摘要上下文，非线程安全；同一实例不可在多个线程上并发调用，
///       多线程场景下请为每个线程使用独立实例，或自行加锁。
/// @note 所有计算接口失败时均返回 NO/nil，并通过 error 出参返回
///       `XZDataDigesterErrorDomain` 域的错误，错误码为对应的 POSIX 码
///       （EINVAL：非法参数或算法；ENOMEM：内存分配失败；ENOTSUP：不支持的时序操作）。
@interface XZDataDigester : NSObject

/// 便利方法，对一个数据直接进行信息摘要，适合对单数据进行信息摘要。
///
/// @note 一次性接口直调 CommonCrypto 单函数，性能更优，适合小数据；
///       数据超过 4GiB 时显式失败（错误码 ENOTSUP），大数据请改用流式实例接口。
///
/// @param data 待摘要的数据。
/// @param algorithm 算法。
/// @param error 失败时返回错误信息。
/// @return 摘要数据；算法不受支持、数据超限或摘要计算失败时返回 nil。
+ (nullable NSData *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 便利方法，以十六进制字符串的形式返回数据的摘要。
///
/// @note 一次性接口直调 CommonCrypto 单函数，数据超过 4GiB 时显式失败（错误码 ENOTSUP）。
///
/// @param data 待摘要的数据。
/// @param algorithm 算法。
/// @param hexEncoding 十六进制字母是否大写。
/// @param error 失败时返回错误信息。
/// @return 十六进制字符串形式的数据摘要；算法不受支持、数据超限或摘要计算失败时返回 nil。
+ (nullable NSString *)digest:(NSData *)data algorithm:(XZDataDigesterAlgorithm)algorithm hexEncoding:(XZHexEncoding)hexEncoding error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 当前 XZDataDigester 的算法。
@property (nonatomic, readonly) XZDataDigesterAlgorithm algorithm;

/// 摘要的长度。
@property (nonatomic, readonly) NSUInteger length;

/// XZDataDigester 禁止直接初始化，请通过 +digesterWithAlgorithm:error: 创建实例。
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 构造 XZDataDigester 的便利方法。
///
/// @param algorithm 算法。
/// @param error 失败时返回错误信息。
/// @return XZDataDigester 对象；算法不受支持或初始化失败时返回 nil。
+ (nullable instancetype)digesterWithAlgorithm:(XZDataDigesterAlgorithm)algorithm error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(init(_:));

/// 恢复摘要计算环境，以便开始新的摘要计算过程。此方法可重复调用。
/// @note 摘要过程中调用此方法，已喂入的数据将被丢弃。
/// @param error 失败时返回错误信息。
/// @return 操作是否成功。
- (BOOL)reset:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 将二进制数据进行摘要计算。
/// @note 必须在 `-final` 之后先调用 `-reset` 才能继续摘要计算，否则喂入数据失败
///       （返回 NO 且错误码为 ENOTSUP），数据不会被静默并入摘要。
/// @param bytes 二进制数据
/// @param length 数据的长度
/// @param error 失败时返回错误信息。
/// @return 数据是否成功添加到摘要计算中。
- (BOOL)digestBytes:(const void *)bytes length:(NSUInteger)length error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(digest(_:length:));

/// 将 NSData 二进制数据添加到摘要计算中。
/// @note 此方法可被调用多次。
/// @note 必须在 `-final` 之后先调用 `-reset` 才能继续摘要计算，否则喂入数据失败
///       （返回 NO 且错误码为 ENOTSUP），数据不会被静默并入摘要。
/// @param data NSData
/// @param error 失败时返回错误信息。
/// @return 数据是否成功添加到摘要计算中。
- (BOOL)digestData:(NSData *)data error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(digest(_:));

/// 将字符串指定编码的二进制形式，添加到摘要计算中。
/// @note 此方法可被调用多次。
/// @note 必须在 `-final` 之后先调用 `-reset` 才能继续摘要计算，否则喂入数据失败
///       （返回 NO 且错误码为 ENOTSUP），数据不会被静默并入摘要。
/// @note 字符串无法转换为指定编码时失败（返回 NO 且错误码为 EINVAL），不会静默跳过该数据。
/// @param string 字符串
/// @param encoding 字符串编码
/// @param error 失败时返回错误信息。
/// @return 数据是否成功添加到摘要计算中。
- (BOOL)digestString:(NSString *)string encoding:(NSStringEncoding)encoding error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(digest(_:encoding:));

/// 将字符串 UTF8 编码的二进制形式，添加到摘要计算中。
/// @note 此方法可被调用多次。
/// @note 必须在 `-final` 之后先调用 `-reset` 才能继续摘要计算，否则喂入数据失败
///       （返回 NO 且错误码为 ENOTSUP），数据不会被静默并入摘要。
/// @param string 字符串
/// @param error 失败时返回错误信息。
/// @return 数据是否成功添加到摘要计算中。
- (BOOL)digestString:(NSString *)string error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(digest(_:));

/// 获取已进行摘要计算的数据的摘要。
/// @note 获取摘要即表示当前摘要计算结束；重复调用返回同一份摘要结果。
/// @note 结束（-final）之后必须调用 -reset 才能重新开始新的摘要计算，
///       否则数据摘要方法失败（返回 NO 且错误码为 ENOTSUP）。
/// @param error 失败时返回错误信息。
/// @return 摘要数据；摘要计算结束失败时返回 nil。
- (nullable NSData *)final:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end

NS_ASSUME_NONNULL_END




