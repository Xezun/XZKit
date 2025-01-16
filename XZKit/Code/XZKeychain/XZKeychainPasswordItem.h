//
//  XZKeychainPasswordItem.h
//  KeyChain
//
//  Created by Xezun on 2025/1/13.
//  Copyright © 2025 Xezun Individual. All rights reserved.
//

#import "XZKeychainItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZKeychainPasswordItem : XZKeychainItem
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
@end

@interface XZKeychainGenericPasswordItem : XZKeychainPasswordItem
/// kSecAttrService: CFStringRef
@property (nonatomic) NSString *service;
/// 通用属性，XZKeychain 把它作为管理 XZKeychainTypeGenericPassword 类型钥匙串的唯一标识符。
/// kSecAttrGeneric: CFStringRef
@property (nonatomic) NSData *userInfo;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

@interface XZKeychainInternetPasswordItem : XZKeychainPasswordItem
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
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

NS_ASSUME_NONNULL_END
