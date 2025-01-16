//
//  XZKeychainItem.h
//  KeyChain
//
//  Created by Xezun on 2025/1/13.
//  Copyright © 2025 Xezun Individual. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Security;

NS_ASSUME_NONNULL_BEGIN

#ifdef XZ_FRAMEWORK
#define XZ_KEYCHAIN_PRIVATE_METHOD
#else
#define XZ_KEYCHAIN_PRIVATE_METHOD NS_UNAVAILABLE
#endif

typedef NS_ENUM(NSUInteger, XZKeychainAccessibility) {
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

@interface XZKeychainItem : NSObject {
    @package
    NSMutableDictionary *_attributes;
}
/// kSecAttrAccessible
@property (nonatomic) XZKeychainAccessibility accessible;
/// kSecAttrAccessControl
@property (nonatomic, copy) XZKeychainAccessControl *accessControl;
/// 模拟器（TARGET_IPHONE_SIMULATOR）没有代码签名，不存在分组。
/// 如果设置分组，添加或更新就会返回 -25243 (errSecNoAccessForItem) 错误。
/// kSecAttrAccessGroup
@property (nonatomic, copy) NSString *accessGroup;
/// kSecAttrLabel
@property (nonatomic, copy) NSString *label;
/// kSecAttrSynchronizable
@property (nonatomic) XZKeychainSynchronizability synchronizable;
- (instancetype)init XZ_KEYCHAIN_PRIVATE_METHOD;
@end



NS_ASSUME_NONNULL_END
