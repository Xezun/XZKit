//
//  XZCryptor.m
//  XZKit
//
//  Created by mlibai on 2018/2/6.
//  Copyright © 2018年 mlibai. All rights reserved.
//

#import "XZDataCryptor.h"
#import <CommonCrypto/CommonCryptor.h>

static inline CCOperation CCOperationFromXZDataCryptorOperation(XZDataCryptorOperation operation) {
    switch (operation) {
        case XZDataCryptorOperationEncrypt: return kCCEncrypt;
        case XZDataCryptorOperationDecrypt: return kCCDecrypt;
    }
}

static CCCryptorRef CCCryptorContextMake(XZDataCryptorAlgorithm *algorithm, XZDataCryptorOperation operation, XZDataCryptorMode *mode, XZDataCryptorPadding padding, NSError * _Nullable __autoreleasing *error);

static CCOptions CCOptionsFromXZDataCryptorPaddingWithMode(XZDataCryptorPadding padding, XZDataCryptorMode *mode);
/// 返回 NO 表示有错误，YES 表示没有错误。
static BOOL XZDataCryptorErrorHandler(CCCryptorStatus status, NSError * _Nullable __autoreleasing *error);

@implementation XZDataCryptor {
    CCCryptorRef _context;
}

- (void)dealloc {
    CCCryptorRelease(_context);
}

- (instancetype)initWithContext:(CCCryptorRef)context algorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding {
    self = [super init];
    if (self) {
        _context    = context;
        _algorithm  = algorithm;
        _operation  = operation;
        _mode       = mode;
        _padding    = padding;
    }
    return self;
}

+ (XZDataCryptor *)cryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    CCCryptorRef context = CCCryptorContextMake(algorithm, operation, mode, padding, error);
    if (context == NULL) {
        return nil;
    }
    return [(XZDataCryptor *)[self alloc] initWithContext:context algorithm:algorithm operation:operation mode:mode padding:padding];
}

+ (XZDataCryptor *)encryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    return [self cryptorWithAlgorithm:algorithm operation:(XZDataCryptorOperationEncrypt) mode:mode padding:padding error:error];
}

+ (XZDataCryptor *)decryptorWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    return [self cryptorWithAlgorithm:algorithm operation:(XZDataCryptorOperationDecrypt) mode:mode padding:padding error:error];
}

+ (XZDataCryptor *)AESCryptorWithOperation:(XZDataCryptorOperation)operation key:(NSString *)key vector:(NSString *)vector error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:key];
    XZDataCryptorMode * const mode = [XZDataCryptorMode CBCModeWithVector:vector];
    return [self cryptorWithAlgorithm:algorithm operation:operation mode:mode padding:(XZDataCryptorPKCS7Padding) error:error];
}

+ (XZDataCryptor *)DESCryptorWithOperation:(XZDataCryptorOperation)operation key:(NSString *)key vector:(NSString *)vector error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:key];
    XZDataCryptorMode * const mode = [XZDataCryptorMode CBCModeWithVector:vector];
    return [self cryptorWithAlgorithm:algorithm operation:operation mode:mode padding:(XZDataCryptorPKCS7Padding) error:error];
}

