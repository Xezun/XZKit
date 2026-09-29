//
//  XZDataCryptorDefines.h
//  XZKit
//
//  Created by Xezun on 2021/2/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZDataCryptor, XZDataCryptorAlgorithm;

/// XZDataCryptor 加解密失败时使用的错误域，`code` 为 CommonCrypto 的 CCCryptorStatus 值。
FOUNDATION_EXPORT NSErrorDomain const XZDataCryptorErrorDomain;

/// 加/解密算法。
///
/// 管理与算法相关的参数（密钥、初始化向量、加密轮数等）并做规范化，避免 `XZDataCryptor` 因参数不合法而无法构建。
///
/// 本类保证 `key` 与 `vector` 在任意输入（包括 nil、空串、超长、多字节字符）下都是合法的：
/// 长度不足补 `\0`、超长截断；nil 或无法解析的输入按全 `\0` 处理。因此不会因密钥与向量的问题导致构造失败。
///
/// 密钥与向量提供三种等价的读写形式：`NSData`、十六进制字符串（`hexEncoded*`）、Base64 字符串（`base64Encoded*`），
/// 它们指向同一份底层数据，设置其中任意一个，读取其余形式时都会相应变化。
/// 每个算法的类属性（如 `AESAlgorithm`）返回使用默认（全 `\0`）密钥与向量的实例；
/// 三个同名工厂方法则分别接受 `NSData`、十六进制字符串、Base64 字符串形式的密钥与向量。
NS_SWIFT_NAME(XZDataCryptor.Algorithm)
@interface XZDataCryptorAlgorithm : NSObject <NSCopying>

/// 算法枚举原生值。
@property (nonatomic, readonly) NSInteger rawValue;
/// 算法加密/解密块的大小。
@property (nonatomic, readonly) NSInteger blockSize;
/// 构造 CCCryptorRef 所需的最小内存，仅供参考。
/// @note CommonCrypto 未提供 RC2、Blowfish 的对应常量，此二算法返回 0 表示未知。
@property (nonatomic, readonly) NSInteger contextSize;

/// 加/解密的密钥。
@property (nonatomic, copy) NSData *key;
/// 十六进制编码形式的密钥。
/// @note nil 或空字符串将得到全 `\0` 的合法密钥。
@property (nonatomic, copy) NSString *hexEncodedKey;
/// Base64 编码形式的密钥。
/// @note 不是合法 Base64 字符串时按 nil 处理，将得到全 `\0` 的合法密钥。
@property (nonatomic, copy) NSString *base64EncodedKey;

/// 初始化向量。
@property (nonatomic, copy) NSData *vector;
/// 十六进制编码形式的初始化向量。
/// @note nil 或空字符串将得到全 `\0` 的合法向量。
@property (nonatomic, copy) NSString *hexEncodedVector;
/// Base64 编码形式的初始化向量。
/// @note 不是合法 Base64 字符串时按 nil 处理，将得到全 `\0` 的合法向量。
@property (nonatomic, copy) NSString *base64EncodedVector;

/// 加密轮数。默认 0，表示使用算法默认轮数。
/// @note CommonCrypto 未明确该参数对各算法的实际作用，通常保持默认 0 即可。
@property (nonatomic) NSInteger rounds;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// AES 算法，块大小 16 字节，密钥长度 16/24/32 字节。
/// @note 根据密钥的字节长度自动确定算法：`<= 16` 用 AES128，`<= 24` 用 AES192，`> 24` 用 AES256。
@property (class, readonly) XZDataCryptorAlgorithm *AESAlgorithm NS_SWIFT_NAME(AES);
+ (XZDataCryptorAlgorithm *)AESAlgorithmWithKey:(nullable NSData *)key vector:(nullable NSData *)vector NS_SWIFT_NAME(AES(key:vector:));
+ (XZDataCryptorAlgorithm *)AESAlgorithmWithHexEncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(AES(hexEncodedKey:vector:));
+ (XZDataCryptorAlgorithm *)AESAlgorithmWithBase64EncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(AES(base64EncodedKey:vector:));

/// DES 算法，密钥长度 8 字节，块大小 8 字节。
/// @note 密钥的字节长度不足 8 补 `\0`，超出 8 则截断。
@property (class, readonly) XZDataCryptorAlgorithm *DESAlgorithm NS_SWIFT_NAME(DES);
+ (XZDataCryptorAlgorithm *)DESAlgorithmWithKey:(nullable NSData *)key vector:(nullable NSData *)vector NS_SWIFT_NAME(DES(key:vector:));
+ (XZDataCryptorAlgorithm *)DESAlgorithmWithHexEncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(DES(hexEncodedKey:vector:));
+ (XZDataCryptorAlgorithm *)DESAlgorithmWithBase64EncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(DES(base64EncodedKey:vector:));

