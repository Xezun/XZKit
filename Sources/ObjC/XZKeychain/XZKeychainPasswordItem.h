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

/// XZKeychainPasswordItem 是密码类钥匙串（Generic Password / Internet Password）的抽象基类，封装两者共有的属性。
///
/// ## 核心属性
/// - **保存必需**：`password`（内部写入 `data`/kSecValueData）。直接使用基类无法保存，请使用 XZKeychainGenericPasswordItem 或 XZKeychainInternetPasswordItem。
/// - **查询主键**：`account`（kSecAttrAccount）；其余主键属性由子类补充。
@interface XZKeychainPasswordItem : XZKeychainItem
/// 存储密码的便利方法，与访问 data 相同。
@property (nonatomic, copy, nullable) NSString *password;

/// kSecAttrCreationDate: CFDateRef
@property (nonatomic, nullable) NSDate *creationDate;
/// kSecAttrModificationDate: CFDateRef
@property (nonatomic, nullable) NSDate *modificationDate;
/// kSecAttrDescription: CFStringRef
/// @note 该属性对应钥匙串的 kSecAttrDescription，与 NSObject 的 -description 语义无关，故命名为 annotation 以避免覆盖 NSObject 的调试输出方法。
@property (nonatomic, nullable) NSString *annotation;
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

/// 通用密码钥匙串，对应 kSecClassGenericPassword。适用于应用内部保存任意用途的凭证（登录 token、本地密码、设备唯一标识等）。
///
/// ## 核心属性
/// - **保存必需**：
///   - `password`（写入 kSecValueData）——密码本体，缺失时 SecItemAdd 返回 errSecParam。
///   - `account`（kSecAttrAccount）——帐号名，主键之一，为空将导致后续无法精确匹配。
///   - `service`（kSecAttrService）——服务名，主键之一，与 `account` 共同构成唯一定位依据。
/// - **查询主键**：`account` + `service`；`accessGroup` 在共享钥匙串场景下也参与匹配。
/// - **可选属性**：`userInfo`（kSecAttrGeneric）用于存储附加识别信息，不参与主键匹配。
@interface XZKeychainGenericPasswordItem : XZKeychainPasswordItem
/// kSecAttrService: CFStringRef
@property (nonatomic, nullable) NSString *service;
/// 通用属性，XZKeychain 把它作为管理 XZKeychainTypeGenericPassword 类型钥匙串的唯一标识符。
/// kSecAttrGeneric: CFStringRef
@property (nonatomic, nullable) NSData *userInfo;
- (instancetype)init NS_DESIGNATED_INITIALIZER;
@end

/// 网络密码钥匙串，对应 kSecClassInternetPassword。专为保存“服务器-帐号-密码”三元组而设计。
///
/// ## 核心属性
/// - **保存必需**：
///   - `password`（写入 kSecValueData）——密码本体。
///   - `server`（kSecAttrServer）——服务器域名或 IP，缺失时 SecItemAdd 返回 errSecParam。
///   - `protocol`（kSecAttrProtocol）——协议类型（如 kSecAttrProtocolHTTPS），建议显式设置。
/// - **查询主键**：`account` + `server` + `protocol` + `authenticationType` + `port` + `path` + `securityDomain`；Apple 官方将这七个属性共同定义为主键，推荐至少设置 `account` + `server`。
/// - **可选属性**：`accessGroup` 在共享钥匙串场景下也参与匹配。
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
