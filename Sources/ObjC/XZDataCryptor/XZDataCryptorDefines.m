//
//  XZDataCryptorDefines.m
//  XZKit
//
//  Created by Xezun on 2021/2/15.
//

#import <CommonCrypto/CommonCryptor.h>
#import "XZDataCryptorDefines.h"
#import "NSString+XZHexEncoding.h"

NSErrorDomain const XZDataCryptorErrorDomain = @"XZDataCryptorErrorDomain";

/// 将密钥规范化为算法要求的 UTF-8 字节长度，nil 亦产出合法的密钥。
static NSData * _Nonnull XZDataCryptorCanonicalKey(NSData * _Nullable key, CCAlgorithm algorithm);
/// 将初始化向量规范化为块大小，nil 亦产出合法的向量。
static NSData * _Nonnull XZDataCryptorCanonicalVector(NSData * _Nullable vector, size_t blockSize);

@implementation XZDataCryptorAlgorithm

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

- (instancetype)initWithRawValue:(NSInteger)rawValue blockSize:(NSInteger)blockSize contextSize:(NSInteger)contextSize key:(nullable NSData *)key vector:(nullable NSData *)vector rounds:(NSInteger)rounds {
    self = [super init];
    if (self) {
        _rawValue    = rawValue;
        _blockSize   = blockSize;
        _contextSize = contextSize;
        _rounds      = MAX(0, rounds);
        _key         = key ? XZDataCryptorCanonicalKey(key, (CCAlgorithm)rawValue).copy : nil;
        _vector      = vector ? XZDataCryptorCanonicalVector(vector, (size_t)blockSize).copy : nil;
    }
    return self;
}

@synthesize key = _key;

- (NSData *)key {
    if (_key == nil) {
        _key = XZDataCryptorCanonicalKey(nil, (CCAlgorithm)self.rawValue).copy;
    }
    return _key;
}

- (void)setKey:(NSData *)key {
    _key = key ? XZDataCryptorCanonicalKey(key, (CCAlgorithm)self.rawValue).copy : nil;
}

@synthesize vector = _vector;

- (NSData *)vector {
    if (_vector == nil) {
        _vector = XZDataCryptorCanonicalVector(nil, self.blockSize).copy;
    }
    return _vector;
}

- (void)setVector:(NSData *)vector {
    _vector = vector ? XZDataCryptorCanonicalVector(vector, self.blockSize).copy : nil;
}

// 十六进制

- (NSString *)hexEncodedKey {
    return self.key.xz_hexEncodedString;
}

- (void)setHexEncodedKey:(NSString *)hexEncodedKey {
    self.key = [NSData xz_dataWithHexEncodedString:hexEncodedKey];
}

- (NSString *)hexEncodedVector {
    return self.vector.xz_hexEncodedString;
}

- (void)setHexEncodedVector:(NSString *)hexEncodedVector {
    self.vector = [NSData xz_dataWithHexEncodedString:hexEncodedVector];
}

// base64

- (NSString *)base64EncodedKey {
    return [self.key base64EncodedStringWithOptions:0];
}

- (void)setBase64EncodedKey:(NSString *)base64EncodedKey {
    self.key = base64EncodedKey ? [[NSData alloc] initWithBase64EncodedString:base64EncodedKey options:0] : nil;
}

- (NSString *)base64EncodedVector {
    return [self.vector base64EncodedStringWithOptions:0];
}

- (void)setBase64EncodedVector:(NSString *)base64EncodedVector {
    self.vector = base64EncodedVector ? [[NSData alloc] initWithBase64EncodedString:base64EncodedVector options:0] : nil;
}

- (void)setRounds:(NSInteger)rounds {
    if (_rounds != rounds) {
        _rounds = MAX(0, rounds);
    }
}

+ (XZDataCryptorAlgorithm *)algorithm:(CCAlgorithm)algorithm blockSize:(size_t)blockSize contextSize:(size_t)contextSize key:(NSData *)key vector:(NSData *)vector {
    return [[self alloc] initWithRawValue:algorithm blockSize:blockSize contextSize:contextSize key:key vector:vector rounds:0];
}

+ (XZDataCryptorAlgorithm *)AESAlgorithm {
    return [self algorithm:kCCAlgorithmAES blockSize:kCCBlockSizeAES128 contextSize:kCCContextSizeAES128 key:nil vector:nil];
}

