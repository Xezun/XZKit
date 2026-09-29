//
//  XZDataCryptor.m
//  XZKit
//
//  Created by Xezun on 2018/2/6.
//  Copyright © 2018年 Xezun Individual. All rights reserved.
//

#import "XZDataCryptor.h"
#import <CommonCrypto/CommonCryptor.h>

/// 返回 YES 表示有错误，NO 表示没有错误。
static BOOL XZDataCryptorHandleError(CCCryptorStatus status, NSError **error);
/// 构造 CCCryptorRef 的方法。
static CCCryptorRef _Nullable XZDataCryptorContextMake(XZDataCryptorAlgorithm *algorithm, XZDataCryptorOperation operation, XZDataCryptorMode mode, XZDataCryptorPadding padding, NSError **error);
static NSData * _Nullable XZDataCryptorCrypt(NSData *data, XZDataCryptorAlgorithm *algorithm, XZDataCryptorOperation operation, XZDataCryptorMode mode, XZDataCryptorPadding padding, NSError **error);

@implementation XZDataCryptor {
    CCCryptorRef _context;
}

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

- (void)dealloc {
    CCCryptorRelease(_context);
}

- (instancetype)initWithContext:(CCCryptorRef)context algorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding {
    self = [super init];
    if (self) {
        _context   = context;
        _algorithm = algorithm.copy;
        _operation = operation;
        _mode      = mode;
        _padding   = padding;
    }
    return self;
}

+ (nullable instancetype)cryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError **)error {
    CCCryptorRef const context = XZDataCryptorContextMake(algorithm, operation, mode, padding, error);
    if (context == NULL) {
        return nil;
    }
    return [[self alloc] initWithContext:context algorithm:algorithm operation:operation mode:mode padding:padding];
}

+ (nullable instancetype)cryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation error:(NSError **)error {
    return [self cryptorWithAlgorithm:algorithm operation:operation mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding) error:error];
}

- (NSData *)cryptBytes:(const void *)bytes length:(NSUInteger)length error:(NSError **)error {
    NSParameterAssert(bytes != NULL);
    // 空上下文直接报参数错误，CommonCrypto 内部会直接解引用上下文指针。
    if (_context == NULL) {
        XZDataCryptorHandleError(kCCParamError, error);
        return nil;
    }
    // 获取需要的内存大小
    void *buffer = NULL;
    size_t bufferSize = CCCryptorGetOutputLength(_context, length, false);
    // 申请分配内存。块加密在数据不满一块时没有输出，没有输出就不申请内存了。
    if (bufferSize > 0) {
        buffer = malloc(bufferSize);
        if (buffer == NULL) {
            XZDataCryptorHandleError(kCCMemoryFailure, error);
            return nil;
        }
    }
    // 生成的数据的实际大小。
    size_t outputLength = 0;
    // 执行加密/解密。
    CCCryptorStatus status = CCCryptorUpdate(_context, bytes, length, buffer, bufferSize, &outputLength);
    // 检查状态，是否发生错误
    if (XZDataCryptorHandleError(status, error)) {
        free(buffer); // free(NULL) 是安全的
        return nil;
    }
    // 本次无输出（数据被缓存），释放缓冲区返回空数据。
    if (outputLength == 0) {
        free(buffer);
        return [NSData data];
    }
    // 成功返回数据
    return [NSData dataWithBytesNoCopy:buffer length:outputLength freeWhenDone:YES];
}

- (NSData *)cryptData:(NSData *)data error:(NSError **)error {
    if (data == nil) {
        return NSData.data;
    }
    
    if (data.length == 0) {
        return data;
    }
        
    return [self cryptBytes:data.bytes length:data.length error:error];
}

