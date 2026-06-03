//
//  XZDataCryptorAlgorithm.m
//  XZKit
//
//  Created by Xezun on 2021/2/15.
//

#import <CommonCrypto/CommonCryptor.h>
#import "XZDataCryptorDefines.h"

typedef XZDataCryptorAlgorithm * _Nonnull (^XZDataCryptorAlgorithmGenerator)(NSString *key, NSString * _Nullable vector);

static NSString *XZDataCryptorCanonicalKey(NSString *key, CCAlgorithm algorithm);
static NSString *XZDataCryptorCanonicalVector(NSString *vector, size_t blockSize);

@implementation XZDataCryptorAlgorithm

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

- (instancetype)initWithRawValue:(CCAlgorithm)rawValue key:(NSString *)key vector:(NSString *)vector blockSize:(size_t)blockSize contextSize:(size_t)contextSize rounds:(NSInteger)rounds {
    NSParameterAssert([key isKindOfClass:NSString.class]);
    self = [super init];
    if (self) {
        _rawValue    = rawValue;
        _blockSize   = blockSize;
        _contextSize = contextSize;
        _rounds      = rounds;
        _key         = XZDataCryptorCanonicalKey(key, rawValue).copy;
        _vector      = XZDataCryptorCanonicalVector(vector, blockSize).copy;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    if ([object isKindOfClass:[XZDataCryptorAlgorithm class]]) {
        return (_rawValue == [(XZDataCryptorAlgorithm *)object rawValue]);
    }
    return NO;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[XZDataCryptorAlgorithm alloc] initWithRawValue:_rawValue key:_key vector:_vector blockSize:_blockSize contextSize:_contextSize rounds:_rounds];
}

- (void)setKey:(NSString *)key {
    NSParameterAssert([key isKindOfClass:NSString.class]);
    if ([_key isEqual:key]) {
        return;
    }
    _key = XZDataCryptorCanonicalKey(key, self.rawValue).copy;
}

- (void)setVector:(NSString *)vector {
    if ([_vector isEqual:vector]) {
        return;
    }
    _vector = XZDataCryptorCanonicalVector(vector, self.blockSize).copy;
}

- (void)setRounds:(NSInteger)rounds {
    _rounds = MAX(0, rounds);
}

+ (XZDataCryptorAlgorithm *)algorithm:(CCAlgorithm)algorithm key:(NSString *)key vector:(NSString *)vector  blockSize:(size_t)blockSize contextSize:(size_t)contextSize {
    return [[self alloc] initWithRawValue:algorithm key:key vector:vector blockSize:blockSize contextSize:contextSize rounds:0];
}

+ (XZDataCryptorAlgorithm *)AES:(NSString *)key vector:(NSString *)vector {
    return [self algorithm:kCCAlgorithmAES key:key vector:vector blockSize:kCCBlockSizeAES128 contextSize:kCCContextSizeAES128];
}

+ (XZDataCryptorAlgorithm *)DES:(NSString *)key vector:(NSString *)vector {
    return [self algorithm:kCCAlgorithmDES key:key vector:vector blockSize:kCCBlockSizeDES contextSize:kCCContextSizeDES];
}

+ (XZDataCryptorAlgorithm *)tripleDES:(NSString *)key vector:(NSString *)vector {
    return [self algorithm:kCCAlgorithm3DES key:key vector:vector blockSize:kCCBlockSize3DES contextSize:kCCContextSize3DES];
}

+ (XZDataCryptorAlgorithm *)CAST:(NSString *)key vector:(NSString *)vector {
    return [self algorithm:kCCAlgorithmCAST key:key vector:vector blockSize:kCCBlockSizeCAST contextSize:kCCContextSizeCAST];
}

+ (XZDataCryptorAlgorithm *)RC4:(NSString *)key vector:(NSString *)vector {
    return [self algorithm:kCCAlgorithmRC4 key:key vector:vector blockSize:kCCContextSizeRC4 contextSize:kCCContextSizeRC4];
}

+ (XZDataCryptorAlgorithm *)RC2:(NSString *)key vector:(NSString *)vector {
    return [self algorithm:kCCAlgorithmRC2 key:key vector:vector blockSize:kCCBlockSizeRC2 contextSize:kCCBlockSizeRC2];
}

+ (XZDataCryptorAlgorithm *)Blowfish:(NSString *)key vector:(NSString *)vector {
    return [self algorithm:kCCAlgorithmBlowfish key:key vector:vector blockSize:kCCBlockSizeBlowfish contextSize:kCCBlockSizeBlowfish];
}

