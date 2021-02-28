//
//  XZDataCryptor.h
//  XZKit
//
//  Created by Xezun on 2018/2/6.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZDataCryptorAlgorithm.h>

// 因为对称加解密属于复杂且耗时的操作，应交由专门的对象处理。
// 不适合写成 NSString、NSData 的类目，以免让人误以为它是一个常规方法。

NS_ASSUME_NONNULL_BEGIN

/// XZDataCryptor 提供了数据的对称加密功能，封装了 CommonCrypto 框架。
/// @note XZDataCryptor 对象设计为大型数据加密，小数据（可单次处理）推荐使用静态方法。
@interface XZDataCryptor: NSObject

/// 加密或解密。
@property (nonatomic, readonly) XZDataCryptorOperation operation;
/// 执行加密或解密的算法。
@property (nonatomic, copy, readonly) XZDataCryptorAlgorithm *algorithm;
/// 执行加密或解密的模式。
@property (nonatomic, readonly) XZDataCryptorMode mode;
/// 数据不足整数块时的填充模式。
@property (nonatomic, readonly) XZDataCryptorPadding padding;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 构造 XZDataCryptor 对象。
/// @param operation 加密/解密
/// @param algorithm 算法
/// @param mode 模式
/// @param padding 填充方式
+ (XZDataCryptor *)cryptorWithOperation:(XZDataCryptorOperation)operation algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding NS_SWIFT_NAME(init(_:algorithm:mode:padding:));

/// 构造一个用于加密的 XZDataCryptor 对象。
/// @param algorithm 算法
/// @param mode 模式
/// @param padding 块填充方式
+ (XZDataCryptor *)encryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding NS_SWIFT_NAME(init(encryptor:mode:padding:));

/// 构造一个用于解密的 XZDataCryptor 对象。
/// @param algorithm 算法
/// @param mode 模式
/// @param padding 块填充方式
+ (XZDataCryptor *)decryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding NS_SWIFT_NAME(init(decryptor:mode:padding:));

/// 对数据执行加密/解密操作。本方法可调用多次，比如将较大的数据分块读入内存，分别进行加密解密计算。
///
/// @note 虽然可以分块计算，但是不一定能使用多线程技术，具体要看加密解密的算法和计算模式是否支持。
/// @note 对于分组密码及块加密算法，需要调用 -finish: 方法补齐块数据才能最终完成加密计算。
///
/// @param bytes 待加密/解密的数据
/// @param error 执行加密或解密时发生发生的错误输出
/// @return （已成功执行）已加密/解密后的数据
- (nullable NSData *)crypto:(void *)bytes length:(NSUInteger)length error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 对数据执行加密/解密操作。
- (nullable NSData *)crypto:(NSData *)data error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 结束加解密计算，并获取最终的补齐数据。
/// @note 对于流密码、无补齐模式的加解密来说，不需要调用此方法。
///
/// @param error 错误输出。
- (nullable NSData *)finish:(NSError *__autoreleasing  _Nullable *)error;

/// 以新的初始化向量重置当前对象，以开始新的加解密。
/// @note CCCryptor 只有 CBC 模式支持重置，对于非 CBC 模式，本方法会重新构造上下文以实现重置。
/// @param vector 初始化向量
- (void)resetWithVector:(nullable NSString *)vector;

@end

@interface XZDataCryptor (XZExtendedDataCryptor)

/// 加密的便利方法。
/// @note 当数据较小可以单独处理时，使用此方法要比使用实例化 XZDataCryptor 对象效率更高。
/// @note 此方法只支持使用 ECB 、CBC（noPadding/PKCS7Padding）模式。
+ (nullable NSData *)encrypt:(NSData *)data algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError **)error;

/// 解密的便利方法。
/// @note 当数据较小，且可以单独处理时，使用此方法要比使用实例化 XZDataCryptor 对象效率更高。
/// @note 此方法只支持使用 ECB 、CBC（noPadding/PKCS7Padding）模式。
+ (nullable NSData *)decrypt:(NSData *)data algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError **)error;

@end


@interface XZDataCryptor (XZAESDataCryptor)

/// 构造处理 AES 加密的 XZDataCryptor 对象。
+ (XZDataCryptor *)AESEncryptor:(NSString *)key vector:(nullable NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding NS_SWIFT_NAME(init(AESEncryptor:vector:mode:padding:));

/// 构造处理 AES 加密的 XZDataCryptor 对象。
+ (XZDataCryptor *)AESEncryptor:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(init(AESEncryptor:vector:));

/// 构造处理 AES 解密的 XZDataCryptor 对象。
+ (XZDataCryptor *)AESDecryptor:(NSString *)key vector:(nullable NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding NS_SWIFT_NAME(init(AESDecryptor:vector:mode:padding:));

/// 构造处理 AES 解密的 XZDataCryptor 对象。
+ (XZDataCryptor *)AESDecryptor:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(init(AESDecryptor:vector:));

/// AES 加密的便利方法。
+ (nullable NSData *)AESEncrypt:(NSData *)data key:(NSString *)key vector:(nullable NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(AESEncrypt(_:key:vector:model:padding:));
/// AES 加密的便利方法。
+ (nullable NSData *)AESEncrypt:(NSData *)data key:(NSString *)key vector:(nullable NSString *)vector error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(AESEncrypt(_:key:vector:));

/// AES 解密的便利方法。
+ (nullable NSData *)AESDecrypt:(NSData *)data key:(NSString *)key vector:(nullable NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(AESDecrypt(_:key:vector:model:padding:));
/// AES 加密的便利方法。
+ (nullable NSData *)AESDecrypt:(NSData *)data key:(NSString *)key vector:(nullable NSString *)vector error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(AESDecrypt(_:key:vector:));

@end


@interface XZDataCryptor (XZDESDataCryptor)

/// 构造处理 DES 加密的 XZDataCryptor 对象。
+ (XZDataCryptor *)DESEncryptor:(NSString *)key vector:(nullable NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding NS_SWIFT_NAME(init(DESEncryptor:vector:mode:padding:));

/// 构造处理 DES 加密的 XZDataCryptor 对象。
+ (XZDataCryptor *)DESEncryptor:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(init(DESEncryptor:vector:));

/// 构造处理 DES 解密的 XZDataCryptor 对象。
+ (XZDataCryptor *)DESDecryptor:(NSString *)key vector:(nullable NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding NS_SWIFT_NAME(init(DESDecryptor:vector:mode:padding:));

/// 构造处理 DES 解密的 XZDataCryptor 对象。
+ (XZDataCryptor *)DESDecryptor:(NSString *)key vector:(nullable NSString *)vector NS_SWIFT_NAME(init(DESDecryptor:vector:));

/// DES 加密的便利方法。
+ (nullable NSData *)DESEncrypt:(NSData *)data key:(NSString *)key vector:(nullable NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(DESEncrypt(_:key:vector:model:padding:));
/// DES 加密的便利方法。
+ (nullable NSData *)DESEncrypt:(NSData *)data key:(NSString *)key vector:(nullable NSString *)vector error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(DESEncrypt(_:key:vector:));

/// DES 解密的便利方法。
+ (nullable NSData *)DESDecrypt:(NSData *)data key:(NSString *)key vector:(nullable NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(DESDecrypt(_:key:vector:model:padding:));
/// DES 加密的便利方法。
+ (nullable NSData *)DESDecrypt:(NSData *)data key:(NSString *)key vector:(nullable NSString *)vector error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(DESDecrypt(_:key:vector:));

@end



NS_ASSUME_NONNULL_END

