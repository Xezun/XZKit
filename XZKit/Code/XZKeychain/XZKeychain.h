//
//  XZKeychain.h
//  Keychain
//
//  Created by iMac on 16/6/24.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Security;

NS_ASSUME_NONNULL_BEGIN

enum {
    XZKeychainErrorSuccess = noErr
};


 /// XZKeychain 的类型，以下类型与实际包含的类型是相对应的。
typedef NS_ENUM(NSUInteger, XZKeychainType) {
    XZKeychainTypeGenericPassword = 0,  // 通用密码
    XZKeychainTypeInternetPassword,     // 网络密码
    XZKeychainTypeCertificate,          // 证书
    XZKeychainTypeKey,                  // 密钥
    XZKeychainTypeIdentity,             // 验证
    XZKeychainTypeNotSupported          // 不支持的属性，请勿使用，主要是提供给 for 循环用的。
};

// 钥匙串所拥有的属性
typedef NS_ENUM(NSUInteger, XZKeychainAttribute) {
    // 钥匙串 XZKeychainGenericPassword 支持的属性：
    XZKeychainAttributeAccessible,
    XZKeychainAttributeAccessControl,
    // 模拟器（TARGET_IPHONE_SIMULATOR）没有代码签名，不存在分组。
    // 如果设置分组，添加或更新就会返回 -25243 (errSecNoAccessForItem) 错误。
    XZKeychainAttributeAccessGroup,
    XZKeychainAttributeCreationDate,
    XZKeychainAttributeModificationDate,
    XZKeychainAttributeDescription,
    XZKeychainAttributeComment,
    XZKeychainAttributeCreator,
    XZKeychainAttributeType,
    XZKeychainAttributeLabel,
    XZKeychainAttributeIsInvisible,
    XZKeychainAttributeIsNegative,
    XZKeychainAttributeAccount,  // 帐号
    XZKeychainAttributeService,
    XZKeychainAttributeGeneric,  // 通用属性，XZKeychain 建议把它作为管理 XZKeychainTypeGenericPassword 类型钥匙串的唯一标识符。
    XZKeychainAttributeSynchronizable,
    
    /* 钥匙串 XZKeychainInternetPassword 支持的属性：
     // 注释掉的属性不表示没有，而是已经在列表中了，下同
     XZKeychainAttributeAccessible,
     XZKeychainAttributeAccessControl,
     XZKeychainAttributeAccessGroup,
     XZKeychainAttributeCreationDate,
     XZKeychainAttributeModificationDate,
     XZKeychainAttributeDescription,
     XZKeychainAttributeComment,
     XZKeychainAttributeCreator,
     XZKeychainAttributeType,
     XZKeychainAttributeLabel,
     XZKeychainAttributeIsInvisible,
     XZKeychainAttributeIsNegative,
     XZKeychainAttributeAccount, */
    XZKeychainAttributeSecurityDomain,
    XZKeychainAttributeServer,
    XZKeychainAttributeProtocol,
    XZKeychainAttributeAuthenticationType,
    XZKeychainAttributePort,
    XZKeychainAttributePath,
    // XZKeychainAttributeSynchronizable
    
    // 钥匙串 XZKeychainCertificate 支持的属性：
    // XZKeychainAttributeAccessible,
    // XZKeychainAttributeAccessControl,
    // XZKeychainAttributeAccessGroup,
    XZKeychainAttributeCertificateType,
    XZKeychainAttributeCertificateEncoding,
    // XZKeychainAttributeLabel,
    XZKeychainAttributeSubject,
    XZKeychainAttributeIssuer,
    XZKeychainAttributeSerialNumber,
    XZKeychainAttributeSubjectKeyID,
    XZKeychainAttributePublicKeyHash,
    // XZKeychainAttributeSynchronizable
    
    // 钥匙串 XZKeychainKey 支持的属性：
    // XZKeychainAttributeAccessible,
    // XZKeychainAttributeAccessControl,
    // XZKeychainAttributeAccessGroup,
    XZKeychainAttributeKeyClass,
    // XZKeychainAttributeLabel,
    XZKeychainAttributeApplicationLabel,
    XZKeychainAttributeIsPermanent,
    XZKeychainAttributeApplicationTag,
    XZKeychainAttributeKeyType,
    XZKeychainAttributeKeySizeInBits,
    XZKeychainAttributeEffectiveKeySize,
    XZKeychainAttributeCanEncrypt,
    XZKeychainAttributeCanDecrypt,
    XZKeychainAttributeCanDerive,
    XZKeychainAttributeCanSign,
    XZKeychainAttributeCanVerify,
    XZKeychainAttributeCanWrap,
    XZKeychainAttributeCanUnwrap
    // XZKeychainAttributeSynchronizable
    
    // 钥匙串 XZKeychainIdentity 支持的属性:
    // 由于 XZKeychainIdentity 钥匙串同时包含“私钥”和“证书”，
    // 所以它同时具有 XZKeychainKey 和 XZKeychainCertificate 两种钥匙串的属性。
};

