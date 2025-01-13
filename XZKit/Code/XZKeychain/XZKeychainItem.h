//
//  XZKeychainItem.h
//  KeyChain
//
//  Created by 徐臻 on 2025/1/13.
//  Copyright © 2025 人民网. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XZKeychainAccessibility) {
    XZKeychainAccessibilityWhenPasscodeSetThisDeviceOnly,
    XZKeychainAccessibilityWhenUnlocked,
    XZKeychainAccessibilityAfterFirstUnlockThisDeviceOnly,
    XZKeychainAccessibilityAfterFirstUnlock,
    XZKeychainAccessibilityAlwaysThisDeviceOnly,
    XZKeychainAccessibilityAlways
};

/// SecAccessControl
@interface XZKeychainAccessControl : NSObject
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
- (instancetype)init NS_UNAVAILABLE;
@end



NS_ASSUME_NONNULL_END
