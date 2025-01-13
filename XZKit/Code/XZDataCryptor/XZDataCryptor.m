//
//  XZCryptor.m
//  XZKit
//
//  Created by Xezun on 2018/2/6.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import "XZDataCryptor.h"
#import <CommonCrypto/CommonCryptor.h>

/// 返回 YES 表示有错误，NO 表示没有错误。
static BOOL XZDataCryptorHandleError(CCCryptorStatus status, NSError * _Nullable __autoreleasing *error);
/// 构造 CCCryptorRef 的方法。
static CCCryptorRef _Nullable XZDataCryptorContextMake(XZDataCryptorAlgorithm *algorithm, XZDataCryptorOperation operation, XZDataCryptorMode mode, XZDataCryptorPadding padding, NSError **error);

@implementation XZDataCryptor {
    CCCryptorRef _context;
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

- (void)dealloc {
    CCCryptorRelease(_context);
}

- (instancetype)initWithContext:(CCCryptorRef)context operation:(XZDataCryptorOperation)operation algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding {
    self = [super init];
    if (self) {
        _context   = context;
        _algorithm = algorithm;
        _operation = operation;
        _mode      = (_algorithm.rawValue == kCCAlgorithmRC4) ? XZDataCryptorModeRC4 : mode;
        _padding   = padding;
    }
    return self;
}

+ (XZDataCryptor *)cryptorWithOperation:(XZDataCryptorOperation)operation algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding {
    NSError *error = nil;
    CCCryptorRef context = XZDataCryptorContextMake(algorithm, operation, mode, padding, &error);
    return [[self alloc] initWithContext:context operation:operation algorithm:algorithm mode:mode padding:padding];
}

+ (XZDataCryptor *)cryptorWithOperation:(XZDataCryptorOperation)operation algorithm:(XZDataCryptorAlgorithm *)algorithm {
    return [self cryptorWithOperation:operation algorithm:algorithm mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding)];
}

- (BOOL)update:(const void * const)bytes length:(NSUInteger)length receiver:(BOOL (^NS_NOESCAPE)(void *buffer, size_t length))receiver error:(NSError * _Nullable __autoreleasing *)error {
    NSParameterAssert(bytes != NULL);
    // 获取需要的内存
    size_t bufferSize = CCCryptorGetOutputLength(_context, length, false);
    // 开辟内存。第一次为新开辟，第二次调用就是拓展内存了。
    void *buffer = malloc(bufferSize);
    // 生成的数据的实际大小。
    size_t outputLength = 0;
    // 执行加密/解密。
    CCCryptorStatus status = CCCryptorUpdate(_context, bytes, length, buffer, bufferSize, &outputLength);
    // 检查状态，是否发生错误
    if (XZDataCryptorHandleError(status, error)) {
        free(buffer);
        return NO;
    }
    // 接收了 buffer
    if (!receiver(buffer, outputLength)) {
        // 释放内存
        free(buffer);
    }
    return YES;
}

- (NSData *)crypt:(void *)bytes length:(NSUInteger)length error:(NSError * _Nullable __autoreleasing *)error {
    NSData * __block data = nil;
    
    [self update:bytes length:length receiver:^BOOL(void *buffer, size_t length) {
        data = [NSData dataWithBytesNoCopy:buffer length:length freeWhenDone:YES];
        return YES;
    } error:error];
    
    return data;
}

- (NSData *)crypt:(NSData *)data error:(NSError * _Nullable __autoreleasing *)error {
    NSMutableData * __block dataM = nil;
    
    [data enumerateByteRangesUsingBlock:^(const void * _Nonnull bytes, NSRange byteRange, BOOL * _Nonnull stop) {
        [self update:bytes length:byteRange.length receiver:^BOOL(void *buffer, size_t length) {
            if (dataM == nil) {
                dataM = [NSMutableData dataWithBytesNoCopy:buffer length:length freeWhenDone:YES];
                return YES;
            }
            [dataM appendBytes:buffer length:length];
            return NO;
        } error:error];
    }];
    
    return dataM;
}

