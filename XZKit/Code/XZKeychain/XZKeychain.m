//
//  XZKeychain.m
//  Keychain
//
//  Created by iMac on 16/6/24.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZKeychain.h"
#import <objc/runtime.h>

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

#pragma mark - _XZKeychainValue

@interface _XZKeychainAttributeValue : NSObject

@property (nonatomic, strong) id originalValue;
@property (nonatomic, strong) id updatingValue;

@end

@implementation _XZKeychainAttributeValue

- (NSString *)description {
    return [NSString stringWithFormat:@"{originalValue: %@, updatingValue: %@}", self.originalValue, self.updatingValue];
}

@end

#pragma mark - XZKeychainItem

@interface XZKeychain () {
    NSMutableDictionary<NSString *, _XZKeychainAttributeValue *> *_attributes;
}

- (NSMutableDictionary<NSString *, _XZKeychainAttributeValue *> *)_XZKeychainAttributesIfLoaded;
- (NSMutableDictionary<NSString *, _XZKeychainAttributeValue *> *)_XZKeychainAttributesLazyLoad;

@end


@implementation XZKeychain

+ (instancetype)keychainWithType:(XZKeychainType)type {
    return [[self alloc] initWithType:type];
}

- (instancetype)init {
    return [self initWithType:(XZKeychainTypeGenericPassword)];
}

- (instancetype)initWithType:(XZKeychainType)type {
    self = [super init];
    if (self != nil) {
        _type = type;
    }
    return self;
}

#pragma mark - 私有方法

- (BOOL)_XZKeychainAttributesIsModified {
    BOOL isModified = NO;
    for (_XZKeychainAttributeValue *value in [self _XZKeychainAttributesIfLoaded].allValues) {
        if (value.originalValue != value.updatingValue) {
            isModified = YES;
            break;
        }
    }
    return isModified;
}



- (NSString *)_XZKeychainTypeString {
    NSString *typeString = NSStringFromKeychainType(self.type);
    return typeString;
}

- (NSMutableDictionary<NSString *,_XZKeychainAttributeValue *> *)_XZKeychainAttributesIfLoaded {
    return _attributes;
}

- (void)_XZKeychainSetAttributes:(NSMutableDictionary<NSString *,_XZKeychainAttributeValue *> *)attributes {
    if (_attributes != attributes) {
        _attributes = attributes;
    }
}

- (NSMutableDictionary<NSString *, _XZKeychainAttributeValue *> *)_XZKeychainAttributesLazyLoad {
    if (_attributes != nil) {
        return _attributes;
    }
    _attributes = [[NSMutableDictionary alloc] init];
    return _attributes;
}

// 设置属性
- (void)_XZKeychainSetValue:(id)aValue forAttributeKey:(NSString *)attributeKey {
    NSMutableDictionary *attributes = [self _XZKeychainAttributesLazyLoad];
    _XZKeychainAttributeValue *keychainValue = attributes[attributeKey];
    if (keychainValue == nil) {
        keychainValue = [[_XZKeychainAttributeValue alloc] init];
        attributes[attributeKey] = keychainValue;
    }
    keychainValue.updatingValue = aValue;
}

// 获取属性
- (id)_XZKeychainValueForAttributeKey:(NSString *)aKey {
    return [self _XZKeychainAttributesIfLoaded][aKey].updatingValue;
}

// 搜索钥匙串
+ (id)_XZKeychainSearch:(NSDictionary *)query statusCode:(OSStatus *)statusCode {
    id object = nil;
    CFTypeRef resultRef = NULL;
    OSStatus errorCode = SecItemCopyMatching((__bridge CFDictionaryRef)query, &resultRef);
    if (resultRef != NULL) {
        if (errorCode == noErr) {
            object = (__bridge id)(resultRef);
        }
        CFRelease(resultRef);
    }
    if (statusCode != NULL) {
        *statusCode = errorCode;
    }
    return object;
}

