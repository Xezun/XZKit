//
//  XZKeychainIdentityItem.m
//  KeyChain
//
//  Created by 徐臻 on 2025/1/13.
//  Copyright © 2025 人民网. All rights reserved.
//

#import "XZKeychainIdentityItem.h"

@implementation XZKeychainIdentityItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _attributes[(NSString *)kSecClass] = (NSString *)kSecClassIdentity;
    }
    return self;
}

- (UInt32)certificateType {
    return [_attributes[(id)kSecAttrCertificateType] unsignedIntValue];
}

- (void)setCertificateType:(UInt32)certificateType {
    _attributes[(id)kSecAttrCertificateType] = @(certificateType);
}

- (UInt32)certificateEncoding {
    return [_attributes[(id)kSecAttrCertificateEncoding] unsignedIntValue];
}

- (void)setCertificateEncoding:(UInt32)certificateEncoding {
    _attributes[(id)kSecAttrCertificateEncoding] = @(certificateEncoding);
}

- (NSData *)subject {
    return _attributes[(id)kSecAttrSubject];
}

- (void)setSubject:(NSData *)subject {
    _attributes[(id)kSecAttrSubject] = subject;
}

- (NSData *)issuer {
    return _attributes[(id)kSecAttrIssuer];
}

- (void)setIssuer:(NSData *)issuer {
    _attributes[(id)kSecAttrIssuer] = issuer;
}

- (NSData *)serialNumber {
    return _attributes[(id)kSecAttrSerialNumber];
}

- (void)setSerialNumber:(NSData *)serialNumber {
    _attributes[(id)kSecAttrSerialNumber] = serialNumber;
}

- (NSData *)subjectKeyID {
    return _attributes[(id)kSecAttrSubjectKeyID];
}

- (void)setSubjectKeyID:(NSData *)subjectKeyID {
    _attributes[(id)kSecAttrSubjectKeyID] = subjectKeyID;
}

- (NSData *)publicKeyHash {
    return _attributes[(id)kSecAttrPublicKeyHash];
}

- (void)setPublicKeyHash:(NSData *)publicKeyHash {
    _attributes[(id)kSecAttrPublicKeyHash] = publicKeyHash;
}

// -----------------

- (XZKeychainKeyClass)keyClass {
    NSString *value = _attributes[(id)kSecAttrKeyClass];
    if ([value isEqualToString:(id)kSecAttrKeyClassPublic]) {
        return XZKeychainKeyClassPublic;
    }
    if ([value isEqualToString:(id)kSecAttrKeyClassPrivate]) {
        return XZKeychainKeyClassPrivate;
    }
    if ([value isEqualToString:(id)kSecAttrKeyClassSymmetric]) {
        return XZKeychainKeyClassSymmetric;
    }
    return XZKeychainKeyClassNone;
}

- (void)setKeyClass:(XZKeychainKeyClass)keyClass {
    switch (keyClass) {
        case XZKeychainKeyClassPublic:
            _attributes[(id)kSecAttrKeyClass] = (id)kSecAttrKeyClassPublic;
            break;
        case XZKeychainKeyClassPrivate:
            _attributes[(id)kSecAttrKeyClass] = (id)kSecAttrKeyClassPrivate;
            break;
        case XZKeychainKeyClassSymmetric:
            _attributes[(id)kSecAttrKeyClass] = (id)kSecAttrKeyClassSymmetric;
            break;
        case XZKeychainKeyClassNone:
            _attributes[(id)kSecAttrKeyClass] = nil;
            break;
    }
}

- (NSData *)applicationLabel {
    return _attributes[(id)kSecAttrApplicationLabel];
}

- (void)setApplicationLabel:(NSData *)applicationLabel {
    _attributes[(id)kSecAttrApplicationLabel] = applicationLabel;
}

- (BOOL)isPermanent {
    return [_attributes[(id)kSecAttrIsPermanent] boolValue];
}

- (void)setPermanent:(BOOL)isPermanent {
    _attributes[(id)kSecAttrIsPermanent] = @(isPermanent);
}

- (NSData *)applicationTag {
    return _attributes[(id)kSecAttrApplicationTag];
}

- (void)setApplicationTag:(NSData *)applicationTag {
    _attributes[(id)kSecAttrApplicationTag] = applicationTag;
}

- (XZKeychainKeyType)keyType {
    NSString *value = _attributes[(id)kSecAttrKeyType];
    if ([value isEqualToString:(id)kSecAttrKeyTypeRSA]) {
        return XZKeychainKeyTypeRSA;
    }
#if SEC_OS_OSX_INCLUDES
    if ([value isEqualToString:(id)kSecAttrKeyTypeDSA]) {
        return XZKeychainKeyTypeDSA;
    }
    if ([value isEqualToString:(id)kSecAttrKeyTypeAES]) {
        return XZKeychainKeyTypeAES;
    }
    if ([value isEqualToString:(id)kSecAttrKeyTypeDES]) {
        return XZKeychainKeyTypeDES;
    }
    if ([value isEqualToString:(id)kSecAttrKeyType3DES]) {
        return XZKeychainKeyType3DES;
    }
    if ([value isEqualToString:(id)kSecAttrKeyTypeRC4]) {
        return XZKeychainKeyTypeRC4;
    }
    if ([value isEqualToString:(id)kSecAttrKeyTypeRC2]) {
        return XZKeychainKeyTypeRC2;
    }
    if ([value isEqualToString:(id)kSecAttrKeyTypeCAST]) {
        return XZKeychainKeyTypeCAST;
    }
    if ([value isEqualToString:(id)kSecAttrKeyTypeECDSA]) {
        return XZKeychainKeyTypeECDSA;
    }
#endif
    if ([value isEqualToString:(id)kSecAttrKeyTypeEC]) {
        return XZKeychainKeyTypeEC;
    }
    if ([value isEqualToString:(id)kSecAttrKeyTypeECSECPrimeRandom]) {
        return XZKeychainKeyTypeECSECPrimeRandom;
    }
    return XZKeychainKeyTypeNone;
}