- (NSData *)final:(NSError *__autoreleasing  _Nullable *)error {
    size_t const bufferSize = CCCryptorGetOutputLength(_context, 0, true);
    void *buffer = malloc(bufferSize); // 如果 bufferSize = 0，malloc 函数的返回值不一定是 NULL 。
    
    size_t outputLength = 0;
    CCCryptorStatus status = CCCryptorFinal(_context, buffer, bufferSize, &outputLength);
    
    // 发生错误
    if (XZDataCryptorHandleError(status, error)) {
        free(buffer);
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:outputLength freeWhenDone:YES];
}

- (void)resetWithKey:(NSString *)key vector:(NSString *)vector {
    _algorithm.key = key;
    _algorithm.vector = vector;
    
    // CCCryptorReset 只支持 CBC 模式只调用
    if (_mode == kCCModeCBC) {
        CCCryptorStatus status = CCCryptorReset(_context, _algorithm.vector.UTF8String);
        if (!XZDataCryptorHandleError(status, NULL)) {
            return;
        }
        // 重置失败，尝试重建
    }
    
    // 重建 _context
    CCCryptorRelease(_context);
    _context = XZDataCryptorContextMake(_algorithm, _operation, _mode, _padding, NULL);
}

@end


static inline CCOptions CCOptionsMake(XZDataCryptorPadding padding, XZDataCryptorMode mode) {
    CCOptions options = (padding == XZDataCryptorPKCS7Padding ? kCCOptionPKCS7Padding : 0);
    if (mode == kCCModeECB) {
        options = options | kCCOptionECBMode;
    }
    return options;
}

@implementation XZDataCryptor (XZExtendedDataCryptor)

+ (NSData *)encrypt:(NSData *)data algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable *)error {
    return [self crypt:data operation:(XZDataCryptorOperationEncrypt) algorithm:algorithm mode:mode padding:padding error:error];
}

+ (NSData *)decrypt:(NSData *)data algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable *)error {
    return [self crypt:data operation:(XZDataCryptorOperationDecrypt) algorithm:algorithm mode:mode padding:padding error:error];
}

+ (NSData *)crypt:(NSData *)data operation:(XZDataCryptorOperation)operation algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error {
    void *buffer = NULL;
    // 根据补齐规则加密后的数据不会超过此值。
    size_t bufferSize = data.length + algorithm.blockSize;
    CCOptions  const options = CCOptionsMake(padding, mode);
    NSString * const vector  = algorithm.vector;
    
    CCCryptorStatus status = kCCBufferTooSmall;
    while (status == kCCBufferTooSmall) {
        buffer = realloc(buffer, bufferSize);
        status = CCCrypt((operation), // 加密/解密
                         (CCAlgorithm)algorithm.rawValue,            // 算法
                         options,                        // 模式与填充方式，只支持 ECB 、CBC（noPadding/PKCS7Padding）。
                         algorithm.key.UTF8String,       // 密钥
                         algorithm.key.length,           // 密钥长度
                         vector.UTF8String,              // 初始化向量
                         data.bytes,                     // 输入的数据
                         data.length,                    // 数据长度
                         buffer,                         // 数据输出缓冲区
                         bufferSize,                     // 缓冲区大小
                         &bufferSize);                   // 输出的数据的实际大小
    }
    
    if (XZDataCryptorHandleError(status, error)) {
        free(buffer);
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
}

@end


@implementation XZDataCryptor (XZAESDataCryptor)

+ (XZDataCryptor *)AESCryptor:(XZDataCryptorOperation)operation key:(NSString *)key vector:(NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm AES:key vector:vector];
    return [self cryptorWithOperation:operation algorithm:algorithm mode:mode padding:padding];
}

+ (XZDataCryptor *)AESCryptor:(XZDataCryptorOperation)operation key:(NSString *)key vector:(NSString *)vector {
    return [self AESCryptor:operation key:key vector:vector mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding)];
}

+ (NSData *)AES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSString *)key vector:(NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable *)error {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm AES:key vector:vector];
    return [self crypt:data operation:operation algorithm:algorithm mode:mode padding:padding error:error];
}

+ (NSData *)AES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSString *)key vector:(NSString *)vector error:(NSError *__autoreleasing  _Nullable *)error {
    return [self AES:data operation:operation key:key vector:vector mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding) error:error];
}