/**
 *  处理错误的方法
 */
+ (BOOL)_XZKeychainHandleOSStatus:(OSStatus)statusCode error:(NSError *__autoreleasing  _Nullable *)error {
    if (statusCode == noErr) {
        return YES;
    } else if (error != NULL) {
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

/**
 *  将一个字典的值转换成 _XZKeychainAttributeValue 对象。
 */
+ (NSMutableDictionary<NSString *, _XZKeychainAttributeValue *> *)_XZKeychainAttributeValueDictionaryFromObjectDictionary:(NSDictionary<NSString *, id> *)objectDictionary {
    NSMutableDictionary *resultDictionary = [[NSMutableDictionary alloc] initWithCapacity:objectDictionary.count];
    [objectDictionary enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        _XZKeychainAttributeValue *value = [[_XZKeychainAttributeValue alloc] init];
        value.originalValue = obj;
        value.updatingValue = obj;
        resultDictionary[key] = value;
    }];
    return resultDictionary;
}

/**
 *  创建一个 XZKeychain 对象的私有方法。
 *
 *  @param type             XZKeychain 类型
 *  @param objectDictionary 属性值字典，字典的值是普通对象。
 *
 *  @return XZKeychain 对象。
 */
+ (XZKeychain *)_XZKeychainWithType:(XZKeychainType)type objectDictionary:(NSDictionary<NSString *, id> *)objectDictionary {
    XZKeychain *keychain = [[XZKeychain alloc] initWithType:type];
    NSMutableDictionary *attributes = [self _XZKeychainAttributeValueDictionaryFromObjectDictionary:objectDictionary];
    [keychain _XZKeychainSetAttributes:attributes];
    return keychain;
}

#pragma mark - 公开方法

- (NSDictionary *)attributes {
    NSMutableDictionary *tmp = nil;
    if ([self _XZKeychainAttributesIfLoaded].count > 0) {
        tmp = [[NSMutableDictionary alloc] init];
        [[self _XZKeychainAttributesIfLoaded] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
            tmp[key] = obj.updatingValue;
        }];
    }
    return tmp;
}

- (void)setValue:(id)value forAttribute:(XZKeychainAttribute)attribute {
    if ([self valueForAttribute:attribute] != value) {
        NSString *aKey = NSStringFromKeychainAttribute(attribute);
        [self _XZKeychainSetValue:value forAttributeKey:aKey];
    }
}

- (void)setObject:(id)anObject forAttribute:(XZKeychainAttribute)attribute {
    [self setValue:anObject forAttribute:attribute];
}

- (void)setObject:(id)anObject atIndexedSubscript:(XZKeychainAttribute)attribute {
    [self setValue:anObject forAttribute:attribute];
}

- (id)valueForAttribute:(XZKeychainAttribute)attribute {
    NSString *aKey = NSStringFromKeychainAttribute(attribute);
    return [self _XZKeychainValueForAttributeKey:aKey];
}

- (id)objectForAttribute:(XZKeychainAttribute)attribute {
    return [self valueForAttribute:attribute];
}

- (id)objectAtIndexedSubscript:(XZKeychainAttribute)attribute {
    return [self valueForAttribute:attribute];
}

// 获取数据
- (BOOL)search:(NSError *__autoreleasing  _Nullable *)error {
    // 创建查询条件
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    query[kXZKeychainTypeKey]       = NSStringFromKeychainType(self.type);
    query[(id)kSecMatchLimit]       = (id)kSecMatchLimitOne;    // 返回一个
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;       // 返回“非加密属性”字典
    [self._XZKeychainAttributesIfLoaded enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
        query[key] = obj.updatingValue;  // 按照目前的值查找
    }];
    
    // 执行搜索
    OSStatus statusCode = errSecBadReq;                     // 状态码
    NSDictionary *attributes = [XZKeychain _XZKeychainSearch:query statusCode:&statusCode];
    [attributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        _XZKeychainAttributeValue *value = [self _XZKeychainAttributesLazyLoad][key];
        if (value == nil) {
            value = [[_XZKeychainAttributeValue alloc] init];
            [self _XZKeychainAttributesLazyLoad][key] = value;
        }
        value.originalValue = obj; // 只改变了原始值。
        if (value.updatingValue == nil) {
            value.updatingValue = obj;
        }
    }];
    // 处理返回值
    return [XZKeychain _XZKeychainHandleOSStatus:statusCode error:error];
}