+ (XZDataCryptorAlgorithm *)AESAlgorithmWithKey:(NSData *)key vector:(NSData *)vector {
    return [self algorithm:kCCAlgorithmAES blockSize:kCCBlockSizeAES128 contextSize:kCCContextSizeAES128 key:key vector:vector];
}

+ (XZDataCryptorAlgorithm *)AESAlgorithmWithHexEncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = [NSData xz_dataWithHexEncodedString:key];
    NSData * const dataVector = [NSData xz_dataWithHexEncodedString:vector];
    return [self algorithm:kCCAlgorithmAES blockSize:kCCBlockSizeAES128 contextSize:kCCContextSizeAES128 key:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)AESAlgorithmWithBase64EncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = key ? [[NSData alloc] initWithBase64EncodedString:key options:0] : nil;
    NSData * const dataVector = vector ? [[NSData alloc] initWithBase64EncodedString:vector options:0] : nil;
    return [self AESAlgorithmWithKey:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)DESAlgorithm {
    return [self algorithm:kCCAlgorithmDES blockSize:kCCBlockSizeDES contextSize:kCCContextSizeDES key:nil vector:nil];
}

+ (XZDataCryptorAlgorithm *)DESAlgorithmWithKey:(NSData *)key vector:(NSData *)vector {
    return [self algorithm:kCCAlgorithmDES blockSize:kCCBlockSizeDES contextSize:kCCContextSizeDES key:key vector:vector];
}

+ (XZDataCryptorAlgorithm *)DESAlgorithmWithHexEncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = [NSData xz_dataWithHexEncodedString:key];
    NSData * const dataVector = [NSData xz_dataWithHexEncodedString:vector];
    return [self algorithm:kCCAlgorithmDES blockSize:kCCBlockSizeDES contextSize:kCCContextSizeDES key:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)DESAlgorithmWithBase64EncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = key ? [[NSData alloc] initWithBase64EncodedString:key options:0] : nil;
    NSData * const dataVector = vector ? [[NSData alloc] initWithBase64EncodedString:vector options:0] : nil;
    return [self DESAlgorithmWithKey:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)tripleDESAlgorithm {
    return [self algorithm:kCCAlgorithm3DES blockSize:kCCBlockSize3DES contextSize:kCCContextSize3DES key:nil vector:nil];
}

+ (XZDataCryptorAlgorithm *)tripleDESAlgorithmWithKey:(NSData *)key vector:(NSData *)vector {
    return [self algorithm:kCCAlgorithm3DES blockSize:kCCBlockSize3DES contextSize:kCCContextSize3DES key:key vector:vector];
}

+ (XZDataCryptorAlgorithm *)tripleDESAlgorithmWithHexEncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = [NSData xz_dataWithHexEncodedString:key];
    NSData * const dataVector = [NSData xz_dataWithHexEncodedString:vector];
    return [self algorithm:kCCAlgorithm3DES blockSize:kCCBlockSize3DES contextSize:kCCContextSize3DES key:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)tripleDESAlgorithmWithBase64EncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = key ? [[NSData alloc] initWithBase64EncodedString:key options:0] : nil;
    NSData * const dataVector = vector ? [[NSData alloc] initWithBase64EncodedString:vector options:0] : nil;
    return [self tripleDESAlgorithmWithKey:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)CASTAlgorithm {
    return [self algorithm:kCCAlgorithmCAST blockSize:kCCBlockSizeCAST contextSize:kCCContextSizeCAST key:nil vector:nil];
}

+ (XZDataCryptorAlgorithm *)CASTAlgorithmWithKey:(NSData *)key vector:(NSData *)vector {
    return [self algorithm:kCCAlgorithmCAST blockSize:kCCBlockSizeCAST contextSize:kCCContextSizeCAST key:key vector:vector];
}

+ (XZDataCryptorAlgorithm *)CASTAlgorithmWithHexEncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = [NSData xz_dataWithHexEncodedString:key];
    NSData * const dataVector = [NSData xz_dataWithHexEncodedString:vector];
    return [self algorithm:kCCAlgorithmCAST blockSize:kCCBlockSizeCAST contextSize:kCCContextSizeCAST key:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)CASTAlgorithmWithBase64EncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = key ? [[NSData alloc] initWithBase64EncodedString:key options:0] : nil;
    NSData * const dataVector = vector ? [[NSData alloc] initWithBase64EncodedString:vector options:0] : nil;
    return [self CASTAlgorithmWithKey:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)RC2Algorithm {
    return [self algorithm:kCCAlgorithmRC2 blockSize:kCCBlockSizeRC2 contextSize:0 key:nil vector:nil];
}

