//
//  XZKeychainAttribute.m
//  XZKit
//
//  Created by mlibai on 2016/12/1.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZKeychainAttribute.h"

@interface XZKeychainAttribute ()

@property (nonatomic, strong, nullable) id originalValue;
@property (nonatomic, strong, nullable) id updatingValue;

@end

@implementation XZKeychainAttribute

+ (instancetype)attributeWithType:(XZKeychainAttributeType)attributeType value:(id)value {
    return [(XZKeychainAttribute *)[self alloc] initWithType:attributeType value:value];
}

- (instancetype)initWithType:(XZKeychainAttributeType)attributeType value:(id)value {
    NSString *name = NSStringFromXZKeychainAttributeType(attributeType);
    return [self initWithName:name originalValue:nil updatingValue:value];
}

- (instancetype)initWithName:(NSString *)name originalValue:(id)originalValue updatingValue:(id)updatingValue {
    self = [super init];
    if (self) {
        _name = [name copy];
        _originalValue = originalValue;
        _updatingValue = updatingValue;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name originalValue:(id)originalValue {
    return [self initWithName:name originalValue:originalValue updatingValue:nil];
}

- (instancetype)initWithName:(NSString *)name updatingValue:(id)updatingValue {
    return [self initWithName:name originalValue:nil updatingValue:updatingValue];
}

- (id)value {
    if (_updatingValue) {
        return _updatingValue;
    }
    return _originalValue;
}

- (void)setValue:(id)value {
    _updatingValue = value;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[[self class] alloc] initWithName:_name originalValue:_originalValue updatingValue:_updatingValue];
}

@end


NSString * _Nonnull NSStringFromXZKeychainAttributeType(XZKeychainAttributeType attributeType) {
    switch (attributeType) {
        case XZKeychainAttributeTypeAccessible:
            return (id)kSecAttrAccessible;
            break;
        case XZKeychainAttributeTypeAccessControl:
            return (id)kSecAttrAccessControl;
            break;
        case XZKeychainAttributeTypeAccessGroup:
            return (id)kSecAttrAccessGroup;
            break;
        case XZKeychainAttributeTypeCreationDate:
            return (id)kSecAttrCreationDate;
            break;
        case XZKeychainAttributeTypeModificationDate:
            return (id)kSecAttrModificationDate;
            break;
        case XZKeychainAttributeTypeDescription:
            return (id)kSecAttrDescription;
            break;
        case XZKeychainAttributeTypeComment:
            return (id)kSecAttrComment;
            break;
        case XZKeychainAttributeTypeCreator:
            return (id)kSecAttrCreator;
            break;
        case XZKeychainAttributeTypeType:
            return (id)kSecAttrType;
            break;
        case XZKeychainAttributeTypeLabel:
            return (id)kSecAttrLabel;
            break;
        case XZKeychainAttributeTypeIsInvisible:
            return (id)kSecAttrIsInvisible;
            break;
        case XZKeychainAttributeTypeIsNegative:
            return (id)kSecAttrIsNegative;
            break;
        case XZKeychainAttributeTypeAccount:
            return (id)kSecAttrAccount;
            break;
        case XZKeychainAttributeTypeService:
            return (id)kSecAttrService;
            break;
        case XZKeychainAttributeTypeGeneric:
            return (id)kSecAttrGeneric;
            break;
        case XZKeychainAttributeTypeSynchronizable:
            return (id)kSecAttrSynchronizable;
            break;
        case XZKeychainAttributeTypeSecurityDomain:
            return (id)kSecAttrSecurityDomain;
            break;
        case XZKeychainAttributeTypeServer:
            return (id)kSecAttrServer;
            break;
        case XZKeychainAttributeTypeProtocol:
            return (id)kSecAttrProtocol;
            break;
        case XZKeychainAttributeTypeAuthenticationType:
            return (id)kSecAttrAuthenticationType;
            break;
        case XZKeychainAttributeTypePort:
            return (id)kSecAttrPort;
            break;
        case XZKeychainAttributeTypePath:
            return (id)kSecAttrPath;
            break;
        case XZKeychainAttributeTypeCertificateType:
            return (id)kSecAttrCertificateType;
            break;
        case XZKeychainAttributeTypeCertificateEncoding:
            return (id)kSecAttrCertificateEncoding;
            break;
        case XZKeychainAttributeTypeSubject:
            return (id)kSecAttrSubject;
            break;
        case XZKeychainAttributeTypeIssuer:
            return (id)kSecAttrIssuer;
            break;
        case XZKeychainAttributeTypeSerialNumber:
            return (id)kSecAttrSerialNumber;
            break;
        case XZKeychainAttributeTypeSubjectKeyID:
            return (id)kSecAttrSubjectKeyID;
            break;
        case XZKeychainAttributeTypePublicKeyHash:
            return (id)kSecAttrPublicKeyHash;
            break;
        case XZKeychainAttributeTypeKeyClass:
            return (id)kSecAttrKeyClass;
            break;
        case XZKeychainAttributeTypeApplicationLabel:
            return (id)kSecAttrApplicationLabel;
            break;
        case XZKeychainAttributeTypeIsPermanent:
            return (id)kSecAttrIsPermanent;
            break;
        case XZKeychainAttributeTypeApplicationTag:
            return (id)kSecAttrApplicationTag;
            break;
        case XZKeychainAttributeTypeKeyType:
            return (id)kSecAttrKeyType;
            break;
        case XZKeychainAttributeTypeKeySizeInBits:
            return (id)kSecAttrKeySizeInBits;
            break;
        case XZKeychainAttributeTypeEffectiveKeySize:
            return (id)kSecAttrEffectiveKeySize;
            break;
        case XZKeychainAttributeTypeCanEncrypt:
            return (id)kSecAttrCanEncrypt;
            break;
        case XZKeychainAttributeTypeCanDecrypt:
            return (id)kSecAttrCanDecrypt;
            break;
        case XZKeychainAttributeTypeCanDerive:
            return (id)kSecAttrCanDerive;
            break;
        case XZKeychainAttributeTypeCanSign:
            return (id)kSecAttrCanSign;
            break;
        case XZKeychainAttributeTypeCanVerify:
            return (id)kSecAttrCanVerify;
            break;
        case XZKeychainAttributeTypeCanWrap:
            return (id)kSecAttrCanWrap;
            break;
        case XZKeychainAttributeTypeCanUnwrap:
            return (id)kSecAttrCanUnwrap;
            break;
        default:
            return @"NotSupportedAttribute";
            break;
    }
}