// 重置数据
- (void)reset {
    [[self _XZKeychainAttributesIfLoaded] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.updatingValue = obj.originalValue;
    }];
}

#pragma mark - 增

- (BOOL)insert:(NSError * _Nullable * _Nullable)error {
    OSStatus statusCode = errSecBadReq;
    __block BOOL isNewOne = YES, isModified = NO;
    [self._XZKeychainAttributesIfLoaded enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
        if (obj.originalValue == nil) {
            if (!isModified && obj.originalValue != obj.updatingValue) {
                isModified = YES;
            }
        } else {
            isNewOne = NO;
            *stop = YES;
        }
    }];
    if (isNewOne && isModified) {
        NSMutableDictionary *updatingAttributes = [NSMutableDictionary dictionary];
        [[self _XZKeychainAttributesIfLoaded] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
            updatingAttributes[key] = obj.updatingValue;
        }];
        // 插入新钥匙串，要指定钥匙串类型
        updatingAttributes[kXZKeychainTypeKey] = [self _XZKeychainTypeString];
        updatingAttributes[(id)(kSecReturnAttributes)] = (id)kCFBooleanTrue;  // 返回属性
        CFDictionaryRef resultRef = NULL;
        statusCode = SecItemAdd((__bridge CFDictionaryRef)updatingAttributes, (CFTypeRef *)&resultRef);
        if (resultRef != NULL) {
            if (statusCode == noErr) {
                NSDictionary *objectDictionary = (__bridge NSDictionary *)resultRef;
                NSMutableDictionary *attributes = [XZKeychain _XZKeychainAttributeValueDictionaryFromObjectDictionary:objectDictionary];
                [self _XZKeychainSetAttributes:attributes];
            }
            CFRelease(resultRef);
        }
    }
    return [XZKeychain _XZKeychainHandleOSStatus:statusCode error:error];
}

#pragma mark - 删

- (BOOL)remove:(NSError * _Nullable * _Nullable)error {
    OSStatus statusCode = errSecBadReq;
    NSMutableDictionary *attributes = [self _XZKeychainAttributesIfLoaded];
    if (attributes != nil && attributes.count > 0) { // 当参数不为 0 的时候。
        NSMutableDictionary *queryOrg = [NSMutableDictionary dictionary];
        NSMutableDictionary *queryCur = [NSMutableDictionary dictionary];
        [attributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
            queryOrg[key] = obj.originalValue;
            queryCur[key] = obj.updatingValue;
        }];
        // 如果有原始属性，按照原始属性匹配，如果没有按照目前属性匹配。
        NSMutableDictionary *query = (queryOrg.count > 0 ? queryOrg : queryCur);
        if (query.count > 0) {
            query[kXZKeychainTypeKey] = [self _XZKeychainTypeString];
            statusCode = SecItemDelete((__bridge CFDictionaryRef)query);
            if (statusCode == errSecItemNotFound) {
                statusCode = noErr;
            }
        }
        if (statusCode == noErr) {
            [attributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
                obj.originalValue = nil;  // 把原始值清空
            }];
        }
    }
    return [XZKeychain _XZKeychainHandleOSStatus:statusCode error:error];
}

#pragma mark - 改