- (void)setKeyType:(XZKeychainKeyType)keyType {
    switch (keyType) {
        case XZKeychainKeyTypeNone:
            _attributes[(id)kSecAttrKeyType] = nil;
            break;
        case XZKeychainKeyTypeRSA:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyTypeRSA;
            break;
#if SEC_OS_OSX_INCLUDES
        case XZKeychainKeyTypeDSA:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyType;
            break;
        case XZKeychainKeyTypeAES:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyType;
            break;
        case XZKeychainKeyTypeDES:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyType;
            break;
        case XZKeychainKeyType3DES:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyType;
            break;
        case XZKeychainKeyTypeRC4:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyType;
            break;
        case XZKeychainKeyTypeRC2:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyType;
            break;
        case XZKeychainKeyTypeCAST:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyType;
            break;
        case XZKeychainKeyTypeECDSA:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyType;
            break;
#endif
        case XZKeychainKeyTypeEC:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyTypeEC;
            break;
        case XZKeychainKeyTypeECSECPrimeRandom:
            _attributes[(id)kSecAttrKeyType] = (id)kSecAttrKeyTypeECSECPrimeRandom;
            break;
    }
}

- (size_t)keySizeInBits {
    return [_attributes[(id)kSecAttrKeySizeInBits] longLongValue];
}

- (void)setKeySizeInBits:(size_t)keySizeInBits {
    _attributes[(id)kSecAttrKeySizeInBits] = @(keySizeInBits);
}

- (size_t)effectiveKeySize {
    return [_attributes[(id)kSecAttrEffectiveKeySize] longLongValue];
}

- (void)setEffectiveKeySize:(size_t)effectiveKeySize {
    _attributes[(id)kSecAttrEffectiveKeySize] = @(effectiveKeySize);
}

- (BOOL)canEncrypt {
    return [_attributes[(id)kSecAttrCanEncrypt] boolValue];
}

- (void)setEncrypt:(BOOL)canEncrypt {
    _attributes[(id)kSecAttrCanEncrypt] = @(canEncrypt);
}

- (BOOL)canDecrypt {
    return [_attributes[(id)kSecAttrCanDecrypt] boolValue];
}

- (void)setCanDecrypt:(BOOL)canDecrypt {
    _attributes[(id)kSecAttrCanDecrypt] = @(canDecrypt);
}

- (BOOL)canDerive {
    return [_attributes[(id)kSecAttrCanDerive] boolValue];
}

- (void)setCanDerive:(BOOL)canDerive {
    _attributes[(id)kSecAttrCanDerive] = @(canDerive);
}

- (BOOL)canSign {
    return [_attributes[(id)kSecAttrCanSign] boolValue];
}

- (void)setCanSign:(BOOL)canSign {
    _attributes[(id)kSecAttrCanSign] = @(canSign);
}

- (BOOL)canVerify {
    return [_attributes[(id)kSecAttrCanVerify] boolValue];
}

- (void)setCanVerify:(BOOL)canVerify {
    _attributes[(id)kSecAttrCanVerify] = @(canVerify);
}

- (BOOL)canWrap {
    return [_attributes[(id)kSecAttrCanWrap] boolValue];
}

- (void)setCanWrap:(BOOL)canWrap {
    _attributes[(id)kSecAttrCanWrap] = @(canWrap);
}

- (BOOL)canUnwrap {
    return [_attributes[(id)kSecAttrCanUnwrap] boolValue];
}

- (void)setCanUnwrap:(BOOL)canUnwrap {
    _attributes[(id)kSecAttrCanUnwrap] = @(canUnwrap);
}

@end


@implementation XZKeychainCertificateItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _attributes[(NSString *)kSecClass] = (NSString *)kSecClassCertificate;
    }
    return self;
}

@dynamic keyClass, applicationLabel, isPermanent, applicationTag, keyType;
@dynamic keySizeInBits, effectiveKeySize, canEncrypt, canDecrypt, canDerive;
@dynamic canSign, canVerify, canWrap, canUnwrap;

@end


@implementation XZKeychainKeyItem

- (instancetype)init {
    self = [super init];
    if (self) {
        _attributes[(NSString *)kSecClass] = (NSString *)kSecClassKey;
    }
    return self;
}

@dynamic certificateType, certificateEncoding;
@dynamic subject, issuer, serialNumber, subjectKeyID, publicKeyHash;

@end
