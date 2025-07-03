//
//  XZKeychain.m
//  Keychain
//
//  Created by iMac on 16/6/24.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZKeychain.h"
#import <objc/runtime.h>
#import "XZKeychainPasswordItem.h"
#import "XZLog.h"

static BOOL XZKeychainHandleOSStatus(OSStatus statusCode, NSError *__autoreleasing  _Nullable *error);

@interface XZKeychain () {
    // 查询条件
    NSDictionary * _Nonnull _query;
    /// 钥匙串原始信息。
    NSDictionary * _Nullable _attributes;
}
@end

@implementation XZKeychain

+ (XZKeychain *)keychainForItem:(XZKeychainItem *)item {
    NSAssert(item.class != [XZKeychainItem class], @"必须使用 %@ 的子类", [XZKeychainItem class]);
    return [[self alloc] initWithItem:item];
}

- (instancetype)initWithItem:(XZKeychainItem *)item {
    self = [super init];
    if (self) {
        _item = item;
        NSMutableDictionary *query = [item->_attributes mutableCopy];
        query[(id)kSecClass] = item.securityClass;
        _query = [query copy];
        _attributes = nil;
    }
    return self;
}

- (nullable NSDictionary *)searchAttributesIfNeeded:(NSError * _Nullable * _Nullable)error {
    if (_attributes) {
        return _attributes;
    }
    NSMutableDictionary *query = [_query mutableCopy];
    // 匹配一个
    query[(id)kSecMatchLimit] = (id)kSecMatchLimitOne;
    // 返回属性
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;
    // 查询钥匙串
    CFTypeRef result = NULL;
    OSStatus const code = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (XZKeychainHandleOSStatus(code, error)) {
        _attributes = (__bridge id)(result) ?: @{};
    }
    return _attributes;
}

#pragma mark - 查

- (BOOL)search:(BOOL)secure error:(NSError * _Nullable __autoreleasing *)error {
    NSDictionary * const attributes = [self searchAttributesIfNeeded:error];
    if (!attributes) {
        return NO;
    }
    
    [_item->_attributes addEntriesFromDictionary:attributes];
    
    if (secure) {
        NSData *data = _item->_attributes[(id)kSecValueData];
        if (data == nil) {
            // 查询密码：密码并不是随属性一起返回的，需要重新在钥匙串中查询。
            NSMutableDictionary *query = [_query mutableCopy];
            [query addEntriesFromDictionary:attributes];
            query[(id)kSecReturnData] = (id)kCFBooleanTrue;
            
            CFTypeRef result = NULL;
            OSStatus const code = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
            if (XZKeychainHandleOSStatus(code, error)) {
                data = (__bridge id)result ?: (id)kCFNull;
                _item->_attributes[(id)kSecValueData] = data;
                return YES;
            }
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 增

- (BOOL)insert:(NSError * _Nullable * _Nullable)error {
    // 新添加条目，直接使用 item 数据
    NSMutableDictionary * const query = [_item->_attributes mutableCopy];
    query[(id)kSecClass] = _item.securityClass;
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;
    CFTypeRef result = NULL;
    OSStatus const code = SecItemAdd((__bridge CFDictionaryRef)query, &result);
    if (XZKeychainHandleOSStatus(code, error)) {
        // 保存数据到 item 中
        if (result) {
            _attributes = (__bridge id)result;
            [_item->_attributes addEntriesFromDictionary:_attributes];
        } else {
            _attributes = nil;
        }
        return YES;
    }
    return NO;
}

#pragma mark - 删

- (BOOL)delete:(NSError * _Nullable * _Nullable)error {
    // 先根据已有条件查寻（第一条）原始数据，然后根据这个去删除
    NSDictionary * const attributes = [self searchAttributesIfNeeded:error];
    if (attributes == nil) {
        return YES;
    }
    NSMutableDictionary *query = [_query mutableCopy];
    [query addEntriesFromDictionary:attributes];
    // query[(id)kSecMatchLimit] = (id)kSecMatchLimitOne;
    
    OSStatus const code = SecItemDelete((__bridge CFDictionaryRef)query);
    if (XZKeychainHandleOSStatus(code, error)) {
        _attributes = nil;
        return YES;
    }
    return NO;
}

#pragma mark - 改

- (BOOL)update:(NSError * _Nullable * _Nullable)error {
    NSDictionary * const oldAttributes = [self searchAttributesIfNeeded:error];
    if (oldAttributes == nil) {
        return XZKeychainHandleOSStatus(errSecItemNotFound, error);
    }
    
    NSMutableDictionary *query = [_query mutableCopy];
    [query addEntriesFromDictionary:oldAttributes];
    // query[(id)kSecMatchLimit] = (id)kSecMatchLimitOne; // 不能添加此条件
    
    NSDictionary * const newAttributes = _item->_attributes;
    OSStatus const code = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)newAttributes);
    if (XZKeychainHandleOSStatus(code, error)) {
        _attributes = nil;
        return YES;
    }
    return NO;
}

@end

#define XZKeychainKeyUDID @"com.xezun.XZKeychain.UDID"

@implementation XZKeychain (XZExtendedKeychain)

+ (XZKeychain<XZKeychainInternetPasswordItem *> *)keychainWithAccount:(NSString *)account domain:(NSString *)domain accessGroup:(NSString *)accessGroup {
    XZKeychainInternetPasswordItem *item = [[XZKeychainInternetPasswordItem alloc] init];
    item.account = account;
    item.accessGroup = accessGroup;
    item.server = domain;
    item.accessGroup = accessGroup;
    
    return [XZKeychain keychainForItem:item];
}

+ (XZKeychain<XZKeychainInternetPasswordItem *> *)keychainWithAccount:(NSString *)account domain:(NSString *)domain {
    return [self keychainWithAccount:account domain:domain accessGroup:nil];
}

+ (NSString *)UDID {
    return [self UDIDForGroup:nil];
}

+ (NSString *)UDIDForGroup:(NSString *)accessGroup {
    NSString * const UDID = [NSUserDefaults.standardUserDefaults stringForKey:XZKeychainKeyUDID];
    if (UDID) {
        return UDID;
    }
    
    XZKeychainGenericPasswordItem *item = [[XZKeychainGenericPasswordItem alloc] init];
    item.accessGroup = accessGroup;
    item.account     = XZKeychainKeyUDID;
    item.userInfo    = [XZKeychainKeyUDID dataUsingEncoding:NSUTF8StringEncoding];
    
    XZKeychain<XZKeychainGenericPasswordItem *> *keychain = [XZKeychain keychainForItem:item];

    NSError *error = nil;
    if ([keychain search:NO error:&error]) {
        return item.description;
    }
    
    NSString * const newUDID = NSUUID.UUID.UUIDString;
    
    [NSUserDefaults.standardUserDefaults setValue:newUDID forKey:XZKeychainKeyUDID];
    item.description = newUDID;
    
    if (![keychain insert:&error]) {
        XZLog(XZLogSystem.XZKit, @"[XZKeychain] 无法在钥匙串中保存 UDID 数据：%@", error);
    }
    
    return newUDID;
}

@end



static BOOL XZKeychainHandleOSStatus(OSStatus statusCode, NSError *__autoreleasing  _Nullable *error) {
    if (statusCode == errSecSuccess) {
        if (error != NULL) {
            *error = nil;
        }
        return YES;
    }
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:statusCode userInfo:nil];
    }
    return NO;
}
