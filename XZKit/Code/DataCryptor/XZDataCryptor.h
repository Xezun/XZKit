//
//  XZDataCryptor.h
//  XZKit
//
//  Created by Xezun on 2018/2/6.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 描述 XZDataCryptor 执行的行为。
///
/// - XZDataCryptorOperationEncrypt: 加密操作。
/// - XZDataCryptorOperationDecrypt: 解密操作。
typedef NS_ENUM(NSInteger, XZDataCryptorOperation) {
    /// 加密操作。
    XZDataCryptorOperationEncrypt,
    /// 解密操作。
    XZDataCryptorOperationDecrypt
} NS_SWIFT_NAME(DataCryptor.Operation);

/// 当使用块加密方式时，数据可能不会正好填满块，此枚举值描述了 XZDataCryptor 填充数据的方式。
///
/// - XZDataCryptorNoPadding: 不填充。
/// - XZDataCryptorPKCS7Padding: PKCS7 填充（数据差n位就填充n到最后一块，块数据正好表示差一个块）。
typedef NS_ENUM(NSInteger, XZDataCryptorPadding) {
    /// 无填充。
    XZDataCryptorNoPadding NS_SWIFT_NAME(none),
    /// PKCS7 方式填充。
    XZDataCryptorPKCS7Padding NS_SWIFT_NAME(PKCS7)
} NS_SWIFT_NAME(DataCryptor.Padding);

@class XZDataCryptorMode, XZDataCryptorAlgorithm;



NS_ASSUME_NONNULL_BEGIN

/// XZDataCryptor 提供了数据的对称加密功能，封装了 CommonCrypto 框架。
/// @note XZDataCryptor 对象设计为大型数据加密，小数据（可单次处理）推荐使用静态方法。
NS_SWIFT_NAME(DataCryptor) @interface XZDataCryptor: NSObject

/// 加密或解密。
@property (nonatomic, readonly) XZDataCryptorOperation operation;
/// 执行加密或解密的算法。
@property (nonatomic, copy, readonly) XZDataCryptorAlgorithm *algorithm;
/// 执行加密或解密的模式。
@property (nonatomic, strong, readonly) XZDataCryptorMode *mode;
/// 数据不足整数块时的填充模式。
@property (nonatomic, readonly) XZDataCryptorPadding padding;

- (instancetype)init NS_UNAVAILABLE;
+ (nullable instancetype)cryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(init(algorithm:operation:mode:padding:));

+ (nullable instancetype)encryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(init(encrypto:mode:padding:));
+ (nullable instancetype)decryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(init(decrypto:mode:padding:));
+ (nullable instancetype)AESCryptorWithOperation:(XZDataCryptorOperation)operation key:(NSString *)key vector:(nullable NSString *)vector error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(init(AES:key:vector:));
+ (nullable instancetype)DESCryptorWithOperation:(XZDataCryptorOperation)operation key:(NSString *)key vector:(nullable NSString *)vector error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(init(DES:key:vector:));

/// 单数据加密/解密数据的便利方法。
///
/// @note 当数据较小可以单独处理时，使用此方法要比使用实例化 XZDataCryptor 对象效率更高。
/// @note 此方法只支持使用 ECB 、CBC（noPadding/PKCS7Padding）模式。
+ (nullable NSData *)crypto:(NSData *)data algorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 对数据执行加密/解密操作。本方法可调用多次，比如将较大的数据分块读入内存，分别进行加密解密计算。
///
/// @note 虽然可以分块计算，但是不一定能使用多线程技术，具体要看加密解密的算法和计算模式是否支持。
/// @note 对于分组密码及块加密算法，需要调用 -finish: 方法补齐块数据才能最终完成加密计算。
///
/// @param data 待加密/解密的数据，nil 表示加解密结束，获取最终的数据（必须调用 reset 方法才能开始新的加解密）。
/// @param error 执行加密或解密时发生发生的错误输出。
/// @return （已成功执行）已加密/解密后的数据。
- (nullable NSData *)crypto:(NSData *)data error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(crypto(_:));

/// 结束加解密计算，并获取最终的补齐数据。
/// @note 对于流密码、无补齐模式的加解密来说，不需要调用此方法。
///
/// @param error 错误输出。
- (nullable NSData *)finish:(NSError *__autoreleasing  _Nullable *)error NS_SWIFT_NAME(finish());