+ (XZDataCryptorAlgorithm *)RC2AlgorithmWithKey:(NSData *)key vector:(NSData *)vector {
    return [self algorithm:kCCAlgorithmRC2 blockSize:kCCBlockSizeRC2 contextSize:0 key:key vector:vector];
}

+ (XZDataCryptorAlgorithm *)RC2AlgorithmWithHexEncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = [NSData xz_dataWithHexEncodedString:key];
    NSData * const dataVector = [NSData xz_dataWithHexEncodedString:vector];
    return [self algorithm:kCCAlgorithmRC2 blockSize:kCCBlockSizeRC2 contextSize:0 key:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)RC2AlgorithmWithBase64EncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = key ? [[NSData alloc] initWithBase64EncodedString:key options:0] : nil;
    NSData * const dataVector = vector ? [[NSData alloc] initWithBase64EncodedString:vector options:0] : nil;
    return [self RC2AlgorithmWithKey:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)RC4Algorithm {
    return [self algorithm:kCCAlgorithmRC4 blockSize:kCCBlockSizeRC2 contextSize:kCCContextSizeRC4 key:nil vector:nil];
}

+ (XZDataCryptorAlgorithm *)RC4AlgorithmWithKey:(NSData *)key vector:(NSData *)vector {
    // RC4 与 RC2 使用相同的块大小
    return [self algorithm:kCCAlgorithmRC4 blockSize:kCCBlockSizeRC2 contextSize:kCCContextSizeRC4 key:key vector:vector];
}

+ (XZDataCryptorAlgorithm *)RC4AlgorithmWithHexEncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = [NSData xz_dataWithHexEncodedString:key];
    NSData * const dataVector = [NSData xz_dataWithHexEncodedString:vector];
    // RC4 与 RC2 使用相同的块大小
    return [self algorithm:kCCAlgorithmRC4 blockSize:kCCBlockSizeRC2 contextSize:kCCContextSizeRC4 key:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)RC4AlgorithmWithBase64EncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = key ? [[NSData alloc] initWithBase64EncodedString:key options:0] : nil;
    NSData * const dataVector = vector ? [[NSData alloc] initWithBase64EncodedString:vector options:0] : nil;
    return [self RC4AlgorithmWithKey:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)BlowfishAlgorithm {
    return [self algorithm:kCCAlgorithmBlowfish blockSize:kCCBlockSizeBlowfish contextSize:0 key:nil vector:nil];
}

+ (XZDataCryptorAlgorithm *)BlowfishAlgorithmWithKey:(NSData *)key vector:(NSData *)vector {
    return [self algorithm:kCCAlgorithmBlowfish blockSize:kCCBlockSizeBlowfish contextSize:0 key:key vector:vector];
}

+ (XZDataCryptorAlgorithm *)BlowfishAlgorithmWithHexEncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = [NSData xz_dataWithHexEncodedString:key];
    NSData * const dataVector = [NSData xz_dataWithHexEncodedString:vector];
    return [self algorithm:kCCAlgorithmBlowfish blockSize:kCCBlockSizeBlowfish contextSize:0 key:dataKey vector:dataVector];
}

+ (XZDataCryptorAlgorithm *)BlowfishAlgorithmWithBase64EncodedKey:(NSString *)key vector:(NSString *)vector {
    NSData * const dataKey = key ? [[NSData alloc] initWithBase64EncodedString:key options:0] : nil;
    NSData * const dataVector = vector ? [[NSData alloc] initWithBase64EncodedString:vector options:0] : nil;
    return [self BlowfishAlgorithmWithKey:dataKey vector:dataVector];
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[XZDataCryptorAlgorithm class]]) {
        return NO;
    }
    return self.rawValue == ((XZDataCryptorAlgorithm *)object).rawValue;
}

- (NSUInteger)hash {
    return self.rawValue;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[XZDataCryptorAlgorithm alloc] initWithRawValue:_rawValue blockSize:_blockSize contextSize:_contextSize key:_key vector:_vector rounds:_rounds];
}