- (NSString *)description {
    switch (_rawValue) {
        case kCCAlgorithmAES:
            return @"AES";
        case kCCAlgorithmDES:
            return @"DES";
        case kCCAlgorithm3DES:
            return @"3DES";
        case kCCAlgorithmCAST:
            return @"CAST";
        case kCCAlgorithmRC4:
            return @"RC4";
        case kCCAlgorithmRC2:
            return @"RC2";
        case kCCAlgorithmBlowfish:
            return @"Blowfish";
        default:
            return @"Unknown";
    }
}

@end


static NSString *XZDataCryptorCanonicalKey(NSString *key, CCAlgorithm algorithm) {
    NSInteger const length = key.length;
    switch (algorithm) {
        case kCCAlgorithmAES: {
            if (length < kCCKeySizeAES128) {
                return [key stringByPaddingToLength:kCCKeySizeAES128 withString:@"\0" startingAtIndex:0];
            }
            if (length == kCCKeySizeAES128) {
                return key;
            }
            if (length < kCCKeySizeAES192) {
                return [key stringByPaddingToLength:kCCKeySizeAES192 withString:@"\0" startingAtIndex:0];
            }
            if (length == kCCKeySizeAES192) {
                return key;
            }
            if (length < kCCKeySizeAES256) {
                return [key stringByPaddingToLength:kCCKeySizeAES256 withString:@"\0" startingAtIndex:0];
            }
            if (length == kCCKeySizeAES256) {
                return key;
            }
            return [key substringToIndex:kCCKeySizeAES256];
        }
        case kCCAlgorithmDES: {
            if (length < kCCKeySizeDES) {
                return [key stringByPaddingToLength:kCCKeySizeDES withString:@"\0" startingAtIndex:0];
            }
            if (length == kCCKeySizeDES) {
                return key;
            }
            return [key substringToIndex:kCCKeySizeDES];
        }
        case kCCAlgorithm3DES: {
            if (length < kCCKeySize3DES) {
                return [key stringByPaddingToLength:kCCKeySize3DES withString:@"\0" startingAtIndex:0];
            }
            if (length == kCCKeySize3DES) {
                return key;
            }
            return [key substringToIndex:kCCKeySize3DES];
        }
        case kCCAlgorithmCAST: {
            if (key.length < kCCKeySizeMinCAST) {
                return [key stringByPaddingToLength:kCCKeySizeMinCAST withString:@"\0" startingAtIndex:0];
            }
            if (key.length > kCCKeySizeMaxCAST) {
                return [key substringToIndex:kCCKeySizeMaxCAST];
            }
            return key;
        }
        case kCCAlgorithmRC4: {
            if (key.length < kCCKeySizeMinRC4) {
                return [key stringByPaddingToLength:kCCKeySizeMinRC4 withString:@"\0" startingAtIndex:0];
            }
            if (key.length > kCCKeySizeMaxRC4) {
                return [key substringToIndex:kCCKeySizeMaxRC4];
            }
            return key;
        }
        case kCCAlgorithmRC2: {
            if (key.length < kCCKeySizeMinRC2) {
                return [key stringByPaddingToLength:kCCKeySizeMinRC2 withString:@"\0" startingAtIndex:0];
            }
            if (key.length > kCCKeySizeMaxRC2) {
                return [key substringToIndex:kCCKeySizeMaxRC2];
            }
            return key;
        }
        case kCCAlgorithmBlowfish: {
            if (key.length < kCCKeySizeMinBlowfish) {
                return [key stringByPaddingToLength:kCCKeySizeMinBlowfish withString:@"\0" startingAtIndex:0];
            }
            if (key.length > kCCKeySizeMaxBlowfish) {
                return [key substringToIndex:kCCKeySizeMaxBlowfish];
            }
            return key;
        }
        default:
            @throw [NSException exceptionWithName:NSGenericException reason:@"Not Supported Algorithm" userInfo:nil];
            break;
    }
}

static NSString *XZDataCryptorCanonicalVector(NSString *vector, size_t blockSize) {
    if (vector.length == blockSize) {
        return vector;
    }
    if (vector.length < blockSize) {
        return [vector stringByPaddingToLength:blockSize withString:@"\0" startingAtIndex:0];
    }
    return [vector substringToIndex:blockSize];
}
