//
//  XZDataCryptor.m
//  XZKit
//
//  Created by M. X. Z. on 16/7/28.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import "XZDataCryptor.h"
#import <CommonCrypto/CommonCryptor.h>

NSInteger const kXZDataCryptoAlgorithmAESIVLength = kCCBlockSizeAES128;

@interface XZAlgorithm ()

@property (nonatomic) CCAlgorithm algorithm;
@property (nonatomic) CCOptions options;
@property (nonatomic, copy) NSString *iv;
@property (nonatomic) NSUInteger keySize;
@property (nonatomic) NSUInteger size;

@end







@interface XZDataCryptor () {
    CCCryptorRef _cryptorRef;
}

@end


@implementation XZDataCryptor

+ (NSData *)_XZDataCrypt:(NSData *)data operation:(CCOperation)operation algorithm:(XZAlgorithm *)algorithm key:(NSString *)key error:(NSError *__autoreleasing *)error {
    NSData *resultData     = nil;
    void *outDataBuffer    = malloc(sizeof(char) * data.length);// 密文
    size_t outSizeRequired = 0;
    CCCryptorStatus status = CCCrypt(operation,                 // 操作类型：加密、解密
                                     algorithm.algorithm,       // 算法
                                     algorithm.options,         // 选项
                                     key.UTF8String,            // 密钥
                                     algorithm.keySize,         // 密钥长度
                                     algorithm.iv.UTF8String,   // 初始化向量
                                     data.bytes,                // 原始数据
                                     data.length,               // 数据的长度
                                     outDataBuffer,             // 输出的数据
                                     1024,                      // 输出缓存的大小
                                     &outSizeRequired);         // 如果缓冲池不够大，部分密文将被丢弃，这里返回被丢弃的密文的长度
    // 如果输出长度不够，就再试一次。
    if (status == kCCBufferTooSmall) {
        outDataBuffer = realloc(outDataBuffer, outSizeRequired);
        status = CCCrypt(operation, algorithm.algorithm, algorithm.options, key.UTF8String, algorithm.keySize, algorithm.iv.UTF8String, data.bytes, data.length, outDataBuffer, 1024, NULL);
    }
    if (status == kCCSuccess) {
        resultData = [NSData dataWithBytes:outDataBuffer length:outSizeRequired];
    } else if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:status userInfo:nil];
    }
    free(outDataBuffer);
    return resultData;
}

+ (NSData *)encrypt:(NSData *)data algorithm:(XZAlgorithm *)algorithm key:(NSString *)key error:(NSError *__autoreleasing *)error {
    return [self _XZDataCrypt:data operation:kCCEncrypt algorithm:algorithm key:key error:error];
}

+ (NSData *)decrypt:(NSData *)data algorithm:(XZAlgorithm *)algorithm key:(NSString *)key error:(NSError *__autoreleasing *)error {
    return [self _XZDataCrypt:data operation:kCCDecrypt algorithm:algorithm key:key error:error];
}

@end

#pragma mark - =====================
#pragma mark - XZDataCryptoAlgorithm
#pragma mark - =====================

@implementation XZAlgorithm

+ (instancetype)algorithmWithType:(XZAlgorithmType)type options:(XZAlgorithmOptions)options iv:(NSString *)iv {
    return [[self alloc] initWithType:type options:options iv:iv];
}

- (instancetype)initWithType:(XZAlgorithmType)type options:(XZAlgorithmOptions)options iv:(NSString *)iv {
    self = [super init];
    if (self != nil) {
        _options = options;
        _iv = iv;
        switch (type) {
            case XZAlgorithmTypeAES128:
                _keySize   = kCCKeySizeAES128;
                _algorithm = kCCAlgorithmAES128;
                _size      = kCCBlockSizeAES128;
                break;
            case XZAlgorithmTypeAES192:
                _keySize   = kCCKeySizeAES192;
                _algorithm = kCCAlgorithmAES128;
                _size      = kCCBlockSizeAES128;
                break;
            case XZAlgorithmTypeAES256:
                _keySize   = kCCKeySizeAES256;
                _algorithm = kCCAlgorithmAES128;
                _size      = kCCBlockSizeAES128;
                break;
            case XZAlgorithmTypeDES:
                _keySize   = kCCKeySizeDES;
                _algorithm = kCCAlgorithmDES;
                _size      = kCCBlockSizeDES;
                break;
            case XZAlgorithmType3DES:
                _keySize   = kCCKeySize3DES;
                _algorithm = kCCAlgorithm3DES;
                _size      = kCCBlockSize3DES;
                break;
            case XZAlgorithmTypeCAST:
                _keySize   = kCCKeySizeMaxCAST;
                _algorithm = kCCAlgorithmCAST;
                _size      = kCCBlockSizeCAST;
                break;
            case XZAlgorithmTypeRC2:
                _keySize   = kCCKeySizeMaxRC2;
                _algorithm = kCCAlgorithmRC2;
                _size      = kCCBlockSizeRC2;
                break;
            case XZAlgorithmTypeRC4:
                _keySize   = kCCKeySizeMaxRC4;
                _algorithm = kCCAlgorithmRC4;
                _size      = kCCBlockSizeRC2; /* no rc4 block size found */
                break;
            case XZAlgorithmTypeBlowfish:
                _keySize   = kCCKeySizeMaxBlowfish;
                _algorithm = kCCAlgorithmBlowfish;
                _size      = kCCBlockSizeBlowfish;
                break;
            default:
                break;
        }
    }
    return self;
}

+ (instancetype)AES128:(NSString *)iv {
    return [[self alloc] initWithType:(XZAlgorithmTypeAES128) options:(XZAlgorithmOptionPKCS7Padding) iv:iv];
}

+ (instancetype)AES192:(NSString *)iv {
    return [[self alloc] initWithType:(XZAlgorithmTypeAES192) options:(XZAlgorithmOptionPKCS7Padding) iv:iv];
}

+ (instancetype)AES256:(NSString *)iv {
    return [[self alloc] initWithType:(XZAlgorithmTypeAES256) options:(XZAlgorithmOptionPKCS7Padding) iv:iv];
}

+ (instancetype)DES:(NSString *)iv {
    return [[self alloc] initWithType:(XZAlgorithmTypeDES) options:(XZAlgorithmOptionPKCS7Padding) iv:iv];
}

+ (instancetype)TripleDES:(NSString *)iv {
    return [[self alloc] initWithType:(XZAlgorithmType3DES) options:(XZAlgorithmOptionPKCS7Padding) iv:iv];
}


@end