/// 不改变加解密参数的情况下，重置当前 XZDataCryptor 对象，以开始新的加解密流程。
/// @note 对于 CBC 模式，使用 -resetWithVector:error 是更经济的方法。
- (BOOL)reset:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(reset());
/// 如果当前为 CBC 模式，在密码没有改变的情况下，通过此方法重置 XZDataCryptor 并设置新的初始化向量。
/// @note 如果当前不为 CBC 模式，本方将调用 -reset 方法，vector 参数将被忽略。
///
/// @param vector 初始化向量，如果为 nil 表示不修改初始化向量。
/// @param error 错误信息。
- (BOOL)resetWithVector:(nullable NSString *)vector error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(reset(vector:error:));
/// 以新的加解密参数重置 XZDataCryptor 对象，以开始新的加解密流程。
- (BOOL)resetWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(reset(algorithm:operation:mode:padding:));

/// 使用 block 函数执行加解密操作。此方法的目的在于，在高密集性的业务逻辑中，为加解密操作提供几乎与原生一样的性能。
///
/// 在 block 函数的三个参数中：
///
/// index: 已执行 block 函数的次数。
///
/// XZCryptorLength: 为输出数据开辟内存时，可通过此方法获取数据在加解密后的大小。
///
/// XZCryptorUpdate: 执行加解密的方法，需要开发者分配输出数据的所使用的内存；
///                    对于某些算法而言，如果 dataIn 如果为 NULL 则表示执行最终计算；
///                    此函数返回 NO 时，表示数据处理过程出现错误，错误将在 error 参数中输出。
///
/// XZCryptorFinish: 获取加密最终数据的方法。
///
/// @param block 执行加解密流程的 block 函数；如果 block 返回了 YES ，那么该 block 会再次被调用，且其 index 参数自增。
/// @param error 如果执行过程发生错误，方法会退出，并通过此参数输出错误。
/// @return 返回 YES 表示执行过程没有错误产生。
- (BOOL)cryptoByUsingBlock:(BOOL (^)(NSInteger index, size_t (^XZCryptorLength)(size_t dataInLength), BOOL (^XZCryptorUpdate)(void *dataIn, size_t dataInLength, void *buffer, size_t bufferLength, size_t *dataOutLength), BOOL (^XZCryptorFinish)(void *buffer, size_t bufferLength, size_t *dataOutLength)))block error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(crypto(using:));

@end


@interface XZDataCryptor (XZExtendedDataCryptor)

/// 一次性加密数据的便利方法。
+ (nullable NSData *)encrypt:(NSData *)data usingAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable * _Nullable)error NS_SWIFT_NAME(encrypt(_:using:mode:padding:));
/// 一次性解密数据的便利方法。
+ (nullable NSData *)decrypt:(NSData *)data usingAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable * _Nullable)error NS_SWIFT_NAME(decrypt(_:using:mode:padding:));
/// AES 加密/解密的便利方法。
+ (nullable NSData *)AES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSString *)key mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(AES(_:operation:key:mode:padding:));
/// DES 加密/解密的便利方法。
+ (nullable NSData *)DES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSString *)key mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(DES(_:operation:key:mode:padding:));

@end


/// 加密/解密模式。
/// @note 对称加密的模式决定了是否需要额外的参数：初始化向量或可调整值。
/// @note 不同模式提供了不同的构造方法，
/// @note 在加/解密时，实际参与计算对 vector/tweak 的长度与块大小相同，如果不足补 `\0` 。
NS_SWIFT_NAME(DataCryptor.Mode) @interface XZDataCryptorMode: NSObject

/// 加密/解密模式的原始值。
@property (nonatomic, readonly) NSInteger rawValue;

/// 初始化向量，只有在部分模式下可用。
@property (nonatomic, copy, readonly, nullable) NSString *vector;

/// AES-XTS 模式下的可调整值。
@property (nonatomic, copy, readonly, nullable) NSString *tweak;

- (instancetype)init NS_UNAVAILABLE;

/// ECB 电码本加密模式，将整个明文分成若干段相同的小段，然后对每一小段进行加密。
/// @note 不建议使用。
@property (class, nonatomic, readonly) XZDataCryptorMode *ECBMode NS_SWIFT_NAME(ECB);

- (nullable NSString *)vectorForAlgorithm:(XZDataCryptorAlgorithm *)algorithm;
- (nullable NSString *)tweakForAlgorithm:(XZDataCryptorAlgorithm *)algorithm;

