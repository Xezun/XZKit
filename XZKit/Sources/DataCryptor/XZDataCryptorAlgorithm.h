//
//  XZDataCryptorAlgorithm.h
//  XZKit
//
//  Created by Xezun on 2021/2/15.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>

NS_ASSUME_NONNULL_BEGIN

@class XZDataCryptor, XZDataCryptorAlgorithm;

/// 加密/解密算法。因为算法与密钥相关，虽然 XZDataCryptorAlgorithm 并没有显示的要求密钥的长度，
/// 但是不同算法的构造方法将自动对密钥进行对齐（不满足长度补二进制0，超过截断）。
NS_SWIFT_NAME(XZDataCryptor.Algorithm)
@interface XZDataCryptorAlgorithm : NSObject

@property (nonatomic, readonly) CCAlgorithm rawValue;

/// 加密/解密的密钥，密钥自动修正，可能与实际输入的不同。
@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy, nullable) NSString *vector;

/// 算法加密/解密块的大小。
@property (nonatomic, readonly) size_t blockSize;
/// 仅供参考，XZCryptor 核心 CCCryptor 所需的最小内存。
@property (nonatomic, readonly) size_t contextSize;

/// 加密轮数。默认 0，使用算法默认轮数。
@property (nonatomic) NSInteger numberOfRounds;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// AES 算法，密钥长度 16/24/32 字节，块大小 16 字节。
/// @note 根据密钥长度自动确定算法 AES128/AES192/AES256 。
/// @note 密钥长度 <= 16 时，使用 AES128 算法。
/// @note 密钥长度 <= 24 时，使用 AES192 算法。
/// @note 密钥长度  > 24 时，使用 AES256 算法。
+ (XZDataCryptorAlgorithm *)AES:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(AES(key:vector:));

/// DES 算法，密钥长度 8 字节，块大小 8 字节。
/// @note 如果密钥长度不是 8，则默认为 0 ，超出截取，不足补 \0 。
+ (XZDataCryptorAlgorithm *)DES:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(DES(key:vector:));

/// 3DES 算法，密钥长度 24 字节，块大小 8 字节。
/// @note 如果密钥长度不是 24，则默认为 24 ，超出截取，不足补 \0 。
+ (XZDataCryptorAlgorithm *)DES3:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(DES3(key:vector:));

/// CAST 算法，密钥长度 5-16 字节，块大小 8 字节。
/// @note 如果密钥长度不足 5，则末尾补 \0 到 5 位，如果大于 16，将截取前 16 位。
+ (XZDataCryptorAlgorithm *)CAST:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(CAST(key:vector:));

/// RC4 算法，密钥长度 1-512 字节，块大小 8 字节。
/// @note 如果密钥长度不足 1，则末尾补 \0 到 1 位，如果大于 512，将截取前 512 位。
+ (XZDataCryptorAlgorithm *)RC4:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(RC4(key:vector:));

/// RC2 算法，密钥长度 1-128 字节，块大小 8 字节。
/// @note 如果密钥长度不足 1，则末尾补 \0 到 1 位，如果大于 128，将截取前 128 位。
+ (XZDataCryptorAlgorithm *)RC2:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(RC2(key:vector:));

/// Blowfish 算法，密钥长度 8-56 字节，块大小 8 字节。
///
/// @note 如果密钥长度不足 8，则末尾补 \0 到 8 位，如果大于 56，将截取前 56 位。
+ (XZDataCryptorAlgorithm *)Blowfish:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(Blowfish(key:vector:));

/// 同一构造方法创建的 XZDataCryptorAlgorithm 使用此方法相同。
/// @note 此方法仅判断 algorithm 属性是否相同。
- (BOOL)isEqual:(nullable id)object;

/// 算法名称。
- (NSString *)description;

@end

/// 描述 XZDataCryptor 执行的行为。
///
/// - XZDataCryptorOperationEncrypt: 加密操作。
/// - XZDataCryptorOperationDecrypt: 解密操作。
typedef NS_ENUM(CCOperation, XZDataCryptorOperation) {
    /// 加密操作。
    XZDataCryptorOperationEncrypt = kCCEncrypt,
    /// 解密操作。
    XZDataCryptorOperationDecrypt = kCCDecrypt
} NS_SWIFT_NAME(XZDataCryptor.Operation);

/// 当使用块加密方式时，数据可能不会正好填满块，此枚举值描述了 XZDataCryptor 填充数据的方式。
///
/// - XZDataCryptorNoPadding: 不填充。
/// - XZDataCryptorPKCS7Padding: PKCS7 填充（数据差n位就填充n到最后一块，块数据正好表示差一个块）。
typedef NS_ENUM(CCPadding, XZDataCryptorPadding) {
    /// 无填充。
    XZDataCryptorNoPadding    NS_SWIFT_NAME(none)  = ccNoPadding,
    /// PKCS7 方式填充。
    XZDataCryptorPKCS7Padding NS_SWIFT_NAME(PKCS7) = ccPKCS7Padding
} NS_SWIFT_NAME(XZDataCryptor.Padding);

/// 加密/解密模式。
/// @note 对称加密的模式决定了是否需要额外的参数：初始化向量或可调整值。
/// @note 不同模式提供了不同的构造方法，
/// @note 在加/解密时，实际参与计算对 vector/tweak 的长度与块大小相同，如果不足补 `\0` 。
typedef NS_ENUM(CCMode, XZDataCryptorMode) {
    /// ECB 电码本加密模式，将整个明文分成若干段相同的小段，然后对每一小段进行加密。
    /// @note 不建议使用。
    /// @note 不支持 vector 初始化向量。
    XZDataCryptorModeECB = kCCModeECB,
    /// CBC 密码分组链接模式。先将明文切分成若干小段，然后每一小段与初始块或者上一段的密文段进行异或运算后，再与密钥进行加密。
    XZDataCryptorModeCBC = kCCModeCBC,
    /// CFB 密码反馈模式。
    XZDataCryptorModeCFB = kCCModeCFB,
    /// CTR 计算器模式。计算器模式不常见，在CTR模式中， 有一个自增的算子，这个算子用密钥加密之后的输出和明文异或的
    /// 结果得到密文，相当于一次一密。这种加密方式简单快速，安全可靠，而且可以并行加密，但是在计算器不能维持很长的情
    /// 况下，密钥只能使用一次。
    XZDataCryptorModeCTR = kCCModeCTR,
    /// OFB 输出反馈模式。
    XZDataCryptorModeOFB = kCCModeOFB,
    /// RC4 模式。
    /// @note 不支持 vector 初始化向量。
    XZDataCryptorModeRC4 = kCCModeRC4,
    /// CFB8 模式。
    XZDataCryptorModeCFB8 = kCCModeCFB8
} NS_SWIFT_NAME(XZDataCryptor.Mode);

NS_ASSUME_NONNULL_END
