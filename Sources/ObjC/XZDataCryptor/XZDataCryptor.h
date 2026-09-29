//
//  XZDataCryptor.h
//  XZKit
//
//  Created by Xezun on 2018/2/6.
//  Copyright © 2018年 Xezun Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZDataCryptorDefines.h>
#else
#import "XZDataCryptorDefines.h"
#endif

// 因为对称加解密属于复杂且耗时的操作，应交由专门的对象处理。
// 不适合写成 NSString、NSData 的类目，以免让人误以为它是一个常规方法。

NS_ASSUME_NONNULL_BEGIN

/// 对称加密工具类，封装了 CommonCrypto 框架。
///
/// 加密大型数据，使用实例化对象；加密小型数据，使用静态方法。
@interface XZDataCryptor: NSObject

/// 加密或解密。
@property (nonatomic, readonly) XZDataCryptorOperation operation;
/// 执行加密或解密的算法。
/// @note 构造时会持有 algorithm 的副本，外部再修改传入的 XZDataCryptorAlgorithm 不会影响本对象。
@property (nonatomic, copy, readonly) XZDataCryptorAlgorithm *algorithm;
/// 执行加密或解密的模式。
@property (nonatomic, readonly) XZDataCryptorMode mode;
/// 数据不足整数块时的填充模式。
@property (nonatomic, readonly) XZDataCryptorPadding padding;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

/// 构造 XZDataCryptor 对象。
/// @note 密钥与向量的长度由 XZDataCryptorAlgorithm 保证合法，只有在内存不足或算法与模式的组合不受支持时才返回 nil。
/// @param algorithm 算法
/// @param operation 加密/解密
/// @param mode 模式
/// @param padding 填充方式
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 构造好的加密器对象。
+ (nullable instancetype)cryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 便利构造方法，使用 CBC/PKCS7 参数。
/// @note 密钥与向量的长度由 XZDataCryptorAlgorithm 保证合法，只有在内存不足或算法与模式的组合不受支持时才返回 nil。
/// @param algorithm 算法
/// @param operation 加密或解密
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 构造好的加密器对象。
+ (nullable instancetype)cryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 对数据执行加密/解密操作。本方法可调用多次，比如将较大的数据分块读入内存，分别进行加密解密计算。
///
/// @note 虽然可以分块计算，但是不一定能使用多线程技术，具体要看加密解密的算法和计算模式是否支持。
/// @note 对于分组密码及块加密算法，需要调用 -final: 方法补齐块数据才能最终完成加密计算。
///
/// @param bytes 待加密/解密的数据
/// @param error 执行加密或解密时发生的错误输出，错误域为 XZDataCryptorErrorDomain
/// @return （已成功执行）已加密/解密后的数据
- (nullable NSData *)cryptBytes:(const void *)bytes length:(NSUInteger)length error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(crypt(_:length:));

/// 对数据执行加密/解密操作。
- (nullable NSData *)cryptData:(NSData *)data error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(crypt(_:));
                     
/// 结束加解密计算，并获取最终的补齐数据。
/// @note Finish an encrypt or decrypt operation, and obtain the (possible) final data output.
/// @note 对于流密码、无补齐模式的加解密来说，不需要调用此方法。
///
/// @param error 错误输出。
- (nullable NSData *)final:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 以新的密钥和初始化向量重置当前对象，以开始新的加解密。
/// @note CommonCrypto 的 CCCryptorReset 不能更换密钥，因此本方法通过重建上下文实现重置。
/// @note 尚未凑满一块而被缓冲的数据将被丢弃。
/// @param key 密钥。传 nil 得到全 `\0` 的合法密钥。
/// @param vector 初始化向量。传 nil 得到全 `\0` 的合法向量；不使用向量的算法会忽略其值。
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
- (BOOL)resetWithKey:(nullable NSData *)key vector:(nullable NSData *)vector error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 只重置初始化向量。
/// @param vector 初始化向量。
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
- (BOOL)resetWithVector:(nullable NSData *)vector error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end


@interface XZDataCryptor (XZExtendedDataCryptor)

/// 加密的便利方法。
/// @note 当数据较小可以单独处理时，使用此方法要比使用实例化 XZDataCryptor 对象效率更高。
/// @note 此方法只支持 ECB 、CBC（noPadding/PKCS7Padding）、RC4 模式，传入其他模式会返回 kCCUnimplemented 错误。
/// @param data 待加密的数据
/// @param algorithm 算法
/// @param mode 模式
/// @param padding 填充方式
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 已加密后的数据
+ (nullable NSData *)encrypt:(NSData *)data algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error;

/// 解密的便利方法。
/// @note 当数据较小，且可以单独处理时，使用此方法要比使用实例化 XZDataCryptor 对象效率更高。
/// @note 此方法只支持 ECB 、CBC（noPadding/PKCS7Padding）、RC4 模式，传入其他模式会返回 kCCUnimplemented 错误。
/// @param data 待解密的数据
/// @param algorithm 算法
/// @param mode 模式
/// @param padding 填充方式
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 已解密后的数据
+ (nullable NSData *)decrypt:(NSData *)data algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error;