/// CBC 密码分组链接模式。先将明文切分成若干小段，然后每一小段与初始块或者上一段的密文段进行异或运算后，再与密钥进行加密。
///
///
/// @note 向量长度一般与块大小相同，请参考 XZDataCryptorAlgorithm 中的说明。
/// @note 初始化向量在使用时，如果长度小于块大小，末尾自动补 \0 。
///
/// @param vector 初始化向量。
/// @return 加密/解密模式。
+ (XZDataCryptorMode *)CBCModeWithVector:(nullable NSString *)vector NS_SWIFT_NAME(CBC(vector:));

/// CFB 密码反馈模式。
///
/// @note 向量长度一般与块大小相同，请参考 XZDataCryptorAlgorithm 中的说明。
/// @note 初始化向量在使用时，如果长度小于块大小，末尾自动补 \0 。
///
/// @param vector 初始化向量。
/// @return 加密/解密模式。
+ (XZDataCryptorMode *)CFBModeWithVector:(nullable NSString *)vector NS_SWIFT_NAME(CFB(vector:));

/// CTR 计算器模式。计算器模式不常见，在CTR模式中， 有一个自增的算子，这个算子用密钥加密之后的输出和明文异或的
/// 结果得到密文，相当于一次一密。这种加密方式简单快速，安全可靠，而且可以并行加密，但是在计算器不能维持很长的情
/// 况下，密钥只能使用一次。
///
/// @note 向量长度一般与块大小相同，请参考 XZDataCryptorAlgorithm 中的说明。
/// @note 初始化向量在使用时，如果长度小于块大小，末尾自动补 \0 。
///
/// @param vector 初始化向量。
/// @return 加密/解密模式。
+ (XZDataCryptorMode *)CTRModeWithVector:(nullable NSString *)vector NS_SWIFT_NAME(CTR(vector:));

/// OFB 输出反馈模式。
///
/// @note 向量长度一般与块大小相同，请参考 XZDataCryptorAlgorithm 中的说明。
/// @note 初始化向量在使用时，如果长度小于块大小，末尾自动补 \0 。
///
/// @param vector 初始化向量。
/// @return 加密/解密模式。
+ (XZDataCryptorMode *)OFBModeWithVector:(nullable NSString *)vector NS_SWIFT_NAME(OFB(vector:));

/// RC4 模式。
@property (class, nonatomic, readonly) XZDataCryptorMode *RC4Mode NS_SWIFT_NAME(RC4);

/// CFB8 模式。
///
/// @note 向量长度一般与块大小相同，请参考 XZDataCryptorAlgorithm 中的说明。
/// @note 初始化向量在使用时，如果长度小于块大小，末尾自动补 \0 。
///
/// @param vector 初始化向量。
/// @return 加密/解密模式。
+ (XZDataCryptorMode *)CFB8ModeWithVector:(nullable NSString *)vector NS_SWIFT_NAME(CFB8(vector:));

/// 相同的构造方法创建的 XZDataCryptorMode 都相等。
/// @note 此方法返回 YES 时，vector 和 tweak 属性未必相同。
- (BOOL)isEqual:(nullable id)object;

/// 算法名称。
- (NSString *)description;

@end


/// 加密/解密算法。因为算法与密钥相关，虽然 XZDataCryptorAlgorithm 并没有显示的要求密钥的长度，但是不同算法的构造方法将自动对密钥进行对齐（不满足长度补二进制0，超过截断）。
NS_SWIFT_NAME(DataCryptor.Algorithm) @interface XZDataCryptorAlgorithm : NSObject

@property (nonatomic, readonly) NSInteger rawValue;
/// 算法加密/解密块的大小。
@property (nonatomic, readonly) size_t blockSize;
/// 仅供参考，XZCryptor 核心 CCCryptor 所需的最小内存。
@property (nonatomic, readonly) size_t contextSize;
/// 加密/解密的密钥，密钥自动修正，可能与实际输入的不同。
@property (nonatomic, readonly) NSString *key;
/// 加密轮数。默认 0，使用算法默认轮数。
@property (nonatomic, readonly) int numberOfRounds;

- (instancetype)init NS_UNAVAILABLE;

