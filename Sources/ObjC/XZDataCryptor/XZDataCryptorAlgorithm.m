//
//  XZDataCryptorAlgorithm.m
//  XZKit
//
//  Created by Xezun on 2021/2/15.
//

#import <CommonCrypto/CommonCryptor.h>
#import "XZDataCryptorAlgorithm.h"

typedef XZDataCryptorAlgorithm * _Nonnull (^XZDataCryptorAlgorithmGenerator)(NSString *key, NSString * _Nullable vector);

static NSString *setKey(NSString *key, CCAlgorithm algorithm);
static NSString *setVector(NSString *vector, size_t blockSize);

@implementation XZDataCryptorAlgorithm

+ (BOOL)accessInstanceVariablesDirectly {
    return NO;
}

- (instancetype)initWithRawValue:(CCAlgorithm)rawValue key:(NSString *)key vector:(NSString *)vector blockSize:(size_t)blockSize contextSize:(size_t)contextSize {
    NSParameterAssert([key isKindOfClass:NSString.class]);
    self = [super init];
    if (self) {
        _rawValue       = rawValue;
        _key            = setKey(key, rawValue).copy;
        _vector         = setVector(vector, blockSize).copy;
        _blockSize      = blockSize;
        _contextSize    = contextSize;
        _numberOfRounds = 0;
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

- (void)setKey:(NSString *)key {
    if ([_key isEqual:key]) {
        return;
    }
    _key = setKey(key, self.rawValue).copy;
}

- (void)setVector:(NSString *)vector {
    if ([_vector isEqual:vector]) {
        return;
    }
    _vector = setVector(vector, self.blockSize).copy;
}

+ (XZDataCryptorAlgorithm *)algorithm:(CCAlgorithm)algorithm key:(NSString *)key vector:(NSString *)vector  blockSize:(size_t)blockSize contextSize:(size_t)contextSize {
    return [[self alloc] initWithRawValue:algorithm key:key vector:vector blockSize:blockSize contextSize:contextSize];
}

+ (XZDataCryptorAlgorithm *)AES:(NSString *)key vector:(NSString *)vector {
    return [self algorithm:kCCAlgorithmAES key:key vector:vector blockSize:kCCBlockSizeAES128 contextSize:kCCContextSizeAES128];
}

+ (XZDataCryptorAlgorithm *)DES:(NSString *)key vector:(NSString *)vector {
    return [self algorithm:kCCAlgorithmDES key:key vector:vector blockSize:kCCBlockSizeDES contextSize:kCCContextSizeDES];
}

+ (XZDataCryptorAlgorithm *)DES3:(NSString *)key vector:(NSString *)vector {
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


static NSString *setKey(NSString *key, CCAlgorithm algorithm) {
    switch (algorithm) {
        case kCCAlgorithmAES: {
            NSInteger const length = key.length;
            if (length < kCCKeySizeAES128) {
                return [key stringByPaddingToLength:kCCKeySizeAES128 withString:@"\0" startingAtIndex:0];
            }
            if (length < kCCKeySizeAES192) {
                return [key stringByPaddingToLength:kCCKeySizeAES192 withString:@"\0" startingAtIndex:0];
            }
            return [key stringByPaddingToLength:kCCKeySizeAES256 withString:@"\0" startingAtIndex:0];
        }
        case kCCAlgorithmDES: {
            return [key stringByPaddingToLength:kCCKeySizeDES withString:@"\0" startingAtIndex:0];
        }
        case kCCAlgorithm3DES: {
            return [key stringByPaddingToLength:kCCKeySize3DES withString:@"\0" startingAtIndex:0];
        }
        case kCCAlgorithmCAST: {
            if (key.length < kCCKeySizeMinCAST) {
                return [key stringByPaddingToLength:5 withString:@"\0" startingAtIndex:0];
            }
            if (key.length > kCCKeySizeMaxCAST) {
                return [key substringToIndex:kCCKeySizeMaxCAST];
            }
            return key;
        }
        case kCCAlgorithmRC4: {
            if (key.length < kCCKeySizeMinRC4) {
                return @"\0";
            }
            if (key.length > kCCKeySizeMaxRC4) {
                return [key substringToIndex:kCCKeySizeMaxRC4];
            }
            return key;
        }
        case kCCAlgorithmRC2: {
            if (key.length < kCCKeySizeMinRC2) {
                return @"\0";
            }
            if (key.length > kCCKeySizeMaxRC2) {
                return [key substringToIndex:kCCKeySizeMaxRC2];
            }
            return key;
        }
        case kCCAlgorithmBlowfish: {
            if (key.length < kCCKeySizeMinBlowfish) {
                return [key stringByPaddingToLength:8 withString:@"\0" startingAtIndex:0];
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


static NSString *setVector(NSString *vector, size_t blockSize) {
    return [vector stringByPaddingToLength:blockSize withString:@"\0" startingAtIndex:0];
}

