//
//  NSData+XZDataCryptor.h
//  XZKit
//
//  Created by Xezun on 2018/7/25.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<XZKit/XZKitDefines.h>)
#import <XZKit/XZKitDefines.h>
#import <XZKit/XZDataDigester.h>
#import <XZKit/XZDataCryptor.h>
#else
#import "XZKitDefines.h"
#import "XZDataDigester.h"
#import "XZDataCryptor.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSData (XZDataCryptor)

/// 加密当前数据。
- (nullable NSData *)xz_dataByEncryptingUsingAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable * _Nullable)error NS_SWIFT_NAME(encrypting(using:mode:padding:));
/// 解密当前的加密数据。
- (nullable NSData *)xz_dataByDecryptingUsingAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable * _Nullable)error NS_SWIFT_NAME(decrypting(using:mode:padding:));
/// 对当前数据进行 AES 加密/解密。
- (nullable NSData *)xz_AES:(XZDataCryptorOperation)operation key:(NSString *)key mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(AES(_:key:mode:padding:));
/// 对当前数据进行 AES 加密/解密，且使用 CBC、PKCS7 模式。
- (nullable NSData *)xz_AES:(XZDataCryptorOperation)operation key:(NSString *)key vector:(NSString *)vector error:(NSError *__autoreleasing  _Nullable * _Nullable)error NS_SWIFT_NAME(AES(_:key:vector:));
/// 对当前数据进行 DES 加密/解密。
- (nullable NSData *)xz_DES:(XZDataCryptorOperation)operation key:(NSString *)key mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error NS_SWIFT_NAME(DES(_:key:mode:padding:));
/// 对当前数据进行 DES 加密/解密，且使用 CBC、PKCS7 模式。
- (nullable NSData *)xz_DES:(XZDataCryptorOperation)operation key:(NSString *)key vector:(NSString *)vector error:(NSError *__autoreleasing  _Nullable * _Nullable)error NS_SWIFT_NAME(DES(_:key:vector:));

@end

NS_ASSUME_NONNULL_END