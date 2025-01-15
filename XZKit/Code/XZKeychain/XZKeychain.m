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

// 设置钥匙串类型的键名
#define kXZKeychainTypeKey  (NSString *)kSecClass

static NSString * _Nonnull NSStringFromKeychainType(XZKeychainType type) {
    switch (type) {
        case XZKeychainTypeGenericPassword:
            return (NSString *)kSecClassGenericPassword;
            break;
        case XZKeychainTypeInternetPassword:
            return (NSString *)kSecClassInternetPassword;
            break;
        case XZKeychainTypeCertificate:
            return (NSString *)kSecClassCertificate;
            break;
        case XZKeychainTypeKey:
            return (NSString *)kSecClassKey;
            break;
        case XZKeychainTypeIdentity:
            return (NSString *)kSecClassIdentity;
            break;
        case XZKeychainTypeNotSupported:
            
        default:
            return @"XZKeychainTypeNotSupported";
            break;
    }
}

static  NSString * _Nonnull NSStringFromKeychainAttribute(XZKeychainAttribute attribute) {
    switch (attribute) {
        case XZKeychainAttributeAccessible:
            return (id)kSecAttrAccessible;
            break;
        case XZKeychainAttributeAccessControl:
            return (id)kSecAttrAccessControl;
            break;
        case XZKeychainAttributeAccessGroup:
            return (id)kSecAttrAccessGroup;
            break;
        case XZKeychainAttributeCreationDate:
            return (id)kSecAttrCreationDate;
            break;
        case XZKeychainAttributeModificationDate:
            return (id)kSecAttrModificationDate;
            break;
        case XZKeychainAttributeDescription:
            return (id)kSecAttrDescription;
            break;
        case XZKeychainAttributeComment:
            return (id)kSecAttrComment;
            break;
        case XZKeychainAttributeCreator:
            return (id)kSecAttrCreator;
            break;
        case XZKeychainAttributeType:
            return (id)kSecAttrType;
            break;
        case XZKeychainAttributeLabel:
            return (id)kSecAttrLabel;
            break;
        case XZKeychainAttributeIsInvisible:
            return (id)kSecAttrIsInvisible;
            break;
        case XZKeychainAttributeIsNegative:
            return (id)kSecAttrIsNegative;
            break;
        case XZKeychainAttributeAccount:
            return (id)kSecAttrAccount;
            break;
        case XZKeychainAttributeService:
            return (id)kSecAttrService;
            break;
        case XZKeychainAttributeGeneric:
            return (id)kSecAttrGeneric;
            break;
        case XZKeychainAttributeSynchronizable:
            return (id)kSecAttrSynchronizable;
            break;
            //XZKeychainInternetPassword 支持的属性：
            // XZKeychainAttributeAccessible,
            // XZKeychainAttributeAccessControl,
            // XZKeychainAttributeAccessGroup,
            // XZKeychainAttributeCreationDate,
            // XZKeychainAttributeModificationDate,
            // XZKeychainAttributeDescription,
            // XZKeychainAttributeComment,
            // XZKeychainAttributeCreator,
            // XZKeychainAttributeType,
            // XZKeychainAttributeLabel,
            // XZKeychainAttributeIsInvisible,
            // XZKeychainAttributeIsNegative,
            // XZKeychainAttributeAccount:
            
        case XZKeychainAttributeSecurityDomain:
            return (id)kSecAttrSecurityDomain;
            break;
        case XZKeychainAttributeServer:
            return (id)kSecAttrServer;
            break;
        case XZKeychainAttributeProtocol:
            return (id)kSecAttrProtocol;
            break;
        case XZKeychainAttributeAuthenticationType:
            return (id)kSecAttrAuthenticationType;
            break;
        case XZKeychainAttributePort:
            return (id)kSecAttrPort;
            break;
        case XZKeychainAttributePath:
            return (id)kSecAttrPath;
            break;
            // XZKeychainAttributeSynchronizable
            
            // XZKeychainCertificate 支持的属性：
            // XZKeychainAttributeAccessible,
            // XZKeychainAttributeAccessControl,
            // XZKeychainAttributeAccessGroup:
            
        case XZKeychainAttributeCertificateType:
            return (id)kSecAttrCertificateType;
            break;
        case XZKeychainAttributeCertificateEncoding:
            // XZKeychainAttributeLabel:
            return (id)kSecAttrCertificateEncoding;
            break;
        case XZKeychainAttributeSubject:
            return (id)kSecAttrSubject;
            break;
        case XZKeychainAttributeIssuer:
            return (id)kSecAttrIssuer;
            break;
        case XZKeychainAttributeSerialNumber:
            return (id)kSecAttrSerialNumber;
            break;
        case XZKeychainAttributeSubjectKeyID:
            return (id)kSecAttrSubjectKeyID;
            break;
        case XZKeychainAttributePublicKeyHash:
            return (id)kSecAttrPublicKeyHash;
            break;
            // XZKeychainAttributeSynchronizable
            
            // XZKeychainKey 支持的属性：
            // XZKeychainAttributeAccessible,
            // XZKeychainAttributeAccessControl,
            // XZKeychainAttributeAccessGroup:
            // XZKeychainAttributeLabel:
        case XZKeychainAttributeKeyClass:
            return (id)kSecAttrKeyClass;
            break;
        case XZKeychainAttributeApplicationLabel:
            return (id)kSecAttrApplicationLabel;
            break;
        case XZKeychainAttributeIsPermanent:
            return (id)kSecAttrIsPermanent;
            break;
        case XZKeychainAttributeApplicationTag:
            return (id)kSecAttrApplicationTag;
            break;
        case XZKeychainAttributeKeyType:
            return (id)kSecAttrKeyType;
            break;
        case XZKeychainAttributeKeySizeInBits:
            return (id)kSecAttrKeySizeInBits;
            break;
        case XZKeychainAttributeEffectiveKeySize:
            return (id)kSecAttrEffectiveKeySize;
            break;
        case XZKeychainAttributeCanEncrypt:
            return (id)kSecAttrCanEncrypt;
            break;
        case XZKeychainAttributeCanDecrypt:
            return (id)kSecAttrCanDecrypt;
            break;
        case XZKeychainAttributeCanDerive:
            return (id)kSecAttrCanDerive;
            break;
        case XZKeychainAttributeCanSign:
            return (id)kSecAttrCanSign;
            break;
        case XZKeychainAttributeCanVerify:
            return (id)kSecAttrCanVerify;
            break;
        case XZKeychainAttributeCanWrap:
            return (id)kSecAttrCanWrap;
            break;
        case XZKeychainAttributeCanUnwrap:
            return (id)kSecAttrCanUnwrap;
            break;
        default:
            return @"NotSupportedAttribute";
            break;
    }
}

