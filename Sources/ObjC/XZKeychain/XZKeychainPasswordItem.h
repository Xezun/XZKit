//
//  XZKeychainPasswordItem.h
//  KeyChain
//
//  Created by Xezun on 2025/1/13.
//  Copyright © 2025 Xezun Individual. All rights reserved.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZKeychainItem.h>
#else
#import "XZKeychainItem.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZKeychainPasswordItem : XZKeychainItem
/// 存储密码的便利方法，与访问 data 相同。
@property (nonatomic, copy, nullable) NSString *password;

/// kSecAttrCreationDate: CFDateRef
@property (nonatomic, nullable) NSDate *creationDate;
/// kSecAttrModificationDate: CFDateRef
@property (nonatomic, nullable) NSDate *modificationDate;
/// kSecAttrDescription: CFStringRef
@property (nonatomic, nullable) NSString *description;
/// kSecAttrComment: CFStringRef
@property (nonatomic, nullable) NSString *comment;
/// kSecAttrCreator: CFNumberRef
@property (nonatomic) UInt32 creator;
/// kSecAttrType: CFNumberRef
@property (nonatomic) UInt32 type;
/// kSecAttrIsInvisible: CFBooleanRef
@property (nonatomic, setter=setInvisible:) BOOL isInvisible;
/// kSecAttrIsNegative: CFBooleanRef
@property (nonatomic, setter=setNegative:) BOOL isNegative;
/// kSecAttrAccount: CFStringRef
@property (nonatomic, nullable) NSString *account;
@end

@interface XZKeychainGenericPasswordItem : XZKeychainPasswordItem
/// kSecAttrService: CFStringRef
@property (nonatomic, nullable) NSString *service;
/// 通用属性，XZKeychain 把它作为管理 XZKeychainTypeGenericPassword 类型钥匙串的唯一标识符。
/// kSecAttrGeneric: CFStringRef
@property (nonatomic, nullable) NSData *userInfo;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

@interface XZKeychainInternetPasswordItem : XZKeychainPasswordItem
/// kSecAttrSecurityDomain: CFStringRef
@property (nonatomic, nullable) NSString *securityDomain;
/// kSecAttrServer: CFStringRef
@property (nonatomic, nullable) NSString *server;
/// kSecAttrProtocol: CFStringRef
@property (nonatomic, nullable) NSString *protocol;
/// kSecAttrAuthenticationType: CFStringRef
@property (nonatomic, nullable) NSString *authenticationType;
/// kSecAttrPort: CFStringRef
@property (nonatomic) NSUInteger port;
/// kSecAttrPath: CFStringRef
@property (nonatomic, nullable) NSString *path;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