/// 3DES 算法，密钥长度 24 字节，块大小 8 字节。
/// @note 密钥的字节长度不足 24 补 `\0`，超出 24 则截断。
@property (class, readonly) XZDataCryptorAlgorithm *tripleDESAlgorithm NS_SWIFT_NAME(tripleDES);
+ (XZDataCryptorAlgorithm *)tripleDESAlgorithmWithKey:(nullable NSData *)key vector:(nullable NSData *)vector NS_SWIFT_NAME(tripleDES(key:vector:));
+ (XZDataCryptorAlgorithm *)tripleDESAlgorithmWithHexEncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(tripleDES(hexEncodedKey:vector:));
+ (XZDataCryptorAlgorithm *)tripleDESAlgorithmWithBase64EncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(tripleDES(base64EncodedKey:vector:));

/// CAST 算法，密钥长度 5-16 字节，块大小 8 字节。
/// @note 密钥的字节长度不足 5 补 `\0` 到 5 位，大于 16 则截取前 16 字节。
@property (class, readonly) XZDataCryptorAlgorithm *CASTAlgorithm NS_SWIFT_NAME(CAST);
+ (XZDataCryptorAlgorithm *)CASTAlgorithmWithKey:(nullable NSData *)key vector:(nullable NSData *)vector NS_SWIFT_NAME(CAST(key:vector:));
+ (XZDataCryptorAlgorithm *)CASTAlgorithmWithHexEncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(CAST(hexEncodedKey:vector:));
+ (XZDataCryptorAlgorithm *)CASTAlgorithmWithBase64EncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(CAST(base64EncodedKey:vector:));

/// RC2 算法，密钥长度 1-128 字节，块大小 8 字节。
/// @note 密钥的字节长度不足 1 补 `\0` 到 1 位，大于 128 则截取前 128 字节。
@property (class, readonly) XZDataCryptorAlgorithm *RC2Algorithm NS_SWIFT_NAME(RC2);
+ (XZDataCryptorAlgorithm *)RC2AlgorithmWithKey:(nullable NSData *)key vector:(nullable NSData *)vector NS_SWIFT_NAME(RC2(key:vector:));
+ (XZDataCryptorAlgorithm *)RC2AlgorithmWithHexEncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(RC2(hexEncodedKey:vector:));
+ (XZDataCryptorAlgorithm *)RC2AlgorithmWithBase64EncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(RC2(base64EncodedKey:vector:));

/// RC4 算法，密钥长度 1-512 字节，分组长度 8 字节。
/// @note 密钥的字节长度不足 1 补 `\0` 到 1 位，大于 512 则截取前 512 字节。
@property (class, readonly) XZDataCryptorAlgorithm *RC4Algorithm NS_SWIFT_NAME(RC4);
+ (XZDataCryptorAlgorithm *)RC4AlgorithmWithKey:(nullable NSData *)key vector:(nullable NSData *)vector NS_SWIFT_NAME(RC4(key:vector:));
+ (XZDataCryptorAlgorithm *)RC4AlgorithmWithHexEncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(RC4(hexEncodedKey:vector:));
+ (XZDataCryptorAlgorithm *)RC4AlgorithmWithBase64EncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(RC4(base64EncodedKey:vector:));