@class XZKeychainItem;

typedef NS_ENUM(NSUInteger, XZKeychainStatus) {
    XZKeychainStatusInsert,
    XZKeychainStatusUpdate,
    XZKeychainStatusDelete,
};

/// XZKeychain 类封装了系统“钥匙串”API的“增删改查”的操作，XZKeychain 所保存的信息只是钥匙串属性信息的一个拷贝，对钥匙串的属性的操作，在调用相应的方法前，并不影响“钥匙串”实际的信息。
@interface XZKeychain<Item: XZKeychainItem *> : NSObject

@property (nonatomic, readonly) Item item;

+ (XZKeychain<Item> *)keychainForItem:(Item)item NS_SWIFT_NAME(init(for:));
- (instancetype)init NS_UNAVAILABLE;

/// 将 item 保存到钥匙串中，如果 item 已经存在，则更新 item 的属性信息。
- (BOOL)search:(NSError * _Nullable * _Nullable)error;

/// 更新钥匙串。若钥匙串中，有多条与 item 相匹配的条目，那么只会更新第一条，更新后 item 将指向被更新的对象。
///
/// @param error 如果发生错误，可用此参数输出。
///
/// @return YES 更新成功；NO 更新失败。
- (BOOL)update:(NSError * _Nullable * _Nullable)error;


/// 根据当前的属性，匹配删除第一个符合条件的钥匙串。如果钥匙串本身不存在，则也返回删除成功。
///
/// @param error 如果发生错误，可用此参数输出。
///
/// @return YES 删除成功；NO 删除失败。
- (BOOL)remove:(NSError * _Nullable * _Nullable)error;


/// 根据当前已设置的属性，创建一个钥匙串。如果创建钥匙串成功，对象会与该钥匙串创建关联。如果是一个已经调用 -search: 方法并返回成功的对象，调用本方法将会返回错误。
///
/// @param error 如果发生错误，可用此参数输出。
///
/// @return YES 表示成功创建；NO 创建失败。
- (BOOL)insert:(NSError * _Nullable * _Nullable)error;

/// 钥匙串加密存储的数据。
@property (nonatomic, nullable) NSData *data;

@end


/// 关于 AccessGroup 钥匙串共享的两种设置方法：
/// 1, 首先，需要在项目中创建一个如下结构的 plist 文件，将文件名作为 group 参数传入；
///    然后，在 Target -> Build settings -> Code Sign Entitlements 设置签名授权为该 plist 文件。
/// ```plist
/// <dict>
///     <key>keychain-access-groups</key>
///     <array>
///         <string>YOUR_APP_ID_HERE.com.yourcompany.keychain</string>
///         <string>YOUR_APP_ID_HERE.com.yourcompany.keychainSuite</string>
///     </array>
/// </dict>
/// ```
/// 2, 在 Target -> Capabilities -> Keychain Sharing 中设置。
@interface XZKeychain (XZGenericPasswordKeychain)

/// 保存密码的便利方法。
///
/// @param password    密码
/// @param account     帐号
/// @param accessGroup 分组
/// @param identifier  唯一标识
///
/// @return YES 保存成功，NO 保存失败
+ (BOOL)setPassword:(NSString * _Nullable)password forAccount:(NSString * _Nullable)account identifier:(NSString * _Nullable)identifier inGroup:(NSString * _Nullable)accessGroup;
+ (BOOL)setPassword:(NSString * _Nullable)password forAccount:(NSString * _Nullable)account identifier:(NSString * _Nullable)identifier;

/// 获取密码的便利方法。
///
/// @param account     帐号
/// @param accessGroup 分组
/// @param identifier  唯一标识
///
/// @return 已保存的密码。如果没有找到则返回 nil 。
+ (NSString * _Nullable)passwordForAccount:(NSString * _Nullable)account identifier:(NSString * _Nullable)identifier inGroup:(NSString * _Nullable)accessGroup;
+ (NSString * _Nullable)passwordForAccount:(NSString * _Nullable)account identifier:(NSString * _Nullable)identifier;

/// 以 kXZGenericPasswordKeychainDeviceIdentifier 作为唯一标识符，以 UUID 作为设备 ID 的钥匙串。
/// 因为存储在钥匙串里的内容，不会因为删除 App 而清空，故可以用已储存的 UUID 作设备的唯一标识。
+ (NSString * _Nullable)UDID;
+ (NSString * _Nullable)UDIDForGroup:(NSString * _Nullable)accessGroup NS_SWIFT_NAME(UDID(for:));

@end

NS_ASSUME_NONNULL_END





