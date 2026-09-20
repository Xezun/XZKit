//
//  XZKeychainItem.h
//  KeyChain
//
//  Created by Xezun on 2025/1/13.
//  Copyright © 2025 Xezun Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef XZ_FRAMEWORK
#define XZ_KEYCHAIN_PRIVATE_METHOD
#else
#define XZ_KEYCHAIN_PRIVATE_METHOD NS_UNAVAILABLE
#endif

typedef NS_ENUM(NSUInteger, XZKeychainAccessibility) {
    /// 未设置 kSecAttrAccessible 属性，由系统采用默认行为（等价于 kSecAttrAccessibleWhenUnlocked）。
    XZKeychainAccessibilityNone,
    XZKeychainAccessibilityWhenPasscodeSetThisDeviceOnly,
    XZKeychainAccessibilityWhenUnlockedThisDeviceOnly,
    XZKeychainAccessibilityWhenUnlocked,
    XZKeychainAccessibilityAfterFirstUnlockThisDeviceOnly,
    XZKeychainAccessibilityAfterFirstUnlock,
};

/// SecAccessControl
/// TODO: 模型化
@interface XZKeychainAccessControl : NSObject
@property (nonatomic) SecAccessControlRef control;
@end

typedef NS_ENUM(NSUInteger, XZKeychainSynchronizability) {
    /// kCFBooleanFalse.
    XZKeychainSynchronizabilityFalse,
    /// kCFBooleanTrue.
    XZKeychainSynchronizabilityTrue,
    /// kSecAttrSynchronizableAny
    XZKeychainSynchronizabilityBoth,
};

/// XZKeychainItem 是所有钥匙串条目模型的抽象基类，封装了各类 kSecClass 共有的属性。
///
/// ## 核心属性
/// - **保存必需**：`data`（kSecValueData）——所有类型的钥匙串在调用 SecItemAdd 时均必须提供二进制数据；子类可基于该属性提供更便利的封装（如 XZKeychainPasswordItem.password）。
/// - **查询匹配**：由具体子类定义，详见各子类文档中的“主键属性”列表。XZKeychain 会将 item 的全部非空属性拼接为查询字典，属性越完整匹配越精准。
/// - **可选属性**：`accessible`、`accessControl`、`accessGroup`、`label`、`synchronizable` 均为访问控制与展示属性，不作为主键匹配依据（`accessGroup` 例外：在共享钥匙串场景下会参与匹配）。
///
/// ## 子类化
/// 子类必须重写 `-securityClass` 返回对应的 kSecClass 常量，否则调用时抛出 NSGenericException。
@interface XZKeychainItem : NSObject {
    @package
    NSMutableDictionary *_attributes;
}
@property (nonatomic, readonly) NSString *securityClass;

/// kSecAttrAccessible
@property (nonatomic) XZKeychainAccessibility accessible;
/// kSecAttrAccessControl
/// @note XZKeychainAccessControl 未实现 NSCopying，故使用 strong 而非 copy；如需避免外部修改，请传入新创建的实例。
@property (nonatomic, strong, nullable) XZKeychainAccessControl *accessControl;
/// 共享钥匙串的组标识。
///
/// 关于 AccessGroup 钥匙串共享的两种设置方法：
/// 1. 首先，需要在项目中创建一个如下结构的 plist 文件，将文件名作为 group 参数传入；
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
/// 2. 在 Target -> Capabilities -> Keychain Sharing 中设置。
/// 
/// > 模拟器（TARGET_IPHONE_SIMULATOR）没有代码签名，不存在分组，如果设置分组，添加或更新就会返回 -25243 (errSecNoAccessForItem) 错误。
///
/// - SeeAlso: kSecAttrAccessGroup
@property (nonatomic, copy, nullable) NSString *accessGroup;
/// kSecAttrLabel
@property (nonatomic, copy, nullable) NSString *label;
/// kSecAttrSynchronizable
@property (nonatomic) XZKeychainSynchronizability synchronizable;
/// 二进制数据。对于 keys 和 password 类型钥匙串，该数据是加密存储的。
@property (nonatomic, nullable) NSData *data;
- (instancetype)init XZ_KEYCHAIN_PRIVATE_METHOD;
@end



NS_ASSUME_NONNULL_END