- (NSData *)final:(NSError *__autoreleasing  _Nullable *)error {
    // 空上下文直接报参数错误，CommonCrypto 内部会直接解引用上下文指针。
    if (_context == NULL) {
        XZDataCryptorHandleError(kCCParamError, error);
        return nil;
    }
    
    void *buffer = NULL;
    size_t const bufferSize = CCCryptorGetOutputLength(_context, 0, true);
    if (bufferSize > 0) {
        buffer = malloc(bufferSize);
        if (buffer == NULL) {
            XZDataCryptorHandleError(kCCMemoryFailure, error);
            return nil;
        }
    }
    
    size_t outputLength = 0;
    CCCryptorStatus status = CCCryptorFinal(_context, buffer, bufferSize, &outputLength);
    
    // 发生错误
    if (XZDataCryptorHandleError(status, error)) {
        free(buffer);
        return nil;
    }
    
    // 无补齐输出时释放缓冲区返回空数据，避免接管 0 长缓冲。
    if (outputLength == 0) {
        free(buffer);
        return [NSData data];
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:outputLength freeWhenDone:YES];
}

- (BOOL)resetWithKey:(NSData *)key vector:(NSData *)vector error:(NSError **)error {
    // 在 algorithm 副本上应用新的密钥与向量，构建成功后再提交，
    // 避免构建失败时 _algorithm 已更新而 _context 仍是旧密钥导致的状态不一致。
    XZDataCryptorAlgorithm *algorithm = _algorithm.copy;
    algorithm.key    = key;
    algorithm.vector = vector;

    CCCryptorRef const context = XZDataCryptorContextMake(algorithm, _operation, _mode, _padding, error);
    if (context == NULL) {
        return NO;
    }
    CCCryptorRelease(_context);
    _context   = context;
    _algorithm = algorithm;
    return YES;
}

- (BOOL)resetWithVector:(NSData *)vector error:(NSError **)error {
    XZDataCryptorAlgorithm *algorithm = _algorithm.copy;
    algorithm.vector = vector;

    // CCCryptorReset 只支持 CBC 模式，且只更换向量不重建上下文；失败则回退到重建。
    // 与 -update:.../-final: 一致，空上下文不可交给 CommonCrypto 解引用。
    // 注意 _mode 是 XZDataCryptorMode，不能直接与 CommonCrypto 的 CCMode 常量比较。
    if (_mode == XZDataCryptorModeCBC && _context != NULL) {
        // 这里只判断状态，不写入 error：失败时继续走下面的重建路径统一产出错误，
        // 避免重建成功后仍残留快路径失败导致的 error，违反"返回 YES 则无错误"的约定。
        if (CCCryptorReset(_context, algorithm.vector.bytes) == kCCSuccess) {
            _algorithm = algorithm;
            return YES;
        }
        // 重置失败，尝试重建
    }

    CCCryptorRef const context = XZDataCryptorContextMake(algorithm, _operation, _mode, _padding, error);
    if (context == NULL) {
        return NO;
    }
    CCCryptorRelease(_context);
    _context   = context;
    _algorithm = algorithm;
    return YES;
}

@end


static inline CCOptions CCOptionsMake(XZDataCryptorPadding padding, CCMode mode) {
    CCOptions options = (padding == XZDataCryptorPKCS7Padding ? kCCOptionPKCS7Padding : 0);
    if (mode == kCCModeECB) {
        options = options | kCCOptionECBMode;
    }
    return options;
}

@implementation XZDataCryptor (XZExtendedDataCryptor)

+ (NSData *)encrypt:(NSData *)data algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable *)error {
    return XZDataCryptorCrypt(data, algorithm, XZDataCryptorOperationEncrypt, mode, padding, error);
}

+ (NSData *)decrypt:(NSData *)data algorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable *)error {
    return XZDataCryptorCrypt(data, algorithm, XZDataCryptorOperationDecrypt, mode, padding, error);
}

@end


@implementation XZDataCryptor (XZAESDataCryptor)

+ (nullable instancetype)AESCryptor:(XZDataCryptorOperation)operation key:(NSData *)key vector:(nullable NSData *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError **)error {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:vector];
    return [self cryptorWithAlgorithm:algorithm operation:operation mode:mode padding:padding error:error];
}

