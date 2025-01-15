//
//  XZKeychainPasswordItem.h
//  KeyChain
//
//  Created by 徐臻 on 2025/1/13.
//  Copyright © 2025 人民网. All rights reserved.
//

#import "XZKeychainItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZKeychainGenericPasswordItem : XZKeychainItem
/// kSecAttrCreationDate: CFDateRef
@property (nonatomic) NSDate *creationDate;
/// kSecAttrModificationDate: CFDateRef
@property (nonatomic) NSDate *modificationDate;
/// kSecAttrDescription: CFStringRef
@property (nonatomic) NSString *description;
/// kSecAttrComment: CFStringRef
@property (nonatomic) NSString *comment;
/// kSecAttrCreator: CFNumberRef
@property (nonatomic) UInt32 creator;
/// kSecAttrType: CFNumberRef
@property (nonatomic) UInt32 type;
/// kSecAttrIsInvisible: CFBooleanRef
@property (nonatomic, setter=setInvisible:) BOOL isInvisible;
/// kSecAttrIsNegative: CFBooleanRef
@property (nonatomic, setter=setNegative:) BOOL isNegative;
/// kSecAttrAccount: CFStringRef
@property (nonatomic) NSString *account;

/// kSecAttrService: CFStringRef
@property (nonatomic) NSString *service;
/// 通用属性，XZKeychain 把它作为管理 XZKeychainTypeGenericPassword 类型钥匙串的唯一标识符。
/// kSecAttrGeneric: CFStringRef
@property (nonatomic) NSData *userInfo;
@end

@interface XZKeychainInternetPasswordItem : XZKeychainGenericPasswordItem
/// kSecAttrService: CFStringRef
@property (nonatomic) NSString *service NS_UNAVAILABLE;
/// 通用属性，XZKeychain 把它作为管理 XZKeychainTypeGenericPassword 类型钥匙串的唯一标识符。
/// kSecAttrGeneric: CFStringRef
@property (nonatomic) NSData *userInfo NS_UNAVAILABLE;

/// kSecAttrSecurityDomain: CFStringRef
@property (nonatomic) NSString *securityDomain;
/// kSecAttrServer: CFStringRef
@property (nonatomic) NSString *server;
/// kSecAttrProtocol: CFStringRef
@property (nonatomic) NSString *protocol;
/// kSecAttrAuthenticationType: CFStringRef
@property (nonatomic) NSString *authenticationType;
/// kSecAttrPort: CFStringRef
@property (nonatomic) NSUInteger port;
/// kSecAttrPath: CFStringRef
@property (nonatomic) NSString *path;
@end

NS_ASSUME_NONNULL_END
