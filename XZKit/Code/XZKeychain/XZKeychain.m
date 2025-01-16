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

static BOOL XZKeychainHandleOSStatus(OSStatus statusCode, NSError *__autoreleasing  _Nullable *error) {
    if (statusCode == noErr) {
        return YES;
    }
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:statusCode userInfo:nil];
    }
    return NO;
}

#pragma mark - XZKeychainItem

@interface XZKeychain () {
    // 查询条件
    NSDictionary * _Nonnull _query;
    /// 钥匙串原始信息。
    NSMutableDictionary * _Nullable _attributes;
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
        _query = [item->_attributes copy];
        _attributes = nil;
    }
    return self;
}

// 重置数据

- (nullable NSDictionary *)attributes:(NSError * _Nullable * _Nullable)error {
    if (_attributes) {
        return _attributes;
    }
    CFTypeRef resultRef = NULL;
    OSStatus const code = SecItemCopyMatching((__bridge CFDictionaryRef)_query, &resultRef);
    if (XZKeychainHandleOSStatus(code, error)) {
        _attributes = (__bridge id)(resultRef);
    }
    return _attributes;
}

- (BOOL)search:(NSError * _Nullable __autoreleasing *)error {
    NSDictionary * const attributes = [self attributes:error];
    if (attributes == nil) {
        return NO;
    }
    [_item->_attributes addEntriesFromDictionary:attributes];
    return YES;
}

#pragma mark - 增

- (BOOL)insert:(NSError * _Nullable * _Nullable)error {
    // 新添加条目，直接使用 item 数据
    NSDictionary * const attributes = [_item->_attributes copy];
    CFTypeRef result = NULL;
    OSStatus const code = SecItemAdd((__bridge CFDictionaryRef)attributes, &result);
    if (XZKeychainHandleOSStatus(code, error)) {
        // 保存数据到 item 中
        [_item->_attributes addEntriesFromDictionary:(__bridge id)result];
        if (result) {
            CFRelease(result);
        }
        _attributes = nil;
        return YES;
    }
    return NO;
}

#pragma mark - 删

- (BOOL)remove:(NSError * _Nullable * _Nullable)error {
    NSDictionary * const attributes = [self attributes:error];
    if (attributes == nil) {
        return YES;
    }
    OSStatus const code = SecItemDelete((__bridge CFDictionaryRef)attributes);
    if (XZKeychainHandleOSStatus(code, error)) {
        _attributes = nil;
        return YES;
    }
    return NO;
}

#pragma mark - 改

- (BOOL)update:(NSError * _Nullable * _Nullable)error {
    NSDictionary * const oldAttributes = [self attributes:error];
    if (oldAttributes == nil) {
        return NO;
    }
    NSMutableDictionary *newAttributes = _item->_attributes;
    OSStatus const code = SecItemUpdate((__bridge CFDictionaryRef)oldAttributes, (__bridge CFDictionaryRef)newAttributes);
    if (XZKeychainHandleOSStatus(code, error)) {
        _attributes = nil;
        return YES;
    }
    return NO;
}

- (NSData *)data {
    NSData *data = _item->_attributes[(id)kSecReturnData];
    if (data == nil) {
        NSDictionary *oldAttributes = [self attributes:NULL];
        if (oldAttributes == nil) {
            return nil;
        }
        [_item->_attributes addEntriesFromDictionary:oldAttributes];
        
        NSData *data = oldAttributes[(id)kSecReturnData];
        if (data == nil) {
            // 查询密码：密码并不是随属性一起返回的，需要重新在钥匙串中查询。
            NSMutableDictionary *newAttributes = [oldAttributes mutableCopy];
            newAttributes[(id)kSecReturnData] = (id)kCFBooleanTrue;
            
            CFTypeRef resultRef = NULL;
            OSStatus const code = SecItemCopyMatching((__bridge CFDictionaryRef)newAttributes, &resultRef);
            if (XZKeychainHandleOSStatus(code, NULL)) {
                data = (__bridge id)resultRef ?: (id)kCFNull;
                _item->_attributes[(id)kSecReturnData] = data;
            }
        }
    }
    return (data == (id)kCFNull ? nil : data);
}

- (void)setData:(NSData *)data {
    if (_item->_attributes[(id)kSecReturnData] == data) {
        return;
    }
    
    NSDictionary *oldAttributes = [self attributes:NULL];
    if (oldAttributes == nil) {
        if (![self insert:NULL]) {
            return; // 无法添加新的
        }
        oldAttributes = [_item->_attributes copy];
    }
    NSMutableDictionary *newAttributes = [oldAttributes mutableCopy];
    newAttributes[(id)kSecValueData] = data ?: (id)kCFNull;
    OSStatus const code = SecItemUpdate((__bridge CFDictionaryRef)oldAttributes, (__bridge CFDictionaryRef)newAttributes);
    if (XZKeychainHandleOSStatus(code, NULL)) {
        _item->_attributes[(id)kSecValueData] = data ?: (id)kCFNull;
    }
}

@end

#import "XZKeychainPasswordItem.h"

@implementation XZKeychain (XZGenericPasswordKeychain)

+ (BOOL)insertAccount:(NSString *)account password:(NSString *)password identifier:(NSString *)identifier inGroup:(NSString *)accessGroup error:(NSError *__autoreleasing  _Nullable *)error {
    XZKeychainGenericPasswordItem *item = [[XZKeychainGenericPasswordItem alloc] init];
    item.account = account;
    item.accessGroup = accessGroup;
    item.userInfo = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    XZKeychain *keychain = [XZKeychain keychainForItem:item];
    keychain.data = password ? [password dataUsingEncoding:NSUTF8StringEncoding] : (id)kCFNull;
    if (![keychain update:error]) {
        return [keychain insert:error];
    }
    return NO;
}

+ (BOOL)insertAccount:(NSString *)account password:(NSString *)password identifier:(NSString *)identifier error:(NSError *__autoreleasing  _Nullable *)error {
    return [self insertAccount:account password:password identifier:identifier inGroup:nil error:error];
}

+ (NSString *)searchPasswordForAccount:(NSString *)account identifier:(NSString *)identifier inGroup:(NSString *)accessGroup error:(NSError *__autoreleasing  _Nullable *)error {
    XZKeychainGenericPasswordItem *item = [[XZKeychainGenericPasswordItem alloc] init];
    item.account = account;
    item.accessGroup = accessGroup;
    item.userInfo = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    NSData *data = [XZKeychain keychainForItem:item].data;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)searchPasswordForAccount:(NSString *)account identifier:(NSString *)identifier error:(NSError *__autoreleasing  _Nullable *)error {
    return [self searchPasswordForAccount:account identifier:identifier inGroup:nil error:error];
}

+ (NSString *)UDID {
    return [self UDIDForGroup:nil];
}

+ (NSString *)UDIDForGroup:(NSString *)accessGroup {
    XZKeychainGenericPasswordItem *item = [[XZKeychainGenericPasswordItem alloc] init];
    item.account = @"UDID";
    item.accessGroup = accessGroup;
    item.userInfo = [@"com.xezun.XZKeychain.UDID" dataUsingEncoding:NSUTF8StringEncoding];
    
    XZKeychain *keychain = [XZKeychain keychainForItem:item];

    NSDictionary *attributes = [keychain attributes:nil];
    if (attributes == nil) {
        item.description = NSUUID.UUID.UUIDString;
        [keychain insert:nil];
    }
    return item.description;
}

@end