/// Blowfish 算法，密钥长度 8-56 字节，块大小 8 字节。
/// @note 密钥的字节长度不足 8 补 `\0` 到 8 位，大于 56 则截取前 56 字节。
@property (class, readonly) XZDataCryptorAlgorithm *BlowfishAlgorithm NS_SWIFT_NAME(Blowfish);
+ (XZDataCryptorAlgorithm *)BlowfishAlgorithmWithKey:(nullable NSData *)key vector:(nullable NSData *)vector NS_SWIFT_NAME(Blowfish(key:vector:));
+ (XZDataCryptorAlgorithm *)BlowfishAlgorithmWithHexEncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(Blowfish(hexEncodedKey:vector:));
+ (XZDataCryptorAlgorithm *)BlowfishAlgorithmWithBase64EncodedKey:(nullable NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(Blowfish(base64EncodedKey:vector:));

/// 算法一样，即认为相等，而不论密钥、初始化向量、加密轮数等是否相同。
- (BOOL)isEqual:(nullable id)object;

/// 用于 NSSet、NSDictionary 等容器时，同一算法即认为是同一个键。
- (NSUInteger)hash;

/// 包含算法名、密钥、初始化向量、加密轮数等信息。
/// @warning 含有密钥与初始化向量内容，请勿在日志或公开场合打印。
@property (nonatomic, readonly) NSString *description;

@end

/// 描述 XZDataCryptor 执行的行为。
///
/// - XZDataCryptorOperationEncrypt: 加密操作。
/// - XZDataCryptorOperationDecrypt: 解密操作。
typedef NS_ENUM(NSUInteger, XZDataCryptorOperation) {
    /// 加密操作。
    XZDataCryptorOperationEncrypt,
    /// 解密操作。
    XZDataCryptorOperationDecrypt
} NS_SWIFT_NAME(XZDataCryptor.Operation);

/// 当使用块加密方式时，数据可能不会正好填满块，此枚举值描述了 XZDataCryptor 填充数据的方式。
/// @discussion 对于块加密而言，如果数据不是块的整数倍，则无法完成加密。
typedef NS_ENUM(NSUInteger, XZDataCryptorPadding) {
    /// 无填充。除非数据与块大小是整数倍的关系，否则加密不会成功。
    XZDataCryptorNoPadding    NS_SWIFT_NAME(none),
    /// PKCS7 方式填充，兼容 PKCS5。最后一块数据差n位就填充n补齐，如果数据不需要补齐，则额外补充一个数据块。
    XZDataCryptorPKCS7Padding NS_SWIFT_NAME(PKCS7)
} NS_SWIFT_NAME(XZDataCryptor.Padding);

/// 加密/解密模式。
/// @note 模式决定是否使用初始化向量（vector）：ECB、RC4 不使用 vector，其余模式使用。
/// @note 加/解密时实际参与计算的 vector 长度与块大小相同，超长截断、不足补 `\0`。
/// @warning 一次性类方法（如 `+encrypt:algorithm:mode:padding:error:`、`+decrypt:...`）仅支持 ECB、CBC、RC4；
///          传入 CFB、CTR、OFB、CFB8 会返回 `kCCUnimplemented` 错误，这些模式需改用 `XZDataCryptor` 分段实例接口。
/// @warning 本枚举取值与 CommonCrypto 的 `CCMode` 并不一致（如 CBC 在本枚举为 1、`CCMode` 为 2），
///          禁止直接强转为 `CCMode` 或与 `CCMode` 常量比较，需经显式映射转换。
typedef NS_ENUM(NSUInteger, XZDataCryptorMode) {
    /// ECB 电码本加密模式，将整个明文分成若干段相同的小段，然后对每一小段进行加密。
    /// @note 不建议使用。
    /// @note 不支持 vector 初始化向量。
    XZDataCryptorModeECB,
    /// CBC 密码分组链接模式。先将明文切分成若干小段，然后每一小段与初始块或者上一段的密文段进行异或运算后，再与密钥进行加密。
    /// @note 使用 vector 初始化向量。
    XZDataCryptorModeCBC,
    /// CFB 密码反馈模式。一次处理 S 位，上一块密文作为加密算法的输入，产生的伪随机数输出与明文异或作为下一单元的密文。
    /// @note 使用 vector 初始化向量；仅支持分段接口（见上方一次性接口限制）。
    XZDataCryptorModeCFB,
    /// CTR 计数器模式。用一个自增的计数器块经密钥加密后与明文异或得到密文，相当于一次一密，可并行加解密、速度快。
    /// @note 使用 vector 作为初始计数器/nonce；相同密钥下计数器不得重用。仅支持分段接口（见上方一次性接口限制）。
    XZDataCryptorModeCTR,
    /// OFB 输出反馈模式。与 CFB 类似，只是加密算法的输入是上一次加密的输出，且使用整个分组。
    /// @note 使用 vector 初始化向量；仅支持分段接口（见上方一次性接口限制）。
    XZDataCryptorModeOFB,
    /// RC4 模式。仅 RC4 算法可用，其他算法使用此模式，视为 ECB 模式（因为都不支持初始化向量）。
    /// @note 不支持 vector 初始化向量。
    XZDataCryptorModeRC4,
    /// CFB8 密码反馈模式，以 8 位（单字节）为单位反馈。
    /// @note 使用 vector 初始化向量；仅支持分段接口（见上方一次性接口限制）。
    XZDataCryptorModeCFB8
} NS_SWIFT_NAME(XZDataCryptor.Mode);

NS_ASSUME_NONNULL_END
