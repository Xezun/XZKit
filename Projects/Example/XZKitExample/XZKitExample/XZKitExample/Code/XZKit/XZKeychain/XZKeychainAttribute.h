//
//  XZKeychainAttribute.h
//  XZKit
//
//  Created by mlibai on 2016/12/1.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 钥匙串所拥有的属性
typedef NS_ENUM(NSUInteger, XZKeychainAttributeType) {
    // 钥匙串 XZKeychainGenericPassword 支持的属性：
    XZKeychainAttributeTypeAccessible,
    XZKeychainAttributeTypeAccessControl,
    // 模拟器（TARGET_IPHONE_SIMULATOR）没有代码签名，不存在分组。
    // 如果设置分组，添加或更新就会返回 -25243 (errSecNoAccessForItem) 错误。
    XZKeychainAttributeTypeAccessGroup,
    XZKeychainAttributeTypeCreationDate,
    XZKeychainAttributeTypeModificationDate,
    XZKeychainAttributeTypeDescription,
    XZKeychainAttributeTypeComment,
    XZKeychainAttributeTypeCreator,
    XZKeychainAttributeTypeType,
    XZKeychainAttributeTypeLabel,
    XZKeychainAttributeTypeIsInvisible,
    XZKeychainAttributeTypeIsNegative,
    XZKeychainAttributeTypeAccount,  // 帐号
    XZKeychainAttributeTypeService,
    XZKeychainAttributeTypeGeneric,  // 通用属性，XZKeychain 建议把它作为管理 XZKeychainTypeGenericPassword 类型钥匙串的唯一标识符。
    XZKeychainAttributeTypeSynchronizable,
    
    /* 钥匙串 XZKeychainInternetPassword 支持的属性：
     // 注释掉的属性不表示没有，而是已经在列表中了，下同
     XZKeychainAttributeTypeAccessible,
     XZKeychainAttributeTypeAccessControl,
     XZKeychainAttributeTypeAccessGroup,
     XZKeychainAttributeTypeCreationDate,
     XZKeychainAttributeTypeModificationDate,
     XZKeychainAttributeTypeDescription,
     XZKeychainAttributeTypeComment,
     XZKeychainAttributeTypeCreator,
     XZKeychainAttributeTypeType,
     XZKeychainAttributeTypeLabel,
     XZKeychainAttributeTypeIsInvisible,
     XZKeychainAttributeTypeIsNegative,
     XZKeychainAttributeTypeAccount, */
    XZKeychainAttributeTypeSecurityDomain,
    XZKeychainAttributeTypeServer,
    XZKeychainAttributeTypeProtocol,
    XZKeychainAttributeTypeAuthenticationType,
    XZKeychainAttributeTypePort,
    XZKeychainAttributeTypePath,
    // XZKeychainAttributeTypeSynchronizable
    
    // 钥匙串 XZKeychainCertificate 支持的属性：
    // XZKeychainAttributeTypeAccessible,
    // XZKeychainAttributeTypeAccessControl,
    // XZKeychainAttributeTypeAccessGroup,
    XZKeychainAttributeTypeCertificateType,
    XZKeychainAttributeTypeCertificateEncoding,
    // XZKeychainAttributeTypeLabel,
    XZKeychainAttributeTypeSubject,
    XZKeychainAttributeTypeIssuer,
    XZKeychainAttributeTypeSerialNumber,
    XZKeychainAttributeTypeSubjectKeyID,
    XZKeychainAttributeTypePublicKeyHash,
    // XZKeychainAttributeTypeSynchronizable
    
    // 钥匙串 XZKeychainKey 支持的属性：
    // XZKeychainAttributeTypeAccessible,
    // XZKeychainAttributeTypeAccessControl,
    // XZKeychainAttributeTypeAccessGroup,
    XZKeychainAttributeTypeKeyClass,
    // XZKeychainAttributeTypeLabel,
    XZKeychainAttributeTypeApplicationLabel,
    XZKeychainAttributeTypeIsPermanent,
    XZKeychainAttributeTypeApplicationTag,
    XZKeychainAttributeTypeKeyType,
    XZKeychainAttributeTypeKeySizeInBits,
    XZKeychainAttributeTypeEffectiveKeySize,
    XZKeychainAttributeTypeCanEncrypt,
    XZKeychainAttributeTypeCanDecrypt,
    XZKeychainAttributeTypeCanDerive,
    XZKeychainAttributeTypeCanSign,
    XZKeychainAttributeTypeCanVerify,
    XZKeychainAttributeTypeCanWrap,
    XZKeychainAttributeTypeCanUnwrap
    // XZKeychainAttributeTypeSynchronizable
    
    // 钥匙串 XZKeychainIdentity 支持的属性:
    // 由于 XZKeychainIdentity 钥匙串同时包含“私钥”和“证书”，
    // 所以它同时具有 XZKeychainKey 和 XZKeychainCertificate 两种钥匙串的属性。
};

FOUNDATION_EXTERN NSString * _Nonnull NSStringFromXZKeychainAttributeType(XZKeychainAttributeType attributeType);

@interface XZKeychainAttribute : NSObject <NSCopying>

@property (nonatomic, readonly, copy, nonnull) NSString *name;

@property (nonatomic, strong, nullable) id value;
@property (nonatomic, readonly, strong, nullable) id originalValue;

+ (instancetype)attributeWithType:(XZKeychainAttributeType)attributeType value:(nullable id)value;
- (instancetype)initWithType:(XZKeychainAttributeType)attributeType value:(nullable id)value;

- (instancetype)initWithName:(nonnull NSString *)name updatingValue:(nullable id)updatingValue;
- (instancetype)initWithName:(nonnull NSString *)name originalValue:(nullable id)originalValue;
- (instancetype)initWithName:(nonnull NSString *)name originalValue:(nullable id)originalValue updatingValue:(nullable id)updatingValue;

@end

NS_ASSUME_NONNULL_END
