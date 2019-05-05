//
//  XZKeychain.h
//  XZKit
//
//  Created by M. X. Z. on 16/7/28.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XZKit/XZKeychainAttribute.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XZKeychainType) {
    XZKeychainTypeGenericPassword = 0,  // 通用密码
    XZKeychainTypeInternetPassword,     // 网络密码
    XZKeychainTypeCertificate,          // 证书
    XZKeychainTypeKey,                  // 密钥
    XZKeychainTypeIdentity,             // 验证
    XZKeychainTypeNotSupported          // 不支持的属性，请勿使用
};

NS_REQUIRES_PROPERTY_DEFINITIONS @interface XZKeychain : NSObject

+ (__kindof XZKeychain * _Nullable)keychain:(NSArray<XZKeychainAttribute *> *)attributes ofType:(XZKeychainType)type error:(NSError * _Nullable * _Nullable)error;
+ (NSArray<__kindof XZKeychain *> * _Nullable)keychains:(NSArray<XZKeychainAttribute *> *)attributes ofType:(XZKeychainType)type error:(NSError * _Nullable * _Nullable)error;

+ (__kindof XZKeychain * _Nullable)keychainWithType:(XZKeychainType)type;
+ (__kindof XZKeychain * _Nullable)keychainWithAttributes:(nullable NSArray<XZKeychainAttribute *> *)attributes type:(XZKeychainType)type;

@property (nonatomic, readonly) XZKeychainType type;
@property (nonatomic, copy, readonly) NSDictionary<NSString *, XZKeychainAttribute *> *attributes;

- (instancetype)init NS_UNAVAILABLE;

- (void)setValue:(nullable id)value forAttribute:(NSString *)attribute;
- (nullable id)valueForAttribute:(NSString *)attribute;

- (void)setObject:(nullable id)anObject forAttribute:(NSString *)attribute;
- (nullable id)objectForAttribute:(NSString *)attribute;

- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;
- (nullable id)objectForKeyedSubscript:(NSString *)key;

- (void)setValue:(nullable id)value forAttributeType:(XZKeychainAttributeType)attributeType;
- (nullable id)valueForAttributeType:(XZKeychainAttributeType)attributeType;

- (void)setObject:(nullable id)anObject forAttributeType:(XZKeychainAttributeType)attributeType;
- (nullable id)objectForAttributeType:(XZKeychainAttributeType)attributeType;

- (void)setObject:(nullable id)obj atIndexedSubscript:(XZKeychainAttributeType)attributeType;
- (nullable id)objectAtIndexedSubscript:(XZKeychainAttributeType)attributeType;


- (void)reset;

- (BOOL)insert:(NSError * _Nullable * _Nullable)error;
- (BOOL)remove:(NSError * _Nullable * _Nullable)error; // if item not found, will return yes, but error is not nil.
- (BOOL)update:(NSError * _Nullable * _Nullable)error;

- (nullable NSData *)secret:(NSError **)error;
- (BOOL)setSecret:(NSData *)secret error:(NSError **)error;

@end

/**
 *  通用密码钥匙串：XZKeychain.type = XZKeychainGenericPassword。
 *  关于 AccessGroup 钥匙串共享的两种设置方法：
 *  1, 首先，需要在项目中创建一个如下结构的 plist 文件，将文件名作为 group 参数传入；
 *     然后，在 Target -> Build settings -> Code Sign Entitlements 设置签名授权为该 plist 文件。
 *     ┌────────────────────────────────────────────────────────────────────────────────────┐
 *     │<dict>                                                                              │
 *     │    <key>keychain-access-groups</key>                                               │
 *     │    <array>                                                                         │
 *     │        <string>YOUR_APP_ID_HERE.com.yourcompany.keychain</string>                  │
 *     │        <string>YOUR_APP_ID_HERE.com.yourcompany.keychainSuite</string>             │
 *     │    </array>                                                                        │
 *     │</dict>                                                                             │
 *     └────────────────────────────────────────────────────────────────────────────────────┘
 *  2, 在 Target -> Capabilities -> Keychain Sharing 中设置。
 */



@interface XZGenericPasswordKeychain : XZKeychain

- (instancetype)initWithAttributes:(nullable NSArray<XZKeychainAttribute *> *)attributes;

@property (nonatomic, strong, nullable) id accessible;
@property (nonatomic, strong, nullable) id accessControl;
@property (nonatomic, strong, nullable) id accessGroup;
@property (nonatomic, strong, nullable) id creationDate;
@property (nonatomic, strong, nullable) id modificationDate;
@property (nonatomic, strong, nullable) NSString *description;
@property (nonatomic, strong, nullable) id comment;
@property (nonatomic, strong, nullable) id creator;
@property (nonatomic, strong, nullable) id itemType; // type
@property (nonatomic, strong, nullable) id label;
@property (nonatomic, strong, nullable) id isInvisible;
@property (nonatomic, strong, nullable) id isNegative;
@property (nonatomic, strong, nullable) id account;
@property (nonatomic, strong, nullable) id service;
@property (nonatomic, strong, nullable) id generic;
@property (nonatomic, strong, nullable) id synchronizable;

@property (nonatomic, copy) NSString *password;

@end

@interface XZInternetPasswordKeychain : XZKeychain

- (instancetype)initWithAttributes:(nullable NSArray<XZKeychainAttribute *> *)attributes;