+ (nullable instancetype)AESCryptor:(XZDataCryptorOperation)operation key:(NSData *)key vector:(nullable NSData *)vector error:(NSError **)error {
    return [self AESCryptor:operation key:key vector:vector mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding) error:error];
}

+ (NSData *)AES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSData *)key vector:(NSData *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable *)error {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:key vector:vector];
    return XZDataCryptorCrypt(data, algorithm, operation, mode, padding, error);
}

+ (NSData *)AES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSData *)key vector:(NSData *)vector error:(NSError *__autoreleasing  _Nullable *)error {
    return [self AES:data operation:operation key:key vector:vector mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding) error:error];
}

@end


@implementation XZDataCryptor (XZDESDataCryptor)

+ (nullable instancetype)DESCryptor:(XZDataCryptorOperation)operation key:(NSData *)key vector:(nullable NSData *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError **)error {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm DESAlgorithmWithKey:key vector:vector];
    return [self cryptorWithAlgorithm:algorithm operation:operation mode:mode padding:padding error:error];
}

+ (nullable instancetype)DESCryptor:(XZDataCryptorOperation)operation key:(NSData *)key vector:(nullable NSData *)vector error:(NSError **)error {
    return [self DESCryptor:operation key:key vector:vector mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding) error:error];
}

+ (nullable NSData *)DES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSData *)key vector:(nullable NSData *)vector mode:(XZDataCryptorMode)mode padding:(XZDataCryptorPadding)padding error:(NSError **)error {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm DESAlgorithmWithKey:key vector:vector];
    return XZDataCryptorCrypt(data, algorithm, operation, mode, padding, error);
}

+ (nullable NSData *)DES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSData *)key vector:(nullable NSData *)vector error:(NSError **)error {
    return [self DES:data operation:operation key:key vector:vector mode:(XZDataCryptorModeCBC) padding:(XZDataCryptorPKCS7Padding) error:error];
}

@end


static inline CCOperation CCOperationFromXZDataCryptorOperation(XZDataCryptorOperation operation) {
    switch (operation) {
        case XZDataCryptorOperationDecrypt:
            return kCCDecrypt;
        case XZDataCryptorOperationEncrypt:
            return kCCEncrypt;
    }
}

static inline CCPadding CCPaddingFromXZDataCryptorPadding(XZDataCryptorPadding padding) {
    switch (padding) {
        case XZDataCryptorNoPadding:
            return ccNoPadding;
        case XZDataCryptorPKCS7Padding:
            return ccPKCS7Padding;
    }
}

// RC4 模式仅 RC4 算法可用。
static inline CCMode CCModeFromXZDataCryptorMode(XZDataCryptorAlgorithm *algorithm, XZDataCryptorMode mode) {
    switch (mode) {
        case XZDataCryptorModeECB:
            return kCCModeECB;
        case XZDataCryptorModeCBC:
            return kCCModeCBC;
        case XZDataCryptorModeCFB:
            return kCCModeCFB;
        case XZDataCryptorModeCTR:
            return kCCModeCTR;
        case XZDataCryptorModeOFB:
            return kCCModeOFB;
        case XZDataCryptorModeRC4:
            if (algorithm.rawValue == kCCAlgorithmRC4) {
                return kCCModeRC4;
            }
            return kCCModeECB;
        case XZDataCryptorModeCFB8:
            return kCCModeCFB8;
    }
}

