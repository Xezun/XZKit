//
//  XZKeychainItem.m
//  KeyChain
//
//  Created by 徐臻 on 2025/1/13.
//  Copyright © 2025 人民网. All rights reserved.
//

#import "XZKeychainItem.h"

@implementation XZKeychainItem

- (instancetype)init {
    self = [super init];
    if (self) {
        // 容器
        _attributes = [NSMutableDictionary dictionaryWithCapacity:64];
        // 默认匹配一个
        _attributes[(id)kSecMatchLimit] = (id)kSecMatchLimitOne;
        // 返回属性
        _attributes[(NSString *)kSecReturnAttributes] = (id)kCFBooleanTrue;
    }
    return self;
}

- (XZKeychainAccessibility)accessible {
    NSString *value = _attributes[(id)kSecAttrAccessible];
    if ([value isEqualToString:(id)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly]) {
        return XZKeychainAccessibilityWhenPasscodeSetThisDeviceOnly;
    }
    if ([value isEqualToString:(id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly]) {
        return XZKeychainAccessibilityWhenUnlockedThisDeviceOnly;
    }
    if ([value isEqualToString:(id)kSecAttrAccessibleWhenUnlocked]) {
        return XZKeychainAccessibilityWhenUnlocked;
    }
    if ([value isEqualToString:(id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly]) {
        return XZKeychainAccessibilityAfterFirstUnlockThisDeviceOnly;
    }
    if ([value isEqualToString:(id)kSecAttrAccessibleAfterFirstUnlock]) {
        return XZKeychainAccessibilityAfterFirstUnlock;
    }
    return XZKeychainAccessibilityNone;
}

- (void)setAccessible:(XZKeychainAccessibility)accessible {
    switch (accessible) {
        case XZKeychainAccessibilityNone:
            _attributes[(id)kSecAttrAccessible] = nil;
            break;
        case XZKeychainAccessibilityWhenPasscodeSetThisDeviceOnly:
            _attributes[(id)kSecAttrAccessible] = (id)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly;
            break;
        case XZKeychainAccessibilityWhenUnlockedThisDeviceOnly:
            _attributes[(id)kSecAttrAccessible] = (id)kSecAttrAccessibleWhenUnlockedThisDeviceOnly;
            break;
        case XZKeychainAccessibilityWhenUnlocked:
            _attributes[(id)kSecAttrAccessible] = (id)kSecAttrAccessibleWhenUnlocked;
            break;
        case XZKeychainAccessibilityAfterFirstUnlockThisDeviceOnly:
            _attributes[(id)kSecAttrAccessible] = (id)kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly;
            break;
        case XZKeychainAccessibilityAfterFirstUnlock:
            _attributes[(id)kSecAttrAccessible] = (id)kSecAttrAccessibleAfterFirstUnlock;
            break;
    }
}

- (XZKeychainAccessControl *)accessControl {
    return _attributes[(id)kSecAttrAccessControl];
}

- (void)setAccessControl:(XZKeychainAccessControl *)accessControl {
    _attributes[(id)kSecAttrAccessControl] = accessControl;
}

- (NSString *)accessGroup {
    return _attributes[(id)kSecAttrAccessGroup];
}

- (void)setAccessGroup:(NSString *)accessGroup {
    _attributes[(id)kSecAttrAccessGroup] = accessGroup;
}

- (NSString *)label {
    return _attributes[(id)kSecAttrLabel];
}

- (void)setLabel:(NSString *)label {
    _attributes[(id)kSecAttrLabel] = label;
}

- (XZKeychainSynchronizability)synchronizable {
    id value = _attributes[(id)kSecAttrSynchronizable];
    if ([value isKindOfClass:[NSString class]]) {
        return XZKeychainSynchronizabilityBoth;
    }
    if ([value boolValue]) {
        return XZKeychainSynchronizabilityTrue;
    }
    return XZKeychainSynchronizabilityFalse;
}

- (void)setSynchronizable:(XZKeychainSynchronizability)synchronizable {
    switch (synchronizable) {
        case XZKeychainSynchronizabilityFalse:
            _attributes[(id)kSecAttrSynchronizable] = @(NO);
            break;
        case XZKeychainSynchronizabilityTrue:
            _attributes[(id)kSecAttrSynchronizable] = @(YES);
            break;
        case XZKeychainSynchronizabilityBoth:
            _attributes[(id)kSecAttrSynchronizable] = (id)kSecAttrSynchronizableAny;
            break;
    }
}

@end


@implementation XZKeychainAccessControl

- (void)dealloc {
    if (_control) {
        CFRelease(_control);
        _control = nil;
    }
}

@synthesize control = _control;

- (void)setControl:(SecAccessControlRef)control {
    if (_control != control) {
        if (_control) {
            CFRelease(_control);
        }
        if (control != nil) {
            _control = (void *)CFRetain(control);
        } else {
            _control = nil;
        }
    }
}

- (SecAccessControlRef)control {
    return _control;
}

@end