static NSString * _Nonnull NSStringFromOSStaus(OSStatus status) {
    switch (status) {
        case errSecSuccess:
            return @"没有错误"; // No error
            break;
        case errSecUnimplemented:
            return @"该操作没有被执行"; // Function or operation not implemented.
            break;
        case errSecIO:
            return @"IO错误"; // I/O error (bummers)
            break;
        case errSecOpWr:
            return @"文件正在被使用"; // file already open with with write permission
            break;
        case errSecParam:
            return @"一个或多个参数错误"; // One or more parameters passed to a function where not valid.
            break;
        case errSecAllocate:
            return @"无法分配内存"; // Failed to allocate memory.
            break;
        case errSecUserCanceled:
            return @"用户取消了进程"; // User canceled the operation.
            break;
        case errSecBadReq:
            return @"参数错误或状态错误"; // Bad parameter or invalid state for operation.
            break;
        case errSecInternalComponent:
            return @"Internal Component.";
            break;
        case errSecNotAvailable:
            return @"无可用钥匙串，请重启设备"; // No keychain is available. You may need to restart your computer.
            break;
        case errSecDuplicateItem:
            return @"钥匙串已存在"; // The specified item already exists in the keychain.
            break;
        case errSecItemNotFound:
            return @"找不到指定的钥匙串"; // The specified item could not be found in the keychain.
            break;
        case errSecInteractionNotAllowed:
            return @"不允许的用户操作"; // User interaction is not allowed.
            break;
        case errSecDecode:
            return @"无法解码数据"; // Unable to decode the provided data.
            break;
        case errSecAuthFailed:
            return @"权限验证失败，用户名或密码不对"; // The user name or passphrase you entered is not correct.
        default:
            return @"未知错误";
            break;
    }
}

static BOOL XZKeychainHandleOSStatus(OSStatus statusCode, NSError *__autoreleasing  _Nullable *error) {
    if (statusCode == noErr) {
        return YES;
    }
    if (error != NULL) {
        NSDictionary *userinfo = nil;
        NSString *languageString = [[NSLocale preferredLanguages] firstObject];
        /**
         *  zh-Hans（简体）、zh-Hant（繁体）: < iOS 9.0
         *  zh-HK（香港繁体）：>= iOS 7.0
         *  zh-Hans-CN（简体）、zh-Hant-CN（繁体）、zh-TW（台湾繁体）：>= iOS 9.0
         */
        if ([languageString hasPrefix:@"zh-"]) {
            userinfo = @{NSLocalizedDescriptionKey: NSStringFromOSStaus(statusCode)};
        }
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:statusCode userInfo:userinfo];
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