static CCCryptorRef XZDataCryptorContextMake(XZDataCryptorAlgorithm *algorithm, XZDataCryptorOperation operation, XZDataCryptorMode mode, XZDataCryptorPadding padding, NSError **error) {
    // 密钥与初始化向量
    const void * const key       = algorithm.key.bytes;
    NSUInteger   const keyLength = algorithm.key.length;
    const void * const vector    = algorithm.vector.bytes;
    
    CCCryptorRef context = NULL;
    CCCryptorStatus const status = CCCryptorCreateWithMode(
        (CCOperation)operation,
        CCModeFromXZDataCryptorMode(algorithm, mode),
        (CCAlgorithm)algorithm.rawValue,
        CCPaddingFromXZDataCryptorPadding(padding),
        vector,                         // 初始化向量
        key, keyLength,                 // 密钥及其字节长度
        NULL, 0,                        // 不支持 tweak
        (int)algorithm.rounds,          // 加密轮数，0 表示算法默认值
        kCCModeOptionCTR_BE, &context   // 仅 CTR 模式生效
    );
    
    // > Possible error returns are kCCParamError and kCCMemoryFailure.
    // 根据 CCCryptorCreateWithMode 的函数说明，失败的原因可能为参数错误或内存不足。
    // 由于参数的合法性校验，已经由 XZDataCryptorAlgorithm 和 XZDataCryptor 进行了保证，
    // 而内存不足的情况，对于现代设备来说，基本可以忽略。
    if (XZDataCryptorHandleError(status, error)) {
        return NULL;
    }
    
    return context;
}

static NSData * _Nullable XZDataCryptorCrypt(NSData *data, XZDataCryptorAlgorithm *algorithm, XZDataCryptorOperation operation, XZDataCryptorMode mode, XZDataCryptorPadding padding, NSError **error) {
    // CCCrypt 只支持 ECB、CBC（以及不要求模式的 RC4），
    // 传入 CFB/CTR/OFB/CFB8 会被静默降级成 CBC，产出的密文与流式接口不一致且无法解密，
    // 因此必须在入口处显式报错，需要这些模式时使用 XZDataCryptor 实例。
    if (mode != XZDataCryptorModeECB && mode != XZDataCryptorModeCBC && mode != XZDataCryptorModeRC4) {
        XZDataCryptorHandleError(kCCUnimplemented, error);
        return nil;
    }
    
    // 密钥与初始化向量
    const void * const key       = algorithm.key.bytes;
    NSUInteger   const keyLength = algorithm.key.length;
    const void * const vector    = algorithm.vector.bytes;
    
    // 模式
    CCOptions const options = CCOptionsMake(padding, CCModeFromXZDataCryptorMode(algorithm, mode));
    
    // 根据补齐规则，直接分配所需的最大内存。
    void *buffer = NULL;
    size_t bufferSize = data.length + algorithm.blockSize;
    
    CCCryptorStatus status = kCCBufferTooSmall;
    while (status == kCCBufferTooSmall) {
        buffer = realloc(buffer, bufferSize);
        // 内存分配失败
        if (buffer == NULL) {
            XZDataCryptorHandleError(kCCMemoryFailure, error);
            return nil;
        }
        status = CCCrypt(
            CCOperationFromXZDataCryptorOperation(operation), // 加密/解密
            (CCAlgorithm)algorithm.rawValue,    // 算法
            options,                            // 模式与填充方式，只支持 ECB 、CBC（noPadding/PKCS7Padding）。
            key,                                // 密钥
            keyLength,                          // 密钥长度
            vector,                             // 初始化向量
            data.bytes,                         // 输入的数据
            data.length,                        // 数据长度
            buffer,                             // 数据输出缓冲区
            bufferSize,                         // 缓冲区大小
            &bufferSize                         // 输出的数据的实际大小
        );
    }
    
    if (XZDataCryptorHandleError(status, error)) {
        free(buffer);
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
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

static BOOL XZDataCryptorHandleError(CCCryptorStatus status, NSError ** error) {
    if (status == kCCSuccess) {
        return NO;
    }
    if (error == NULL) {
        return YES;
    }
    NSDictionary * const userInfo = @{
        NSLocalizedFailureReasonErrorKey: NSStringFromCCCryptorStatus(status)
    };
    *error = [NSError errorWithDomain:XZDataCryptorErrorDomain code:status userInfo:userInfo];
    return YES;
}