@property (nonatomic, strong, nullable) id accessible;
@property (nonatomic, strong, nullable) id accessControl;
@property (nonatomic, strong, nullable) id accessGroup;
@property (nonatomic, strong, nullable) id creationDate;
@property (nonatomic, strong, nullable) id modificationDate;
@property (nonatomic, strong, nullable) NSString *description;
@property (nonatomic, strong, nullable) id comment;
@property (nonatomic, strong, nullable) id creator;
@property (nonatomic, strong, nullable) id itemType; // type
@property (nonatomic, strong, nullable) id label;
@property (nonatomic, strong, nullable) id isInvisible;
@property (nonatomic, strong, nullable) id isNegative;
@property (nonatomic, strong, nullable) id account;
@property (nonatomic, strong, nullable) id securityDomain;
@property (nonatomic, strong, nullable) id server;
@property (nonatomic, strong, nullable) id protocol;
@property (nonatomic, strong, nullable) id authenticationType;
@property (nonatomic, strong, nullable) id port;
@property (nonatomic, strong, nullable) id path;
@property (nonatomic, strong, nullable) id synchronizable;

@end

@interface XZCertificateKeychain : XZKeychain

- (instancetype)initWithAttributes:(nullable NSArray<XZKeychainAttribute *> *)attributes;

@property (nonatomic, strong, nullable) id accessible;
@property (nonatomic, strong, nullable) id accessControl;
@property (nonatomic, strong, nullable) id accessGroup;
@property (nonatomic, strong, nullable) id certificateType;
@property (nonatomic, strong, nullable) id certificateEncoding;
@property (nonatomic, strong, nullable) id label;
@property (nonatomic, strong, nullable) id subject;
@property (nonatomic, strong, nullable) id issuer;
@property (nonatomic, strong, nullable) id serialNumber;
@property (nonatomic, strong, nullable) id subjectKeyID;
@property (nonatomic, strong, nullable) id publicKeyHash;
@property (nonatomic, strong, nullable) id synchronizable;

@end

@interface XZKeyKeychain : XZKeychain

- (instancetype)initWithAttributes:(nullable NSArray<XZKeychainAttribute *> *)attributes;

@property (nonatomic, strong, nullable) id accessible;
@property (nonatomic, strong, nullable) id accessControl;
@property (nonatomic, strong, nullable) id accessGroup;
@property (nonatomic, strong, nullable) id keyClass;
@property (nonatomic, strong, nullable) id label;
@property (nonatomic, strong, nullable) id applicationLabel;
@property (nonatomic, strong, nullable) id isPermanent;
@property (nonatomic, strong, nullable) id applicationTag;
@property (nonatomic, strong, nullable) id keyType;
@property (nonatomic, strong, nullable) id keySizeInBits;
@property (nonatomic, strong, nullable) id effectiveKeySize;
@property (nonatomic, strong, nullable) id canEncrypt;
@property (nonatomic, strong, nullable) id canDecrypt;
@property (nonatomic, strong, nullable) id canDerive;
@property (nonatomic, strong, nullable) id canSign;
@property (nonatomic, strong, nullable) id canVerify;
@property (nonatomic, strong, nullable) id canWrap;
@property (nonatomic, strong, nullable) id canUnwrap;
@property (nonatomic, strong, nullable) id synchronizable;

@end

@interface XZIdentityKeychain : XZKeychain

- (instancetype)initWithAttributes:(nullable NSArray<XZKeychainAttribute *> *)attributes;

@property (nonatomic, strong, nullable) id accessible;
@property (nonatomic, strong, nullable) id accessControl;
@property (nonatomic, strong, nullable) id accessGroup;
@property (nonatomic, strong, nullable) id certificateType;
@property (nonatomic, strong, nullable) id certificateEncoding;
@property (nonatomic, strong, nullable) id label;
@property (nonatomic, strong, nullable) id subject;
@property (nonatomic, strong, nullable) id issuer;
@property (nonatomic, strong, nullable) id serialNumber;
@property (nonatomic, strong, nullable) id subjectKeyID;
@property (nonatomic, strong, nullable) id publicKeyHash;
@property (nonatomic, strong, nullable) id synchronizable;

//@property (nonatomic, strong, nullable) XZKeychainAttribute Accessible;
//@property (nonatomic, strong, nullable) XZKeychainAttribute AccessControl;
//@property (nonatomic, strong, nullable) XZKeychainAttribute AccessGroup;
@property (nonatomic, strong, nullable) id keyClass;
//@property (nonatomic, strong, nullable) XZKeychainAttribute Label;
@property (nonatomic, strong, nullable) id applicationLabel;
@property (nonatomic, strong, nullable) id isPermanent;
@property (nonatomic, strong, nullable) id applicationTag;
@property (nonatomic, strong, nullable) id keyType;
@property (nonatomic, strong, nullable) id keySizeInBits;
@property (nonatomic, strong, nullable) id effectiveKeySize;
@property (nonatomic, strong, nullable) id canEncrypt;
@property (nonatomic, strong, nullable) id canDecrypt;
@property (nonatomic, strong, nullable) id canDerive;
@property (nonatomic, strong, nullable) id canSign;
@property (nonatomic, strong, nullable) id canVerify;
@property (nonatomic, strong, nullable) id canWrap;
@property (nonatomic, strong, nullable) id canUnwrap;
//@property (nonatomic, strong, nullable) XZKeychainAttribute Synchronizable;

@end

NS_ASSUME_NONNULL_END