+ (NSData *)crypto:(NSData *)data algorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error {
    void *buffer = NULL;
    // 根据补齐规则加密后的数据不会超过此值。
    size_t bufferSize = data.length + algorithm.blockSize;
    CCOptions const options = CCOptionsFromXZDataCryptorPaddingWithMode(padding, mode);
    NSString * const vector = [mode vectorForAlgorithm:algorithm];
    
    CCCryptorStatus status = kCCBufferTooSmall;
    while (status == kCCBufferTooSmall) {
        buffer = realloc(buffer, bufferSize);
        status = CCCrypt(CCOperationFromXZDataCryptorOperation(operation), // 加密/解密
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
    
    if (!XZDataCryptorErrorHandler(status, error)) {
        free(buffer);
        return nil;
    }
    
    return [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
}

- (NSData *)crypto:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error {
    // 获取需要的内存
    size_t bufferSize = CCCryptorGetOutputLength(_context, data.length, false);
    // 开辟内存。第一次为新开辟，第二次调用就是拓展内存了。
    void *buffer = malloc(bufferSize);
    // 生成的数据的实际大小。
    size_t outputLength = 0;
    // 执行加密/解密。
    CCCryptorStatus status = CCCryptorUpdate(_context, data.bytes, data.length, buffer, bufferSize, &outputLength);
    if (!XZDataCryptorErrorHandler(status, error)) {
        free(buffer);
        return nil;
    }
    // 执行成功。
    return [NSData dataWithBytesNoCopy:buffer length:outputLength freeWhenDone:YES];
}

- (NSData *)finish:(NSError * _Nullable __autoreleasing *)error {
    // 流密码算法、noPadding 不需要调用 CCCryptorFinal 函数。
    // if (_padding == XZDataCryptorNoPadding || _algorithm.blockSize == 0) {
    //    return [NSData data];
    // }
    size_t bufferSize = CCCryptorGetOutputLength(_context, 0, true);
    void *buffer = malloc(bufferSize); // 如果 bufferSize = 0，malloc 函数的返回值不一定是 NULL 。
    size_t outputLength = 0;
    CCCryptorStatus status = CCCryptorFinal(_context, buffer, bufferSize, &outputLength);
    if (!XZDataCryptorErrorHandler(status, error)) {
        free(buffer);
        return nil;
    }
    return [NSData dataWithBytesNoCopy:buffer length:outputLength freeWhenDone:YES];
}

- (BOOL)reset:(NSError *__autoreleasing  _Nullable *)error {
    CCCryptorRelease(_context);
    _context = CCCryptorContextMake(_algorithm, _operation, _mode, _padding, error);
    return (_context != NULL);
}

- (BOOL)resetWithVector:(NSString *)vector error:(NSError *__autoreleasing  _Nullable *)error {
    if (vector != nil && ![_mode.vector isEqualToString:vector]) {
        _mode = [XZDataCryptorMode CBCModeWithVector:vector];
    }
    return XZDataCryptorErrorHandler(CCCryptorReset(_context, _mode.vector.UTF8String), error);
}

- (BOOL)resetWithAlgorithm:(XZDataCryptorAlgorithm *)algorithm operation:(XZDataCryptorOperation)operation mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable *)error {
    CCCryptorRef context = CCCryptorContextMake(algorithm, operation, mode, padding, error);
    if (context == nil) {
        return NO;
    }
    CCCryptorRelease(_context);
    _context   = context;
    _algorithm = algorithm;
    _operation = operation;
    _mode      = mode;
    _padding   = padding;
    return YES;
}


- (BOOL)cryptoByUsingBlock:(BOOL (^)(NSInteger, size_t (^ _Nonnull)(size_t), BOOL (^ _Nonnull)(void * _Nonnull, size_t, void * _Nonnull, size_t, size_t * _Nonnull), BOOL (^ _Nonnull)(void * _Nonnull, size_t, size_t * _Nonnull)))block error:(NSError *__autoreleasing  _Nullable *)error {
    
    size_t (^CryptoGetLength)(size_t) = ^(size_t dataInLength) {
        return CCCryptorGetOutputLength(self->_context, dataInLength, dataInLength == 0);
    };
    
    NSError * __block outputError;
    
    BOOL (^CryptoUpdate)(void * _Nullable, size_t, void * _Nullable, size_t, size_t * _Nullable) = ^(void *dataIn, size_t dataInLength, void *buffer, size_t bufferLength, size_t *dataOutLength) {
        if (dataIn != NULL) {
            return XZDataCryptorErrorHandler(CCCryptorUpdate(self->_context, dataIn, dataInLength, buffer, bufferLength, dataOutLength), &outputError);
        }
        return XZDataCryptorErrorHandler(CCCryptorFinal(self->_context, buffer, bufferLength, dataOutLength), &outputError);
    };
    
    BOOL (^CryptoFinish)(void * _Nonnull, size_t, size_t * _Nonnull) = ^(void * _Nonnull buffer, size_t bufferLength, size_t * _Nonnull dataOutLength) {
        return XZDataCryptorErrorHandler(CCCryptorFinal(self->_context, buffer, bufferLength, dataOutLength), &outputError);
    };
    
    for (NSInteger i = 0; block(i, CryptoGetLength, CryptoUpdate, CryptoFinish); i++) {
        if (outputError != nil) {
            if (error != NULL) {
                *error = outputError;
            }
            return NO;
        }
    }
    if (error != NULL) {
        *error = outputError;
    }
    return YES;
}

@end


@implementation XZDataCryptor (XZExtendedDataCryptor)


+ (nullable NSData *)encrypt:(NSData *)data usingAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    return [self crypto:data algorithm:algorithm operation:(XZDataCryptorOperationEncrypt) mode:mode padding:padding error:error];
}

+ (nullable NSData *)decrypt:(NSData *)data usingAlgorithm:(XZDataCryptorAlgorithm *)algorithm mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    return [self crypto:data algorithm:algorithm operation:(XZDataCryptorOperationDecrypt) mode:mode padding:padding error:error];
}