- (BOOL)update:(NSError * _Nullable * _Nullable)error {
    OSStatus statusCode = errSecUnimplemented;  // 默认是未执行
    if ([self _XZKeychainAttributesIsModified]) {
        NSMutableDictionary *query = [NSMutableDictionary dictionary];
        NSMutableDictionary *updatingAttributes = [NSMutableDictionary dictionary];
        [[self _XZKeychainAttributesIfLoaded] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
            query[key] = obj.originalValue;  // 将原始属性作为搜索条件
            if (obj.updatingValue == nil) {
                updatingAttributes[key] = (__bridge id)kCFNull;
            } else {
                updatingAttributes[key] = obj.updatingValue;
            }
        }];
        if (query.count > 0) { // 搜索条件存在时，才执行更新
            // 设置类型
            query[kXZKeychainTypeKey] = [self _XZKeychainTypeString];
            // 执行更新
            statusCode = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)updatingAttributes);
            if (statusCode == noErr) {
                // 更新成功，把新值复制到原始值
                [[self _XZKeychainAttributesIfLoaded] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
                    obj.originalValue = obj.updatingValue;
                }];
            }
        }
    }
    return [XZKeychain _XZKeychainHandleOSStatus:statusCode error:error];
}

#pragma mark - 查

- (NSArray<XZKeychain *> *)match:(NSError *__autoreleasing  _Nullable *)error {
    OSStatus statusCode             = errSecBadReq; // 状态码
    NSMutableArray *keychainItems   = nil;          // 返回值
    
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    query[kXZKeychainTypeKey]       = NSStringFromKeychainType(self.type);
    query[(id)kSecMatchLimit]       = (id)kSecMatchLimitAll;    // 返回所有
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;       // 返回“非加密属性”字典
    [self._XZKeychainAttributesIfLoaded enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
        query[key] = obj.updatingValue;
    }];
    
    // 执行搜索
    NSArray *items = [XZKeychain _XZKeychainSearch:query statusCode:&statusCode];
    if (statusCode == errSecItemNotFound) {  // 如果是没找到，就不处理错误了。
        statusCode = noErr;
    }
    if ([XZKeychain _XZKeychainHandleOSStatus:statusCode error:error] && items.count > 0) {
        keychainItems = [[NSMutableArray alloc] init];
        [items enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull itemDict, NSUInteger idx, BOOL * _Nonnull stop) {
            XZKeychain *item = [[XZKeychain alloc] initWithType:self.type];
            NSMutableDictionary *attributes = [XZKeychain _XZKeychainAttributeValueDictionaryFromObjectDictionary:itemDict];
            [item _XZKeychainSetAttributes:attributes];
            [keychainItems addObject:item];
        }];
    }
    return keychainItems;
}

+ (NSArray<XZKeychain *> *)match:(NSArray<XZKeychain *> *)matches errors:(NSDictionary<XZKeychain *, NSError *> *__autoreleasing  _Nullable * _Nullable)errors {
    NSMutableArray *keychainItems   = nil;
    NSMutableDictionary *errorsDict = nil;
    for (XZKeychain *item in matches) {
        NSError *tmpError = nil;
        NSArray *tmpArray = [item match:&tmpError];
        if (keychainItems == nil) {
            keychainItems = (NSMutableArray *)tmpArray;
        } else {
            [keychainItems addObjectsFromArray:tmpArray];
        }
        if (errors != NULL && tmpError != nil) {
            if (errorsDict == nil) {
                errorsDict = [NSMutableDictionary dictionary];
            }
            errorsDict[item] = tmpError;
        }
    }
    if (errors != nil) {  // errors 不等于 nil 时，error 一定不为 NULL。
        *errors = errorsDict;
    }
    return keychainItems;
}

