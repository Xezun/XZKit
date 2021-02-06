//
//  NSData+XZDataCryptor.m
//  XZKit
//
//  Created by Xezun on 2018/7/25.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import "NSData+XZDataCryptor.h"

@implementation NSData (XZDataCryptor)

- (NSData *)xz_dataByEncryptingUsingAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error {
    return [XZDataCryptor crypto:self algorithm:algorithm operation:(XZDataCryptorOperationEncrypt) mode:mode padding:padding error:error];
}

- (NSData *)xz_dataByDecryptingUsingAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error {
    return [XZDataCryptor crypto:self algorithm:algorithm operation:(XZDataCryptorOperationDecrypt) mode:mode padding:padding error:error];
}

- (NSData *)xz_AES:(XZDataCryptorOperation)operation key:(NSString *)key mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error {
    return [XZDataCryptor crypto:self
                       algorithm:[XZDataCryptorAlgorithm AESAlgorithmWithKey:key]
                       operation:operation
                            mode:mode
                         padding:padding
                           error:error];
}

- (NSData *)xz_AES:(XZDataCryptorOperation)operation key:(NSString *)key vector:(NSString *)vector error:(NSError * _Nullable __autoreleasing *)error {
    return [XZDataCryptor crypto:self
                       algorithm:[XZDataCryptorAlgorithm AESAlgorithmWithKey:key]
                       operation:operation
                            mode:[XZDataCryptorMode CBCModeWithVector:vector]
                         padding:(XZDataCryptorPKCS7Padding)
                           error:error];
}

- (NSData *)xz_DES:(XZDataCryptorOperation)operation key:(NSString *)key mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error {
    return [XZDataCryptor crypto:self
                       algorithm:[XZDataCryptorAlgorithm DESAlgorithmWithKey:key]
                       operation:operation
                            mode:mode
                         padding:padding
                           error:error];
}

- (NSData *)xz_DES:(XZDataCryptorOperation)operation key:(NSString *)key vector:(NSString *)vector error:(NSError * _Nullable __autoreleasing *)error {
    return [XZDataCryptor crypto:self
                       algorithm:[XZDataCryptorAlgorithm DESAlgorithmWithKey:key]
                       operation:operation
                            mode:[XZDataCryptorMode CBCModeWithVector:vector]
                         padding:(XZDataCryptorPKCS7Padding)
                           error:error];
}

@end