/// AES 算法，密钥长度 16/24/32 字节，块大小 16 字节。
///
/// @note 根据密钥长度自动确定算法 AES128/AES192/AES256 。
/// @note 密钥长度 <= 16 时，使用 AES128 算法。
/// @note 密钥长度 <= 24 时，使用 AES192 算法。
/// @note 密钥长度  > 24 时，使用 AES256 算法。
///
/// @param key 密钥字符串。
/// @return XZDataCryptorAlgorithm 对象。
+ (XZDataCryptorAlgorithm *)AESAlgorithmWithKey:(NSString *)key NS_SWIFT_NAME(AES(key:));
+ (XZDataCryptorAlgorithm *)AESAlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds NS_SWIFT_NAME(AES(key:numberOfRounds:));

/// DES 算法，密钥长度 8 字节，块大小 8 字节。
///
/// @note 如果密钥长度不是 8，则默认为 0 ，超出截取，不足补 \0 。
///
/// @param key 密钥字符串。
/// @return XZDataCryptorAlgorithm 对象
+ (XZDataCryptorAlgorithm *)DESAlgorithmWithKey:(NSString *)key NS_SWIFT_NAME(DES(key:));
+ (XZDataCryptorAlgorithm *)DESAlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds NS_SWIFT_NAME(DES(DES:numberOfRounds:));

/// 3DES 算法，密钥长度 24 字节，块大小 8 字节。
///
/// @note 如果密钥长度不是 24，则默认为 24 ，超出截取，不足补 \0 。
///
/// @param key 密钥字符串。
/// @return XZDataCryptorAlgorithm 对象
+ (XZDataCryptorAlgorithm *)TripleDESAlgorithmWithKey:(NSString *)key NS_SWIFT_NAME(TripleDES(key:));
+ (XZDataCryptorAlgorithm *)TripleDESAlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds NS_SWIFT_NAME(TripleDES(key:numberOfRounds:));

/// CAST 算法，密钥长度 5-16 字节，块大小 8 字节。
///
/// @note 如果密钥长度不足 5，则末尾补 \0 到 5 位，如果大于 16，将截取前 16 位。
///
/// @param key 密钥字符串。
/// @return XZDataCryptorAlgorithm 对象
+ (XZDataCryptorAlgorithm *)CASTAlgorithmWithKey:(NSString *)key NS_SWIFT_NAME(CAST(key:));
+ (XZDataCryptorAlgorithm *)CASTAlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds NS_SWIFT_NAME(CAST(key:numberOfRounds:));

/// RC4 算法，密钥长度 1-512 字节，块大小 8 字节。
///
/// @note 如果密钥长度不足 1，则末尾补 \0 到 1 位，如果大于 512，将截取前 512 位。
///
/// @param key 密钥字符串。
/// @return XZDataCryptorAlgorithm 对象
+ (XZDataCryptorAlgorithm *)RC4AlgorithmWithKey:(NSString *)key NS_SWIFT_NAME(RC4(key:));
+ (XZDataCryptorAlgorithm *)RC4AlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds NS_SWIFT_NAME(RC4(key:numberOfRounds:));

/// RC2 算法，密钥长度 1-128 字节，块大小 8 字节。
///
/// @note 如果密钥长度不足 1，则末尾补 \0 到 1 位，如果大于 128，将截取前 128 位。
///
/// @param key 密钥字符串。
/// @return XZDataCryptorAlgorithm 对象
+ (XZDataCryptorAlgorithm *)RC2AlgorithmWithKey:(NSString *)key NS_SWIFT_NAME(RC2(key:));
+ (XZDataCryptorAlgorithm *)RC2AlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds NS_SWIFT_NAME(RC2(key:numberOfRounds:));

/// Blowfish 算法，密钥长度 8-56 字节，块大小 8 字节。
///
/// @note 如果密钥长度不足 8，则末尾补 \0 到 8 位，如果大于 56，将截取前 56 位。
///
/// @param key 密钥字符串。
/// @return XZDataCryptorAlgorithm 对象
+ (XZDataCryptorAlgorithm *)BlowfishAlgorithmWithKey:(NSString *)key NS_SWIFT_NAME(Blowfish(key:));
+ (XZDataCryptorAlgorithm *)BlowfishAlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds NS_SWIFT_NAME(Blowfish(key:numberOfRounds:));

/// 同一构造方法创建的 XZDataCryptorAlgorithm 使用此方法相同。
/// @note 此方法仅判断 algorithm 属性是否相同。
- (BOOL)isEqual:(nullable id)object;

/// 算法名称。
- (NSString *)description;

@end






NS_ASSUME_NONNULL_END