@end


@interface XZDataCryptor (XZAESDataCryptor)

/// 构造 AES 加密器。
/// @param operation 加密或解密
/// @param key 密钥
/// @param vector 初始化向量
/// @param mode 加密模式
/// @param padding 块对齐方式
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 构造好的加密器对象。
/// @note 密钥与向量的长度由 XZDataCryptorAlgorithm 保证合法，只有在内存不足或算法与模式的组合不受支持时才返回 nil。
+ (nullable instancetype)AESCryptor:(XZDataCryptorOperation)operation key:(nullable NSData *)key vector:(nullable NSData *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(init(AES:key:vector:mode:padding:));
/// 构造 AES 加密器，使用 CBC/PKCS7Padding 参数。
/// @param operation 加密或解密
/// @param key 密钥
/// @param vector 初始化向量
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 构造好的加密器对象。
/// @note 密钥与向量的长度由 XZDataCryptorAlgorithm 保证合法，只有在内存不足或算法与模式的组合不受支持时才返回 nil。
+ (nullable instancetype)AESCryptor:(XZDataCryptorOperation)operation key:(nullable NSData *)key vector:(nullable NSData *)vector error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(init(AES:key:vector:));

/// 对数据执行 AES 加密或解密。
/// @note 一次性方法只支持 ECB 、CBC（noPadding/PKCS7Padding）、RC4 模式，传入其他模式会返回 kCCUnimplemented 错误；CFB/CTR/OFB/CFB8 请使用加密器实例。
/// @param data 待处理的数据
/// @param operation 加密或解密
/// @param key 密钥
/// @param vector 初始化向量
/// @param mode 加密模式
/// @param padding 块对齐方式
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 已加密/解密后的数据
+ (nullable NSData *)AES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(nullable NSData *)key vector:(nullable NSData *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(AES(_:operation:key:vector:mode:padding:));
/// 对数据执行 AES 加密或解密，使用 CBC/PKCS7Padding 参数。
/// @param data 待处理的数据
/// @param operation 加密或解密
/// @param key 密钥
/// @param vector 初始化向量
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 已加密/解密后的数据
+ (nullable NSData *)AES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(nullable NSData *)key vector:(nullable NSData *)vector error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(AES(_:operation:key:vector:));

@end


@interface XZDataCryptor (XZDESDataCryptor)

/// 构造 DES 加密器。
/// @param operation 加密或解密
/// @param key 密钥
/// @param vector 初始化向量
/// @param mode 加密模式
/// @param padding 块对齐方式
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 构造好的加密器对象。
/// @note 密钥与向量的长度由 XZDataCryptorAlgorithm 保证合法，只有在内存不足或算法与模式的组合不受支持时才返回 nil。
+ (nullable instancetype)DESCryptor:(XZDataCryptorOperation)operation key:(nullable NSData *)key vector:(nullable NSData *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(init(DES:key:vector:mode:padding:));
/// 构造 DES 加密器，使用 CBC/PKCS7Padding 参数。
/// @param operation 加密或解密
/// @param key 密钥
/// @param vector 初始化向量
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 构造好的加密器对象。
/// @note 密钥与向量的长度由 XZDataCryptorAlgorithm 保证合法，只有在内存不足或算法与模式的组合不受支持时才返回 nil。
+ (nullable instancetype)DESCryptor:(XZDataCryptorOperation)operation key:(nullable NSData *)key vector:(nullable NSData *)vector error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(init(DES:key:vector:));

/// 对数据执行 DES 加密或解密。
/// @note 一次性方法只支持 ECB 、CBC（noPadding/PKCS7Padding）、RC4 模式，传入其他模式会返回 kCCUnimplemented 错误；CFB/CTR/OFB/CFB8 请使用加密器实例。
/// @param data 待处理的数据
/// @param operation 加密或解密
/// @param key 密钥
/// @param vector 初始化向量
/// @param mode 加密模式
/// @param padding 块对齐方式
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 已加密/解密后的数据
+ (nullable NSData *)DES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(nullable NSData *)key vector:(nullable NSData *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(DES(_:operation:key:vector:mode:padding:));
/// 对数据执行 DES 加密或解密，使用 CBC/PKCS7Padding 参数。
/// @param data 待处理的数据
/// @param operation 加密或解密
/// @param key 密钥
/// @param vector 初始化向量
/// @param error 错误输出，错误域为 XZDataCryptorErrorDomain
/// @return 已加密/解密后的数据
+ (nullable NSData *)DES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(nullable NSData *)key vector:(nullable NSData *)vector error:(NSError * _Nullable __autoreleasing * _Nullable)error NS_SWIFT_NAME(DES(_:operation:key:vector:));

@end

NS_ASSUME_NONNULL_END