+ (nullable NSData *)AES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSString *)key mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm AESAlgorithmWithKey:key];
    return [self crypto:data algorithm:algorithm operation:operation mode:mode padding:padding error:error];
}

+ (nullable NSData *)DES:(NSData *)data operation:(XZDataCryptorOperation)operation key:(NSString *)key mode:(XZDataCryptorMode *)mode padding:(XZDataCryptorPadding)padding error:(NSError * _Nullable __autoreleasing *)error {
    XZDataCryptorAlgorithm * const algorithm = [XZDataCryptorAlgorithm DESAlgorithmWithKey:key];
    return [self crypto:data algorithm:algorithm operation:operation mode:mode padding:padding error:error];
}

@end




@implementation XZDataCryptorAlgorithm

- (instancetype)initWithRawValue:(CCAlgorithm)rawValue key:(NSString *)key blockSize:(size_t)blockSize contextSize:(size_t)contextSize numberOfRounds:(int)numberOfRounds {
    self = [super init];
    if (self) {
        _rawValue       = rawValue;
        _key            = [key copy];
        _blockSize      = blockSize;
        _contextSize    = contextSize;
        _numberOfRounds = numberOfRounds;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([super isEqual:object]) {
        return YES;
    }
    if ([object isKindOfClass:[XZDataCryptorAlgorithm class]]) {
        return (_rawValue == [(XZDataCryptorAlgorithm *)object rawValue]);
    }
    return NO;
}

+ (XZDataCryptorAlgorithm *)AESAlgorithmWithKey:(NSString *)key {
    return [self AESAlgorithmWithKey:key numberOfRounds:0];
}

+ (XZDataCryptorAlgorithm *)AESAlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds {
    NSInteger const length = key.length;
    switch (length) {
        case kCCKeySizeAES128: break;
        case kCCKeySizeAES192: break;
        case kCCKeySizeAES256: break;
        default:
            if (length < kCCKeySizeAES128) {
                key = [key stringByPaddingToLength:kCCKeySizeAES128 withString:@"\0" startingAtIndex:0];
            } else if (length < kCCKeySizeAES192) {
                key = [key stringByPaddingToLength:kCCKeySizeAES192 withString:@"\0" startingAtIndex:0];
            } else {
                key = [key stringByPaddingToLength:kCCKeySizeAES256 withString:@"\0" startingAtIndex:0];
            }
            break;
    }
    return [[XZDataCryptorAlgorithm alloc] initWithRawValue:kCCAlgorithmAES key:key blockSize:kCCBlockSizeAES128 contextSize:kCCContextSizeAES128 numberOfRounds:numberOfRounds];
}

+ (XZDataCryptorAlgorithm *)DESAlgorithmWithKey:(NSString *)key {
    return [self DESAlgorithmWithKey:key numberOfRounds:0];
}

+ (XZDataCryptorAlgorithm *)DESAlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds {
    key = [key stringByPaddingToLength:kCCKeySizeDES withString:@"\0" startingAtIndex:0];
    return [[XZDataCryptorAlgorithm alloc] initWithRawValue:kCCAlgorithmDES key:key blockSize:kCCBlockSizeDES contextSize:kCCContextSizeDES numberOfRounds:numberOfRounds];
}

+ (XZDataCryptorAlgorithm *)TripleDESAlgorithmWithKey:(NSString *)key {
    return [self TripleDESAlgorithmWithKey:key numberOfRounds:0];
}

+ (XZDataCryptorAlgorithm *)TripleDESAlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds {
    key = [key stringByPaddingToLength:kCCKeySize3DES withString:@"\0" startingAtIndex:0];
    return [[XZDataCryptorAlgorithm alloc] initWithRawValue:kCCAlgorithm3DES key:key blockSize:kCCBlockSize3DES contextSize:kCCContextSize3DES numberOfRounds:numberOfRounds];
}

+ (XZDataCryptorAlgorithm *)CASTAlgorithmWithKey:(NSString *)key {
    return [self CASTAlgorithmWithKey:key numberOfRounds:0];
}

+ (XZDataCryptorAlgorithm *)CASTAlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds {
    if (key.length < kCCKeySizeMinCAST) {
        key = [key stringByPaddingToLength:5 withString:@"\0" startingAtIndex:0];
    } else if (key.length > kCCKeySizeMaxCAST) {
        key = [key substringToIndex:kCCKeySizeMaxCAST];
    }
    return [[XZDataCryptorAlgorithm alloc] initWithRawValue:kCCAlgorithmCAST key:key blockSize:kCCBlockSizeCAST contextSize:kCCContextSizeCAST numberOfRounds:numberOfRounds];
}

+ (XZDataCryptorAlgorithm *)RC4AlgorithmWithKey:(NSString *)key {
    return [self RC4AlgorithmWithKey:key numberOfRounds:0];
}

+ (XZDataCryptorAlgorithm *)RC4AlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds {
    if (key.length < kCCKeySizeMinRC4) {
        key = @"\0";
    } else if (key.length > kCCKeySizeMaxRC4) {
        key = [key substringToIndex:kCCKeySizeMaxRC4];
    }
    return [[XZDataCryptorAlgorithm alloc] initWithRawValue:kCCAlgorithmRC4 key:key blockSize:0 contextSize:kCCContextSizeRC4 numberOfRounds:numberOfRounds];
}

+ (XZDataCryptorAlgorithm *)RC2AlgorithmWithKey:(NSString *)key {
    return [self RC2AlgorithmWithKey:key numberOfRounds:0];
}

+ (XZDataCryptorAlgorithm *)RC2AlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds {
    if (key.length < kCCKeySizeMinRC2) {
        key = @"\0";
    } else if (key.length > kCCKeySizeMaxRC2) {
        key = [key substringToIndex:kCCKeySizeMaxRC2];
    }
    return [[XZDataCryptorAlgorithm alloc] initWithRawValue:kCCAlgorithmRC2 key:key blockSize:kCCBlockSizeRC2 contextSize:0 numberOfRounds:numberOfRounds];
}

+ (XZDataCryptorAlgorithm *)BlowfishAlgorithmWithKey:(NSString *)key {
    return [self BlowfishAlgorithmWithKey:key numberOfRounds:0];
}

+ (XZDataCryptorAlgorithm *)BlowfishAlgorithmWithKey:(NSString *)key numberOfRounds:(int)numberOfRounds {
    if (key.length < kCCKeySizeMinBlowfish) { 
        key = [key stringByPaddingToLength:8 withString:@"\0" startingAtIndex:0];
    } else if (key.length > kCCKeySizeMaxBlowfish) {
        key = [key substringToIndex:kCCKeySizeMaxBlowfish];
    }
    return [[XZDataCryptorAlgorithm alloc] initWithRawValue:kCCAlgorithmBlowfish key:key blockSize:kCCBlockSizeBlowfish contextSize:0 numberOfRounds:numberOfRounds];
}

- (NSString *)description {
    switch (_rawValue) {
        case kCCAlgorithmAES:       return @"AES";
        case kCCAlgorithmDES:       return @"DES";
        case kCCAlgorithm3DES:      return @"3DES";
        case kCCAlgorithmCAST:      return @"CAST";
        case kCCAlgorithmRC4:       return @"RC4";
        case kCCAlgorithmRC2:       return @"RC2";
        case kCCAlgorithmBlowfish:  return @"Blowfish";
        default:                    return @"Unknown";
    }
}

@end


@implementation XZDataCryptorMode

- (instancetype)initWithRawValue:(NSInteger)rawValue vector:(NSString *)vector tweak:(NSString *)tweak {
    self = [super init];
    if (self) {
        _rawValue = rawValue;
        _vector = [vector copy];
        _tweak  = [vector copy];
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if ([super isEqual:object]) {
        return YES;
    }
    if ([object isKindOfClass:[XZDataCryptorMode class]]) {
        return (_rawValue == [(XZDataCryptorMode *)object rawValue]);
    }
    return NO;
}

- (NSString *)vectorForAlgorithm:(XZDataCryptorAlgorithm *)algorithm {
    if (_vector == nil) {
        return nil;
    }
    return [_vector stringByPaddingToLength:algorithm.blockSize withString:@"\0" startingAtIndex:0];
}

- (NSString *)tweakForAlgorithm:(XZDataCryptorAlgorithm *)algorithm {
    if (_tweak == nil) {
        return nil;
    }
    return [_tweak stringByPaddingToLength:algorithm.blockSize withString:@"\0" startingAtIndex:0];
}

- (NSString *)description {
    switch (_rawValue) {
        case kCCModeECB:    return @"ECB";
        case kCCModeCBC:    return @"CBC";
        case kCCModeCFB:    return @"CFB";
        case kCCModeCTR:    return @"CTR";
        case kCCModeOFB:    return @"OFB";
        case kCCModeRC4:    return @"RC4";
        case kCCModeCFB8:   return @"CFB8";
        default:            return @"Unkonwn";
    }
}

+ (XZDataCryptorMode *)ECBMode {
    return [[XZDataCryptorMode alloc] initWithRawValue:kCCModeECB vector:nil tweak:nil];
}

+ (XZDataCryptorMode *)CBCModeWithVector:(NSString *)vector {
    return [[XZDataCryptorMode alloc] initWithRawValue:kCCModeCBC vector:vector tweak:nil];
}

+ (XZDataCryptorMode *)CFBModeWithVector:(NSString *)vector {
    return [[XZDataCryptorMode alloc] initWithRawValue:kCCModeCFB vector:vector tweak:nil];
}

+ (XZDataCryptorMode *)CTRModeWithVector:(NSString *)vector {
    return [[XZDataCryptorMode alloc] initWithRawValue:kCCModeCTR vector:vector tweak:nil];
}

+ (XZDataCryptorMode *)OFBModeWithVector:(NSString *)vector {
    return [[XZDataCryptorMode alloc] initWithRawValue:kCCModeOFB vector:vector tweak:nil];
}

+ (XZDataCryptorMode *)RC4Mode {
    return [[XZDataCryptorMode alloc] initWithRawValue:kCCModeRC4 vector:nil tweak:nil];
}

+ (XZDataCryptorMode *)CFB8ModeWithVector:(NSString *)vector {
    return [[XZDataCryptorMode alloc] initWithRawValue:kCCModeCFB8 vector:vector tweak:nil];
}

@end


FOUNDATION_STATIC_INLINE CCOperation CCOperationFromOperation(XZDataCryptorOperation operation) {
    switch (operation) {
        case XZDataCryptorOperationDecrypt: return kCCDecrypt;
        case XZDataCryptorOperationEncrypt: return kCCEncrypt;
    }
}

FOUNDATION_STATIC_INLINE CCPadding CCPaddingFromPadding(XZDataCryptorPadding padding) {
    switch (padding) {
        case XZDataCryptorNoPadding:    return ccNoPadding;
        case XZDataCryptorPKCS7Padding: return ccPKCS7Padding;
    }
}


CCCryptorRef CCCryptorContextMake(XZDataCryptorAlgorithm *algorithm, XZDataCryptorOperation operation, XZDataCryptorMode *mode, XZDataCryptorPadding padding, NSError * _Nullable __autoreleasing *error) {
    NSString * const vector = [mode vectorForAlgorithm:algorithm];
    NSString * const tweak = [mode tweakForAlgorithm:algorithm];
    CCCryptorRef context = NULL;
    CCCryptorStatus status = CCCryptorCreateWithMode(CCOperationFromOperation(operation),
                                                     (CCMode)mode.rawValue,
                                                     (CCAlgorithm)algorithm.rawValue,
                                                     CCPaddingFromPadding(padding),
                                                     vector.UTF8String,
                                                     algorithm.key.UTF8String,
                                                     algorithm.key.length,
                                                     tweak.UTF8String,
                                                     tweak.length,
                                                     algorithm.numberOfRounds,
                                                     0,
                                                     &context);
    if (!XZDataCryptorErrorHandler(status, error)) {
        return nil;
    }
    return context;
}

CCOptions CCOptionsFromXZDataCryptorPaddingWithMode(XZDataCryptorPadding padding, XZDataCryptorMode *mode) {
    CCOptions options = (padding == XZDataCryptorPKCS7Padding ? kCCOptionPKCS7Padding : 0);
    if (mode.rawValue == kCCModeECB) {
        options = options | kCCOptionECBMode;
    }
    return options;
}


static NSString * _Nonnull NSStringFromCCCryptorStatus(CCCryptorStatus status) {
    switch (status) {
        case kCCSuccess:           return @"kCCSuccess: Operation completed normally.";
        case kCCParamError:        return @"kCCParamError: Illegal parameter value.";
        case kCCBufferTooSmall:    return @"kCCBufferTooSmall: Insufficent buffer provided for specified operation.";
        case kCCMemoryFailure:     return @"kCCMemoryFailure: Memory allocation failure.";
        case kCCAlignmentError:    return @"kCCAlignmentError: Input size was not aligned properly.";
        case kCCDecodeError:       return @"kCCDecodeError: Input data did not decode or decrypt properly.";
        case kCCUnimplemented:     return @"kCCUnimplemented: Function not implemented for the current algorithm.";
        case kCCOverflow:          return @"kCCOverflow";
        case kCCRNGFailure:        return @"kCCRNGFailure";
        case kCCUnspecifiedError:  return @"kCCUnspecifiedError";
        case kCCCallSequenceError: return @"kCCCallSequenceError";
        case kCCKeySizeError:      return @"kCCKeySizeError";
        default:                   return @"Unknown";
    }
}

BOOL XZDataCryptorErrorHandler(CCCryptorStatus status, NSError * _Nullable __autoreleasing * error) {
    if (status == kCCSuccess) {
        return YES;
    }
    if (error == NULL) {
        return NO;
    }
    *error = [NSError errorWithDomain:NSCocoaErrorDomain code:status userInfo:@{NSLocalizedDescriptionKey: NSStringFromCCCryptorStatus(status)}];
    return NO;
}