+ (NSArray<XZKeychain *> *)allKeychains {
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    query[(id)kSecMatchLimit]       = (id)kSecMatchLimitAll;    // 返回所有
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;       // 返回“非加密属性”字典
    for (XZKeychainType type = 0; type < XZKeychainTypeNotSupported; type++) {
        query[kXZKeychainTypeKey]       = NSStringFromKeychainType(type);
        NSArray<NSDictionary *> *items = [self _XZKeychainSearch:query statusCode:NULL];
        for (NSDictionary *dict in items) {
            XZKeychain *keychain = [XZKeychain _XZKeychainWithType:type objectDictionary:dict];
            [matches addObject:keychain];
        }
    }
    return matches;
}

+ (NSArray<XZKeychain *> *)allKeychainsWithType:(XZKeychainType)type {
    NSMutableArray *matches = [[NSMutableArray alloc] init];
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    query[(id)kSecMatchLimit]       = (id)kSecMatchLimitAll;    // 返回所有
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue;       // 返回“非加密属性”字典
    query[kXZKeychainTypeKey]       = NSStringFromKeychainType(type);
    NSArray<NSDictionary *> *items = [self _XZKeychainSearch:query statusCode:NULL];
    for (NSDictionary *dict in items) {
        XZKeychain *keychain = [XZKeychain _XZKeychainWithType:type objectDictionary:dict];
        [matches addObject:keychain];
    }
    return matches;
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

@end

/**
 *  从钥匙串中获取密码的键名
 */
#define kXZGenericPasswordKeychainPasswordKey (id)kSecValueData
NSString * const _Nonnull kXZGenericPasswordKeychainDeviceIdentifier = @"com.mlibai.keychain.device_identifier";

@implementation XZKeychain (XZGenericPasswordKeychain)

+ (instancetype)keychainWithIdentifier:(NSString *)identifier {
    return [self keychainWithAccessGroup:nil identifier:identifier];
}

+ (instancetype)keychainWithAccessGroup:(NSString *)accessGroup identifier:(NSString *)identifier {
    XZKeychain *keychain = [[XZKeychain alloc] initWithType:(XZKeychainTypeGenericPassword)];
    keychain.identifier = identifier;
    keychain.accessGroup = accessGroup;
    // [keychain search:NULL];
    return keychain;
}

+ (BOOL)setPassword:(NSString *)password forAccount:(NSString *)account accessGroup:(NSString *)accessGroup identifier:(NSString *)identifier {
    XZKeychain *keychain = [XZKeychain keychainWithAccessGroup:accessGroup identifier:identifier];
    keychain.account = account;
    if (password == nil) { // 为 nil 删除钥匙串
        return [keychain remove:NULL];
    } else { // 不为 nil ，尝试更新或添加
        if ([keychain search:NULL]) {
            keychain.password = password;
            return [keychain update:NULL];
        } else {
            keychain.password = password;
            return [keychain insert:NULL];
        }
    }
}

+ (BOOL)setPassword:(NSString *)password forAccount:(NSString *)account identifier:(NSString *)identifier {
    return [self setPassword:password forAccount:account accessGroup:nil identifier:identifier];
}

+ (NSString *)passwordForAccount:(NSString *)account accessGroup:(NSString *)accessGroup identifier:(NSString *)identifier {
    NSString *password = nil;
    XZKeychain *keychain = [XZKeychain keychainWithAccessGroup:accessGroup identifier:identifier];
    if ([keychain search:NULL] && [keychain.account isEqualToString:account]) {
        password = keychain.password;
    }
    return password;
}

+ (NSString *)passwordForAccount:(NSString *)account identifier:(NSString *)identifier {
    return [self passwordForAccount:account accessGroup:nil identifier:identifier];
}

- (NSString *)identifier {
    return [self valueForAttribute:(XZKeychainAttributeGeneric)];
}

- (void)setIdentifier:(NSString *)identifier {
    [self setValue:identifier forAttribute:(XZKeychainAttributeGeneric)];
}

- (NSString *)account {
    return [self valueForAttribute:(XZKeychainAttributeAccount)];
}

- (void)setAccount:(NSString *)account {
    [self setValue:account forAttribute:(XZKeychainAttributeAccount)];
}

- (NSString *)password {
    NSString *password = nil;
    NSData *passwordData = [self _XZKeychainValueForAttributeKey:kXZGenericPasswordKeychainPasswordKey];
    if (passwordData == nil) {
        // 获取存储 password 的 _XZKeychainAttributeValue
        if ([self _XZKeychainAttributesIfLoaded][kXZGenericPasswordKeychainPasswordKey] == nil) {
            passwordData = [self _XZGenericPasswordKeychainLoadPasswordAttributeValue:NULL].updatingValue;
        }
    }
    if (passwordData != nil) {
        password = [[NSString alloc] initWithData:passwordData encoding:(NSUTF8StringEncoding)];
    }
    return password;
}

- (void)setPassword:(NSString *)password {
    if (self.password != password) {
        NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
        [self _XZKeychainSetValue:passwordData forAttributeKey:kXZGenericPasswordKeychainPasswordKey];
    }
}

- (NSString *)accessGroup {
    return [self valueForAttribute:(XZKeychainAttributeAccessGroup)];
}

- (void)setAccessGroup:(NSString *)accessGroup {
    [self setValue:accessGroup forAttribute:(XZKeychainAttributeAccessGroup)];
}

- (_XZKeychainAttributeValue *)_XZGenericPasswordKeychainLoadPasswordAttributeValue:(NSError **)error {
    NSMutableDictionary *attributes = [self _XZKeychainAttributesLazyLoad];
    _XZKeychainAttributeValue *passwordValue = attributes[kXZGenericPasswordKeychainPasswordKey];
    if (attributes.count > 0) {
        // 查询密码：密码并不是随属性一起返回的，需要重新在钥匙串中查询。
        NSMutableDictionary *passwordQuery = [NSMutableDictionary dictionary];
        [attributes enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, _XZKeychainAttributeValue * _Nonnull obj, BOOL * _Nonnull stop) {
            passwordQuery[key] = obj.originalValue;
        }];
        if (passwordQuery.count > 0) {
            // 设置返回值为 CFDataRef
            passwordQuery[(id)kSecReturnData] = (id)kCFBooleanTrue;
            // 钥匙串类型
            passwordQuery[kXZKeychainTypeKey] = [self _XZKeychainTypeString];
            
            OSStatus statusCode = noErr;
            NSData *passwordData = [XZKeychain _XZKeychainSearch:passwordQuery statusCode:&statusCode];
            if ([XZKeychain _XZKeychainHandleOSStatus:statusCode error:error]) {
                if (passwordValue == nil) {
                    passwordValue = [[_XZKeychainAttributeValue alloc] init];
                    attributes[kXZGenericPasswordKeychainPasswordKey] = passwordValue;
                }
                passwordValue.originalValue = passwordData;
                passwordValue.updatingValue = passwordData;
            } else {
                NSLog(@"XZKeychain: {identifier: %@, account: %@}，发生严重错误，从钥匙串获取密码失败！", self.identifier, self.account);
            }
        }
    }
    return passwordValue;
}

+ (NSString *)deviceIdentifier {
    return [self deviceIdentifierForAccessGroup:nil];
}

+ (NSString *)deviceIdentifierForAccessGroup:(NSString *)accessGroup {
    NSString *deviceIdentifier = nil;
    XZKeychain *keychain = [XZKeychain keychainWithAccessGroup:accessGroup identifier:kXZGenericPasswordKeychainDeviceIdentifier];
    if ([keychain search:NULL]) {
        deviceIdentifier = [keychain valueForAttribute:(XZKeychainAttributeDescription)];
    } else {
        NSString *identifier = [[NSUUID UUID] UUIDString];
        [keychain setValue:identifier forAttribute:(XZKeychainAttributeDescription)];
        if ([keychain insert:NULL]) {
            deviceIdentifier = identifier;
        }
    }
    return deviceIdentifier;
}

@end





