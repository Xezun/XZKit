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

static BOOL XZKeychainHandleOSStatus(OSStatus statusCode, NSError *__autoreleasing  _Nullable *error);
/// 过滤属性字典中作为“显式 nil”占位的 kCFNull（SecItemAdd/SecItemCopyMatching/SecItemDelete 不接受 kCFNull 作为查询参数，否则返回 errSecParam）。
/// @note SecItemUpdate 中 kCFNull 具有“删除属性”语义，因此更新字典不能调用本方法。
static NSDictionary *XZKeychainAttributesForQuery(NSDictionary *attributes);

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
        NSMutableDictionary *query = [XZKeychainAttributesForQuery(item->_attributes) mutableCopy];
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
        // SecItemCopyMatching 返回的 CFTypeRef 遵循 Create Rule，需使用 CFBridgingRelease 将所有权转移给 ARC，否则会造成内存泄漏。
        _attributes = CFBridgingRelease(result) ?: @{};
    } else if (result != NULL) {
        CFRelease(result);
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
        id data = _item->_attributes[(id)kSecValueData];
        // data 为 nil 或 kCFNull（setData:nil 设置的占位）时，需要重新从钥匙串获取二进制数据。
        if (data == nil || data == (id)kCFNull) {
            // 查询密码：密码并不是随属性一起返回的，需要重新在钥匙串中查询。
            NSMutableDictionary *query = [_query mutableCopy];
            [query addEntriesFromDictionary:attributes];
            query[(id)kSecReturnData] = (id)kCFBooleanTrue;
            
            CFTypeRef result = NULL;
            OSStatus const code = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
            if (XZKeychainHandleOSStatus(code, error)) {
                // 同 searchAttributesIfNeeded: 中的 CF 内存管理说明。
                NSData *valueData = CFBridgingRelease(result);
                _item->_attributes[(id)kSecValueData] = valueData ?: (id)kCFNull;
                return YES;
            } else if (result != NULL) {
                CFRelease(result);
            }
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 增

- (BOOL)insert:(NSError * _Nullable * _Nullable)error {
    // 新添加条目，直接使用 item 数据（需过滤 kCFNull 占位，SecItemAdd 不接受）。
    NSMutableDictionary * const query = [XZKeychainAttributesForQuery(_item->_attributes) mutableCopy];
    query[(id)kSecClass] = _item.securityClass;
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;
    CFTypeRef result = NULL;
    OSStatus const code = SecItemAdd((__bridge CFDictionaryRef)query, &result);
    if (XZKeychainHandleOSStatus(code, error)) {
        // 保存数据到 item 中（同样需遵循 Create Rule）。
        if (result) {
            _attributes = CFBridgingRelease(result);
            [_item->_attributes addEntriesFromDictionary:_attributes];
        } else {
            _attributes = nil;
        }
        return YES;
    } else if (result != NULL) {
        CFRelease(result);
    }
    return NO;
}

#pragma mark - 删

- (BOOL)delete:(NSError * _Nullable * _Nullable)error {
    // 先根据已有条件查寻（第一条）原始数据，然后根据这个去删除
    NSError *searchError = nil;
    NSDictionary * const attributes = [self searchAttributesIfNeeded:&searchError];
    if (attributes == nil) {
        // 仅当“钥匙串本身不存在”时才视为删除成功；其他错误（如权限、参数）仍应返回 NO。
        if (searchError.code == errSecItemNotFound && [searchError.domain isEqualToString:NSOSStatusErrorDomain]) {
            if (error != NULL) {
                *error = nil;
            }
            return YES;
        }
        if (error != NULL) {
            *error = searchError;
        }
        return NO;
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
    NSString * const cachedUDID = [NSUserDefaults.standardUserDefaults stringForKey:XZKeychainKeyUDID];
    if (cachedUDID.length > 0) {
        return cachedUDID;
    }
    
    XZKeychainGenericPasswordItem *item = [[XZKeychainGenericPasswordItem alloc] init];
    item.accessGroup = accessGroup;
    item.account     = XZKeychainKeyUDID;
    item.service     = XZKeychainKeyUDID;
    item.userInfo    = [XZKeychainKeyUDID dataUsingEncoding:NSUTF8StringEncoding];
    
    XZKeychain<XZKeychainGenericPasswordItem *> *keychain = [XZKeychain keychainForItem:item];

    NSError *error = nil;
    if ([keychain search:NO error:&error]) {
        NSString *const storedUDID = item.annotation;
        if (storedUDID.length > 0) {
            // 同步到 NSUserDefaults 以加速下次读取。
            [NSUserDefaults.standardUserDefaults setValue:storedUDID forKey:XZKeychainKeyUDID];
            return storedUDID;
        }
    }
    
    NSString * const newUDID = NSUUID.UUID.UUIDString;
    item.annotation = newUDID;
    // kSecValueData 是 kSecClassGenericPassword 类型钥匙串的必需属性，缺失时 SecItemAdd 会返回 errSecParam。
    item.password   = newUDID;
    
    if ([keychain insert:&error]) {
        // 插入成功后再写入本地缓存，避免将未能持久化的 UDID 归入长期缓存。
        [NSUserDefaults.standardUserDefaults setValue:newUDID forKey:XZKeychainKeyUDID];
    }
#if DEBUG
    else {
        NSLog(@"[XZKeychain] 存储 UDID 到钥匙串失败：%@", error);
    }
#endif
    
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

static NSDictionary *XZKeychainAttributesForQuery(NSDictionary *attributes) {
    if (attributes.count == 0) {
        return @{};
    }
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:attributes.count];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        if (value != (id)kCFNull) {
            result[key] = value;
        }
    }];
    return result;
}