- (NSString *)description {
    NSString *algorithm = nil;
    switch (self.rawValue) {
        case kCCAlgorithmAES:
            algorithm = @"AES";
            break;
        case kCCAlgorithmDES:
            algorithm = @"DES";
            break;
        case kCCAlgorithm3DES:
            algorithm = @"3DES";
            break;
        case kCCAlgorithmCAST:
            algorithm = @"CAST";
            break;
        case kCCAlgorithmRC4:
            algorithm = @"RC4";
            break;
        case kCCAlgorithmRC2:
            algorithm = @"RC2";
            break;
        case kCCAlgorithmBlowfish:
            algorithm = @"Blowfish";
            break;
        default:
            algorithm = @"Unknown";
            break;
    }
    NSString * const key    = self.key.xz_hexEncodedString;
    NSString * const vector = self.vector.xz_hexEncodedString ?: @"";
    NSInteger  const rounds = self.rounds;
    return [NSString stringWithFormat:@"<%@: %p, name: %@, key: %@, vector: %@, rounds: %ld>", self.class, self, algorithm, key, vector, rounds];
}

@end


FOUNDATION_STATIC_INLINE NSData * XZDataCryptorMakeData(NSData *data, NSUInteger length, NSUInteger newLength) {
    if (data == nil || length == 0) {
        void *bytes = calloc(newLength, sizeof(char));
        return [[NSData alloc] initWithBytesNoCopy:(void *)bytes length:newLength freeWhenDone:YES];
    }
    
    if (length == newLength) {
        return data.copy;
    }
    
    if (length > newLength) {
        return [data subdataWithRange:NSMakeRange(0, newLength)].copy;
    }
    
    NSUInteger const delta = newLength - length;
    void *bytes = calloc(delta, sizeof(char));
    
    NSMutableData *dataM = [NSMutableData dataWithData:data];
    [dataM appendBytes:bytes length:delta];
    free(bytes);
    
    return dataM.copy;
}

static NSData * _Nonnull XZDataCryptorCanonicalKey(NSData *key, CCAlgorithm algorithm) {
    // 类型检查
    if (key) {
        if ([key isKindOfClass:NSString.class]) {
            key = [(NSString *)key dataUsingEncoding:NSUTF8StringEncoding];
        } else if (![key isKindOfClass:NSData.class]) {
            key = nil;
        }
    }
    
    // 取出 Unicode 字节数
    NSUInteger const length = [key length];
    
    // 密钥长度
    NSUInteger newLength = 0;
    switch (algorithm) {
        case kCCAlgorithmAES: {
            // AES 只支持 16/24/32 字节密钥，按字节长度就近取较大的密钥长度。
            if (length > kCCKeySizeAES192) {
                newLength = kCCKeySizeAES256;
            } else if (length > kCCKeySizeAES128) {
                newLength = kCCKeySizeAES192;
            } else {
                newLength = kCCKeySizeAES128;
            }
            break;
        }
        case kCCAlgorithmDES:
            newLength = kCCKeySizeDES;
            break;
        case kCCAlgorithm3DES:
            newLength = kCCKeySize3DES;
            break;
        case kCCAlgorithmCAST:
            newLength = MIN(MAX(length, kCCKeySizeMinCAST), kCCKeySizeMaxCAST);
            break;
        case kCCAlgorithmRC4:
            newLength = MIN(MAX(length, kCCKeySizeMinRC4), kCCKeySizeMaxRC4);
            break;
        case kCCAlgorithmRC2:
            newLength = MIN(MAX(length, kCCKeySizeMinRC2), kCCKeySizeMaxRC2);
            break;
        case kCCAlgorithmBlowfish:
            newLength = MIN(MAX(length, kCCKeySizeMinBlowfish), kCCKeySizeMaxBlowfish);
            break;
        default:
            @throw [NSException exceptionWithName:NSGenericException reason:@"Not Supported Algorithm" userInfo:nil];
            break;
    }
    
    return XZDataCryptorMakeData(key, length, newLength);
}

static NSData * _Nonnull XZDataCryptorCanonicalVector(NSData *vector, size_t blockSize) {
    if ([vector isKindOfClass:NSData.class]) {
        return XZDataCryptorMakeData(vector, [vector length], blockSize);
    }
    if ([vector isKindOfClass:NSString.class]) {
        NSData *dataVector = [(NSString *)vector dataUsingEncoding:NSUTF8StringEncoding];
        return XZDataCryptorMakeData(dataVector, dataVector.length, blockSize);
    }
    return XZDataCryptorMakeData(nil, 0, blockSize);
}