@end


@implementation XZDataCryptor (XZDESDataCryptor)

+ (XZDataCryptor *)DESCryptor:(XZDataCryptorOperation)operation key:(NSString *)key vector:(nullable NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm DES:key vector:vector];
    return [self cryptorWithOperation:operation algorithm:algorithm mode:mode padding:padding];
}

+ (XZDataCryptor *)DESCryptor:(XZDataCryptorOperation)operation key:(NSString *)key vector:(nullable NSString *)vector {
    return [self DESCryptor:operation key:key vector:vector mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding)];
}

+ (nullable NSData *)DES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSString *)key vector:(nullable NSString *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm DES:key vector:vector];
    return [self crypt:data operation:operation algorithm:algorithm mode:mode padding:padding error:error];
}

+ (nullable NSData *)DES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSString *)key vector:(nullable NSString *)vector error:(NSError * _Nullable __autoreleasing *)error {
    return [self DES:data operation:operation key:key vector:vector mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding) error:error];
}

@end


static CCCryptorRef XZDataCryptorContextMake(XZDataCryptorAlgorithm *algorithm, XZDataCryptorOperation operation, XZDataCryptorMode mode, XZDataCryptorPadding padding, NSError * _Nullable __autoreleasing *error) {
    NSString * const vector = algorithm.vector;
    NSString * const tweak  = nil; // tweak removed
    CCCryptorRef context = NULL;
    
    CCOperation const opt = operation;
    CCMode      const mod = mode;
    CCAlgorithm const alg = algorithm.rawValue;
    CCPadding   const pad = padding;
    const char *const vet = vector.UTF8String;
    const char *const key = algorithm.key.UTF8String;
    size_t      const kel = (size_t)algorithm.key.length;
    const char *const twk = tweak.UTF8String;
    size_t      const twl = tweak.length;
    int         const rnd = (int)algorithm.rounds;
    // kCCModeOptionCTR_BE 现在只支持 CTR Mode Big Endian - 大端 模式
    CCCryptorStatus status = CCCryptorCreateWithMode(opt, mod, alg, pad, vet, key, kel, twk, twl, rnd, kCCModeOptionCTR_BE, &context);
    // 这个过程只有参数错误和内存不足两种错误发生，因为参数已经经过校验，可以认为不会发生错误。
    XZDataCryptorHandleError(status, error);
    return context;
}

static NSString * _Nonnull NSStringFromCCCryptorStatus(CCCryptorStatus status) {
    switch (status) {
        case kCCSuccess:
            return @"kCCSuccess: Operation completed normally.";
        case kCCParamError:
            return @"kCCParamError: Illegal parameter value.";
        case kCCBufferTooSmall:
            return @"kCCBufferTooSmall: Insufficent buffer provided for specified operation.";
        case kCCMemoryFailure:
            return @"kCCMemoryFailure: Memory allocation failure.";
        case kCCAlignmentError:
            return @"kCCAlignmentError: Input size was not aligned properly.";
        case kCCDecodeError:
            return @"kCCDecodeError: Input data did not decode or decrypt properly.";
        case kCCUnimplemented:
            return @"kCCUnimplemented: Function not implemented for the current algorithm.";
        case kCCOverflow:
            return @"kCCOverflow";
        case kCCRNGFailure:
            return @"kCCRNGFailure";
        case kCCUnspecifiedError:
            return @"kCCUnspecifiedError";
        case kCCCallSequenceError:
            return @"kCCCallSequenceError";
        case kCCKeySizeError:
            return @"kCCKeySizeError";
        default:
            return @"Unknown";
    }
}

static BOOL XZDataCryptorHandleError(CCCryptorStatus status, NSError * _Nullable __autoreleasing * error) {
    if (status == kCCSuccess) {
        return NO;
    }
    if (error == NULL) {
        return YES;
    }
    NSDictionary * const userInfo = @{
        NSLocalizedFailureReasonErrorKey: NSStringFromCCCryptorStatus(status)
    };
    *error = [NSError errorWithDomain:NSCocoaErrorDomain code:status userInfo:userInfo];
    return YES;
}
