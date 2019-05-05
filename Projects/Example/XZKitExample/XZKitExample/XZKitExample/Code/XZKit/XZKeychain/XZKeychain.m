//
//  XZKeychain.m
//  XZKit
//
//  Created by M. X. Z. on 16/7/28.
//  Copyright © 2016年 J. W. Z. All rights reserved.
//

#import "XZKeychain.h"
#import <objc/runtime.h>

#import "XZKeychainAttribute.h"

@import Security;

static NSString * _Nonnull NSStringFromXZKeychainType(XZKeychainType type);
static Class _Nullable XZKeychainSubclassForType(XZKeychainType type);

static id XZKeychainAttributeMatcher(XZKeychainType type, NSArray<XZKeychainAttribute *> *attributes, NSError **error, BOOL limitOne);
static void XZKeychainAttributeChecker(NSArray<XZKeychainAttribute*> *attributes, BOOL * _Nonnull isNew, BOOL * _Nonnull isModified);
static BOOL XZKeychainHandleError(OSStatus errorCode, NSError **error);

// 设置钥匙串类型的键名
#define kXZKeychainTypeKey       (NSString *)kSecClass

#define kXZKeychainSecretDataKey (id)kSecValueData

@interface XZKeychain () {
    NSMutableDictionary<NSString *, XZKeychainAttribute *> *_attributes;
}

@end

@interface XZKeychainAttribute (XZKeychainInternal)

@property (nonatomic, strong, nullable) id originalValue;
@property (nonatomic, strong, nullable) id updatingValue;

@end

@implementation XZKeychain

+ (XZKeychain *)keychain:(NSArray<XZKeychainAttribute *> *)attributes ofType:(XZKeychainType)type error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    NSDictionary<NSString *, id> *attributeDict = XZKeychainAttributeMatcher(type, attributes, error, YES);
    if (attributeDict.count == 0) {
        return nil;
    }
    
    NSMutableDictionary<NSString *, XZKeychainAttribute *> *keyedAttributes = [NSMutableDictionary dictionary];
    for (XZKeychainAttribute *tmpAttr in attributes) {
        keyedAttributes[tmpAttr.name] = tmpAttr;
    }
    [attributeDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        XZKeychainAttribute *attribute = keyedAttributes[key];
        if (attribute == nil) {
            attribute = [[XZKeychainAttribute alloc] initWithName:key originalValue:obj];
            keyedAttributes[key] = attribute;
        } else {
            attribute.originalValue = obj;
            attribute.updatingValue = nil;
        }
    }];
    
    return [self _keychainWithAttributes:keyedAttributes type:type];
}

+ (NSArray<XZKeychain *> *)keychains:(NSArray<XZKeychainAttribute *> * const)attributes ofType:(XZKeychainType)type error:(NSError *__autoreleasing  _Nullable * _Nullable)error {
    NSArray<NSDictionary<NSString *, id> *> *attributeDicts = XZKeychainAttributeMatcher(type, attributes, error, NO);
    NSInteger const count = attributeDicts.count;
    if (count == 0) {
        return nil;
    }
    
    NSMutableArray<XZKeychain *> *keychains = [[NSMutableArray alloc] initWithCapacity:count];
    
    NSMutableDictionary<NSString *, XZKeychainAttribute *> *keyedAttributes = [NSMutableDictionary dictionary];
    for (XZKeychainAttribute *tmpAttr in attributes) {
        keyedAttributes[tmpAttr.name] = tmpAttr;
    }
    
    for (NSInteger i = 0; i < count; i++) {
        NSMutableDictionary<NSString *, XZKeychainAttribute *> *tmpKeyedAttributes = nil;
        if (i > 0) {
            tmpKeyedAttributes = [NSMutableDictionary dictionaryWithCapacity:keyedAttributes.count];
            [keyedAttributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZKeychainAttribute * _Nonnull obj, BOOL * _Nonnull stop) {
                tmpKeyedAttributes[key] = obj.copy;
            }];
        } else {
            tmpKeyedAttributes = keyedAttributes;
        }
        [attributeDicts[i] enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            XZKeychainAttribute *attribute = tmpKeyedAttributes[key];
            if (attribute == nil) {
                attribute = [[XZKeychainAttribute alloc] initWithName:key originalValue:obj];
                tmpKeyedAttributes[key] = attribute;
            } else {
                attribute.originalValue = obj;
                attribute.updatingValue = nil;
            }
        }];
        [keychains addObject:[self _keychainWithAttributes:tmpKeyedAttributes type:type]];
    }
    
    return keychains;
}

/** 参数 attributes 将直接被使用 */
+ (instancetype)_keychainWithAttributes:(nonnull NSMutableDictionary<NSString *, XZKeychainAttribute *> *)attributes type:(XZKeychainType)type {
    return [(XZKeychain *)[XZKeychainSubclassForType(type) alloc] _initWithAttributes:attributes type:type];
}

- (instancetype)_initWithAttributes:(nonnull NSMutableDictionary<NSString *, XZKeychainAttribute *> *)attributes type:(XZKeychainType)type {
    self = [super init];
    if (self) {
        _type = type;
        _attributes = attributes;
    }
    return self;
}

#pragma mark - Public Methods

static const void * const _accessPassword = &_accessPassword;

+ (NSString *)accessPassword {
    return objc_getAssociatedObject(self, _accessPassword);
}

+ (void)setAccessPassword:(NSString *)accessPassword {
    objc_setAssociatedObject(self, _accessPassword, accessPassword, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (XZKeychain *)keychainWithType:(XZKeychainType)type {
    return [self keychainWithAttributes:nil type:type];
}

+ (XZKeychain *)keychainWithAttributes:(NSArray<XZKeychainAttribute *> *)attributes type:(XZKeychainType)type {
    return [(XZKeychain *)[XZKeychainSubclassForType(type) alloc] initWithAttributes:attributes type:type];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSGenericException reason:@"Please use subclass." userInfo:nil];
}

- (instancetype)initWithAttributes:(NSArray<XZKeychainAttribute *> *)attributes type:(XZKeychainType)type {
    self = [super init];
    if (self) {
        _attributes = [NSMutableDictionary dictionary];
        for (XZKeychainAttribute *attr in attributes) {
            _attributes[attr.name] = attr;
        }
    }
    return self;
}

@synthesize attributes = _attributes;
@synthesize type = _type;

#pragma mark - Key-Value methods

- (void)setValue:(id)value forAttribute:(NSString *)attribute {
    XZKeychainAttribute *attr = _attributes[attribute];
    if (attr == nil) {
        attr = [[XZKeychainAttribute alloc] initWithName:attribute originalValue:nil updatingValue:value];
        _attributes[attribute] = attr;
    } else {
        attr.value = value;
    }
}

- (id)valueForAttribute:(NSString *)attribute {
    return _attributes[attribute].value;
}

- (void)setObject:(id)anObject forAttribute:(NSString *)attribute {
    [self setValue:anObject forAttribute:attribute];
}

- (id)objectForAttribute:(NSString *)attribute {
    return [self valueForAttribute:attribute];
}

- (void)setObject:(id)anObject forKeyedSubscript:(nonnull NSString *)key {
    [self setValue:anObject forAttribute:key];
}

- (id)objectForKeyedSubscript:(NSString *)key {
    return [self valueForAttribute:key];
}



- (void)setValue:(nullable id)value forAttributeType:(XZKeychainAttributeType)attributeType {
    [self setValue:value forAttribute:NSStringFromXZKeychainAttributeType(attributeType)];
}

- (nullable id)valueForAttributeType:(XZKeychainAttributeType)attributeType {
    return [self valueForAttribute:NSStringFromXZKeychainAttributeType(attributeType)];
}

- (void)setObject:(nullable id)anObject forAttributeType:(XZKeychainAttributeType)attributeType {
    [self setValue:anObject forAttributeType:attributeType];
}

- (nullable id)objectForAttributeType:(XZKeychainAttributeType)attributeType {
    return [self valueForAttributeType:attributeType];
}

- (void)setObject:(nullable id)obj atIndexedSubscript:(XZKeychainAttributeType)attributeType {
    [self setValue:obj forAttributeType:attributeType];
}

- (nullable id)objectAtIndexedSubscript:(XZKeychainAttributeType)attributeType {
    return [self valueForAttributeType:attributeType];
}

- (void)XZ_updateAttributesWithDictionary:(NSDictionary<NSString *, id> *)attributeDictionary {
    // set new value
    [_attributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZKeychainAttribute * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.originalValue = attributeDictionary[key];
        obj.updatingValue = nil;
    }];
    [attributeDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        XZKeychainAttribute *tmp = _attributes[key];
        if (tmp == nil) {
            tmp = [[XZKeychainAttribute alloc] initWithName:key originalValue:obj];
            _attributes[key] = tmp;
        }
    }];
}

// 重置数据
- (void)reset {
    [_attributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZKeychainAttribute * _Nonnull obj, BOOL * _Nonnull stop) {
        obj.value = nil;
    }];
}

#pragma mark - 增

- (BOOL)insert:(NSError * _Nullable * _Nullable)error {
    if (_attributes.count == 0) {
        return XZKeychainHandleError(errSecParam, error);
    }
    
    BOOL isNewOne = YES, isModified = NO;
    NSArray<XZKeychainAttribute *> * const attributes = _attributes.allValues;
    XZKeychainAttributeChecker(attributes, &isNewOne, &isModified);
    
    if (!isNewOne) {
        return [self update:error];
    }
    
    if (!isModified) { // may never happen.
        return XZKeychainHandleError(errSecParam, error);
    }
    
    NSMutableDictionary *updatingAttributes = [NSMutableDictionary dictionary];
    for (XZKeychainAttribute *attr in attributes) {
        updatingAttributes[attr.name] = attr.value;
    }
    
    updatingAttributes[kXZKeychainTypeKey] = NSStringFromXZKeychainType(self.type);
    updatingAttributes[(id)(kSecReturnAttributes)] = (id)kCFBooleanTrue;  // 返回属性
    CFDictionaryRef resultRef = NULL;
    OSStatus statusCode = SecItemAdd((__bridge CFDictionaryRef)updatingAttributes, (CFTypeRef *)&resultRef);
    
    BOOL success = XZKeychainHandleError(statusCode, error);
    if (success) {
        [self XZ_updateAttributesWithDictionary:(__bridge NSDictionary<NSString *,id> *)(resultRef)];
    }
    
    if (resultRef != NULL) {
        CFRelease(resultRef);
    }
    
    return success;
}

#pragma mark - 删

- (BOOL)remove:(NSError * _Nullable * _Nullable)error {
    if (_attributes.count == 0) {
        return XZKeychainHandleError(errSecParam, error);
    }
    
    BOOL isNewOne = YES, isModified = NO;
    NSArray<XZKeychainAttribute *> * const attributes = _attributes.allValues;
    XZKeychainAttributeChecker(attributes, &isNewOne, &isModified);
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    if (isNewOne) {
        for (XZKeychainAttribute *attr in attributes) {
            query[attr.name] = attr.value;
        }
    } else {
        for (XZKeychainAttribute *attr in attributes) {
            query[attr.name] = attr.originalValue;
        }
    }
    
    query[kXZKeychainTypeKey] = NSStringFromXZKeychainType(self.type);
    OSStatus statusCode = SecItemDelete((__bridge CFDictionaryRef)query);
    if (XZKeychainHandleError(statusCode, error) || statusCode == errSecItemNotFound) {
        [_attributes removeAllObjects];
        return YES;
    }
    return NO;
}

#pragma mark - 改

- (BOOL)update:(NSError * _Nullable * _Nullable)error {
    if (_attributes.count == 0) {
        return XZKeychainHandleError(errSecParam, error);
    }
    
    BOOL isNewOne = YES, isModified = NO;
    NSArray<XZKeychainAttribute *> * const attributes = _attributes.allValues;
    XZKeychainAttributeChecker(attributes, &isNewOne, &isModified);
    
    if (isNewOne) {
        return [self insert:error];
    }
    
    if (!isModified) {
        return XZKeychainHandleError(noErr, error);
    }
    
    NSMutableDictionary<NSString *, id> *query = [NSMutableDictionary dictionary];
    NSMutableDictionary<NSString *, id> *attrs = [NSMutableDictionary dictionary];
    for (XZKeychainAttribute *attr in attributes) {
        query[attr.name] = attr.originalValue;
        attrs[attr.name] = attr.value;
    }
    
    query[kXZKeychainTypeKey] = NSStringFromXZKeychainType(self.type);
    OSStatus statusCode = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)attrs);
    
    if (XZKeychainHandleError(statusCode, error)) {
        NSError *error1 = nil;
        NSDictionary<NSString *, id> *object = XZKeychainAttributeMatcher(self.type, _attributes.allValues, &error1, YES);
        if (error1 == nil && error1.code == noErr) {
            [self XZ_updateAttributesWithDictionary:object];
            return YES;
        } else if (error != NULL) {
            *error = error1;
        }
        return NO; // may be success, but not sure.
    }
    
    return NO;
}

- (NSData *)secret:(NSError * _Nullable __autoreleasing *)error {
    if (_attributes.count == 0) {
        XZKeychainHandleError(errSecParam, error);
        return nil;
    }
    
    BOOL isNewOne = YES, isModified = NO;
    NSArray<XZKeychainAttribute *> * const attributes = _attributes.allValues;
    XZKeychainAttributeChecker(attributes, &isNewOne, &isModified);
    
    if (isNewOne) {
        XZKeychainHandleError(errSecParam, error);
        return nil;
    }
    
    NSMutableDictionary *query = [NSMutableDictionary dictionary];
    for (XZKeychainAttribute *attr in attributes) {
        query[attr.name] = attr.originalValue;
    }
    
    query[(id)kSecReturnData] = (id)kCFBooleanTrue;
    query[kXZKeychainTypeKey] = NSStringFromXZKeychainType(self.type);
    query[(id)kSecMatchLimit] = (id)kSecMatchLimitOne;
    
    id object = nil;
    CFTypeRef resultRef = NULL;
    OSStatus errorCode = SecItemCopyMatching((__bridge CFDictionaryRef)query, &resultRef);
    
    if (XZKeychainHandleError(errorCode, error)) {
        object = (__bridge id)(resultRef);
    }
    
    if (resultRef != NULL) {
        CFRelease(resultRef);
    }
    
    return object;
}

- (BOOL)setSecret:(NSData *)secret error:(NSError * _Nullable __autoreleasing *)error {
    XZKeychainAttribute *secretAttribute = _attributes[kXZKeychainSecretDataKey];
    if (secretAttribute == nil) {
        _attributes[kXZKeychainSecretDataKey] = [[XZKeychainAttribute alloc] initWithName:kXZKeychainSecretDataKey originalValue:secret];
    } else {
        secretAttribute.originalValue = secret;
    }
    return [self update:error];
}

@end


static id XZKeychainAttributeMatcher(XZKeychainType type, NSArray<XZKeychainAttribute *> *attributes, NSError **error, BOOL limitOne) {
    // 创建查询条件
    NSMutableDictionary *query = [[NSMutableDictionary alloc] init];
    
    // 1. class key-value
    query[(id)kSecClass] = NSStringFromXZKeychainType(type);
    
    // 2 .attribute key-value: query[(id)kSecAttrService] = nil;
    for (XZKeychainAttribute *attr in attributes) {
        query[attr.name] = attr.value;
    }
    
    // 3. search key-value
    query[(id)kSecMatchLimit]       = (id)(limitOne ? kSecMatchLimitOne : kSecMatchLimitAll);
    
    // 4. return-type key-value
    query[(id)kSecReturnAttributes] = (id)kCFBooleanTrue; // 非加密的属性
    // query[(id)kSecReturnData]       = (id)kCFBooleanTrue; // 加密的数据
    
    id result = nil;
    CFTypeRef resultRef = NULL;
    OSStatus errorCode = SecItemCopyMatching((__bridge CFDictionaryRef)query, &resultRef);
    
    if (XZKeychainHandleError(errorCode, error)) {
        result = (__bridge id)(resultRef);
    }
    
    if (resultRef != NULL) {
        CFRelease(resultRef);
    }
    
    return result;
}

static void XZKeychainAttributeChecker(NSArray<XZKeychainAttribute*> *attributes, BOOL *isNew, BOOL *isModified) {
    for (XZKeychainAttribute *attr in attributes) {
        if (*isNew) {
            *isNew = (attr.originalValue == nil);
        }
        if (!*isModified) {
            *isModified = ![attr.originalValue isEqual:attr.value];
        }
        if (*isModified && !*isNew) {
            break;
        }
    }
}

static NSString * _Nonnull NSStringFromOSStaus(OSStatus status);

static BOOL XZKeychainHandleError(OSStatus errorCode, NSError **error) {
    if (errorCode == noErr) {
        if (error != NULL) {
            *error = nil;
        }
        return YES;
    }
    if (error != NULL) {
        *error = [NSError errorWithDomain:NSOSStatusErrorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey: NSStringFromOSStaus(errorCode)}];
    }
    return NO;
}

static NSString * _Nonnull NSStringFromXZKeychainType(XZKeychainType type) {
    switch (type) {
        case XZKeychainTypeGenericPassword:
            return (NSString *)kSecClassGenericPassword;
            
        case XZKeychainTypeInternetPassword:
            return (NSString *)kSecClassInternetPassword;
            
        case XZKeychainTypeCertificate:
            return (NSString *)kSecClassCertificate;
            
        case XZKeychainTypeKey:
            return (NSString *)kSecClassKey;
            
        case XZKeychainTypeIdentity:
            return (NSString *)kSecClassIdentity;
            
        case XZKeychainTypeNotSupported:
            return @"XZKeychainTypeNotSupported";
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


static Class _Nullable XZKeychainSubclassForType(XZKeychainType type) {
    switch (type) {
        case XZKeychainTypeGenericPassword:
            return [XZGenericPasswordKeychain class];
            
        case XZKeychainTypeInternetPassword:
            return [XZInternetPasswordKeychain class];
            
        case XZKeychainTypeCertificate:
            return [XZCertificateKeychain class];
            
        case XZKeychainTypeKey:
            return [XZKeyKeychain class];
            
        case XZKeychainTypeIdentity:
            return [XZIdentityKeychain class];
            
        case XZKeychainTypeNotSupported:
            return Nil;
    }
}




@implementation XZKeychain (XZKeychainExtended)

- (id)accessible {
    return [self valueForAttributeType:(XZKeychainAttributeTypeAccessible)];
}

- (void)setAccessible:(id)accessible {
    [self setValue:accessible forAttributeType:(XZKeychainAttributeTypeAccessible)];
}

- (id)accessControl {
    return [self valueForAttributeType:(XZKeychainAttributeTypeAccessControl)];
}

- (void)setAccessControl:(id)accessControl {
    [self setValue:accessControl forAttributeType:(XZKeychainAttributeTypeAccessControl)];
}

- (id)accessGroup {
    return [self valueForAttributeType:(XZKeychainAttributeTypeAccessGroup)];
}

- (void)setAccessGroup:(id)accessGroup {
    [self setValue:accessGroup forAttributeType:(XZKeychainAttributeTypeAccessGroup)];
}

- (id)creationDate {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCreationDate)];
}

- (void)setCreationDate:(id)creationDate {
    [self setValue:creationDate forAttributeType:(XZKeychainAttributeTypeCreationDate)];
}

- (id)modificationDate {
    return [self valueForAttributeType:(XZKeychainAttributeTypeModificationDate)];
}

- (void)setModificationDate:(id)modificationDate {
    [self setValue:modificationDate forAttributeType:(XZKeychainAttributeTypeModificationDate)];
}

- (NSString *)description {
    return [self valueForAttributeType:(XZKeychainAttributeTypeDescription)];
}

- (void)setDescription:(NSString *)description {
    [self setValue:description forAttributeType:(XZKeychainAttributeTypeDescription)];
}

- (id)comment {
    return [self valueForAttributeType:(XZKeychainAttributeTypeComment)];
}

- (void)setComment:(id)comment {
    [self setValue:comment forAttributeType:(XZKeychainAttributeTypeComment)];
}

- (id)creator {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCreator)];
}

- (void)setCreator:(id)creator {
    [self setValue:creator forAttributeType:(XZKeychainAttributeTypeCreator)];
}

- (id)itemType {
    return [self valueForAttributeType:(XZKeychainAttributeTypeType)];
}

- (void)setItemType:(id)itemType {
    [self setValue:itemType forAttributeType:(XZKeychainAttributeTypeType)];
}

- (id)label {
    return [self valueForAttributeType:(XZKeychainAttributeTypeLabel)];
}

- (void)setLabel:(id)label {
    [self setValue:label forAttributeType:(XZKeychainAttributeTypeLabel)];
}

- (id)isInvisible {
    return [self valueForAttributeType:(XZKeychainAttributeTypeIsInvisible)];
}

- (void)setIsInvisible:(id)isInvisible {
    [self setValue:isInvisible forAttributeType:(XZKeychainAttributeTypeIsInvisible)];
}

- (id)isNegative {
    return [self valueForAttributeType:(XZKeychainAttributeTypeIsNegative)];
}

- (void)setIsNegative:(id)isNegative {
    [self setValue:isNegative forAttributeType:(XZKeychainAttributeTypeIsNegative)];
}

- (id)account {
    return [self valueForAttributeType:(XZKeychainAttributeTypeAccount)];
}

- (void)setAccount:(id)account {
    [self setValue:account forAttributeType:(XZKeychainAttributeTypeAccount)];
}

- (id)service {
    return [self valueForAttributeType:(XZKeychainAttributeTypeService)];
}

- (void)setService:(id)service {
    [self setValue:service forAttributeType:(XZKeychainAttributeTypeService)];
}

- (id)generic {
    return [self valueForAttributeType:(XZKeychainAttributeTypeGeneric)];
}

- (void)setGeneric:(id)generic {
    [self setValue:generic forAttributeType:(XZKeychainAttributeTypeGeneric)];
}

- (id)synchronizable {
    return [self valueForAttributeType:(XZKeychainAttributeTypeSynchronizable)];
}

- (void)setSynchronizable:(id)synchronizable {
    [self setValue:synchronizable forAttributeType:(XZKeychainAttributeTypeSynchronizable)];
}

- (id)securityDomain {
    return [self valueForAttributeType:(XZKeychainAttributeTypeSecurityDomain)];
}

- (void)setSecurityDomain:(id)securityDomain {
    [self setValue:securityDomain forAttributeType:(XZKeychainAttributeTypeSecurityDomain)];
}

- (id)server {
    return [self valueForAttributeType:(XZKeychainAttributeTypeServer)];
}

- (void)setServer:(id)server {
    [self setValue:server forAttributeType:(XZKeychainAttributeTypeServer)];
}

- (id)protocol {
    return [self valueForAttributeType:(XZKeychainAttributeTypeProtocol)];
}

- (void)setProtocol:(id)protocol {
    [self setValue:protocol forAttributeType:(XZKeychainAttributeTypeProtocol)];
}

- (id)authenticationType {
    return [self valueForAttributeType:(XZKeychainAttributeTypeAuthenticationType)];
}

- (void)setAuthenticationType:(id)authenticationType {
    [self setValue:authenticationType forAttributeType:(XZKeychainAttributeTypeAuthenticationType)];
}

- (id)port {
    return [self valueForAttributeType:(XZKeychainAttributeTypePort)];
}

- (void)setPort:(id)port {
    [self setValue:port forAttributeType:(XZKeychainAttributeTypePort)];
}

- (id)path {
    return [self valueForAttributeType:(XZKeychainAttributeTypePath)];
}

- (void)setPath:(id)path {
    [self setValue:path forAttributeType:(XZKeychainAttributeTypePath)];
}

- (id)certificateType {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCertificateType)];
}

- (void)setCertificateType:(id)certificateType {
    [self setValue:certificateType forAttributeType:(XZKeychainAttributeTypeCertificateType)];
}

- (id)certificateEncoding {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCertificateEncoding)];
}

- (void)setCertificateEncoding:(id)certificateEncoding {
    [self setValue:certificateEncoding forAttributeType:(XZKeychainAttributeTypeCertificateEncoding)];
}

- (id)subject {
    return [self valueForAttributeType:(XZKeychainAttributeTypeSubject)];
}

- (void)setSubject:(id)subject {
    [self setValue:subject forAttributeType:(XZKeychainAttributeTypeSubject)];
}

- (id)issuer {
    return [self valueForAttributeType:(XZKeychainAttributeTypeIssuer)];
}

- (void)setIssuer:(id)issuer {
    [self setValue:issuer forAttributeType:(XZKeychainAttributeTypeIssuer)];
}

- (id)serialNumber {
    return [self valueForAttributeType:(XZKeychainAttributeTypeSerialNumber)];
}

- (void)setSerialNumber:(id)serialNumber {
    [self setValue:serialNumber forAttributeType:(XZKeychainAttributeTypeSerialNumber)];
}

- (id)subjectKeyID {
    return [self valueForAttributeType:(XZKeychainAttributeTypeSubjectKeyID)];
}

- (void)setSubjectKeyID:(id)subjectKeyID {
    [self setValue:subjectKeyID forAttributeType:(XZKeychainAttributeTypeSubjectKeyID)];
}

- (id)publicKeyHash {
    return [self valueForAttributeType:(XZKeychainAttributeTypePublicKeyHash)];
}

- (void)setPublicKeyHash:(id)publicKeyHash {
    [self setValue:publicKeyHash forAttributeType:(XZKeychainAttributeTypePublicKeyHash)];
}

- (id)keyClass {
    return [self valueForAttributeType:(XZKeychainAttributeTypeKeyClass)];
}

- (void)setKeyClass:(id)keyClass {
    [self setValue:keyClass forAttributeType:(XZKeychainAttributeTypeKeyClass)];
}

- (id)applicationLabel {
    return [self valueForAttributeType:(XZKeychainAttributeTypeApplicationLabel)];
}

- (void)setApplicationLabel:(id)applicationLabel {
    [self setValue:applicationLabel forAttributeType:(XZKeychainAttributeTypeApplicationLabel)];
}

- (id)isPermanent {
    return [self valueForAttributeType:(XZKeychainAttributeTypeIsPermanent)];
}

- (void)setIsPermanent:(id)isPermanent {
    [self setValue:isPermanent forAttributeType:(XZKeychainAttributeTypeIsPermanent)];
}

- (id)applicationTag {
    return [self valueForAttributeType:(XZKeychainAttributeTypeApplicationTag)];
}

- (void)setApplicationTag:(id)applicationTag {
    [self setValue:applicationTag forAttributeType:(XZKeychainAttributeTypeApplicationTag)];
}

- (id)keyType {
    return [self valueForAttributeType:(XZKeychainAttributeTypeKeyType)];
}

- (void)setKeyType:(id)keyType {
    [self setValue:keyType forAttributeType:(XZKeychainAttributeTypeKeyType)];
}

- (id)keySizeInBits {
    return [self valueForAttributeType:(XZKeychainAttributeTypeKeySizeInBits)];
}

- (void)setKeySizeInBits:(id)keySizeInBits {
    [self setValue:keySizeInBits forAttributeType:(XZKeychainAttributeTypeKeySizeInBits)];
}

- (id)effectiveKeySize {
    return [self valueForAttributeType:(XZKeychainAttributeTypeEffectiveKeySize)];
}

- (void)setEffectiveKeySize:(id)effectiveKeySize {
    [self setValue:effectiveKeySize forAttributeType:(XZKeychainAttributeTypeEffectiveKeySize)];
}

- (id)canEncrypt {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCanEncrypt)];
}

- (void)setCanEncrypt:(id)canEncrypt {
    [self setValue:canEncrypt forAttributeType:(XZKeychainAttributeTypeCanEncrypt)];
}

- (id)canDecrypt {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCanDecrypt)];
}

- (void)setCanDecrypt:(id)canDecrypt {
    [self setValue:canDecrypt forAttributeType:(XZKeychainAttributeTypeCanDecrypt)];
}

- (id)canDerive {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCanDerive)];
}

- (void)setCanDerive:(id)canDerive {
    [self setValue:canDerive forAttributeType:(XZKeychainAttributeTypeCanDerive)];
}

- (id)canSign {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCanSign)];
}

- (void)setCanSign:(id)canSign {
    [self setValue:canSign forAttributeType:(XZKeychainAttributeTypeCanSign)];
}

- (id)canVerify {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCanVerify)];
}

- (void)setCanVerify:(id)canVerify {
    [self setValue:canVerify forAttributeType:(XZKeychainAttributeTypeCanVerify)];
}

- (id)canWrap {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCanWrap)];
}

- (void)setCanWrap:(id)canWrap {
    [self setValue:canWrap forAttributeType:(XZKeychainAttributeTypeCanWrap)];
}

- (id)canUnwrap {
    return [self valueForAttributeType:(XZKeychainAttributeTypeCanUnwrap)];
}

- (void)setCanUnwrap:(id)canUnwrap {
    [self setValue:canUnwrap forAttributeType:(XZKeychainAttributeTypeCanUnwrap)];
}

@end






#pragma mark - ===========
#pragma mark - Subclassses

@implementation XZGenericPasswordKeychain

@dynamic accessible;
@dynamic accessControl;
@dynamic accessGroup;
@dynamic creationDate;
@dynamic modificationDate;
@dynamic description;
@dynamic comment;
@dynamic creator;
@dynamic itemType; // type
@dynamic label;
@dynamic isInvisible;
@dynamic isNegative;
@dynamic account;
@dynamic service;
@dynamic generic;
@dynamic synchronizable;

- (instancetype)initWithAttributes:(NSArray<XZKeychainAttribute *> *)attributes {
    return [self initWithAttributes:attributes type:(XZKeychainTypeGenericPassword)];
}

- (NSString *)description {
    return [super description];
}

- (void)setDescription:(NSString *)description {
    [super setDescription:description];
}

- (NSString *)password {
    return [[NSString alloc] initWithData:[self secret:NULL] encoding:NSUTF8StringEncoding];
}

- (void)setPassword:(NSString *)password {
    NSData *data = [password dataUsingEncoding:(NSUTF8StringEncoding)];
    [self setSecret:data error:NULL];
}

@end

@implementation XZInternetPasswordKeychain

@dynamic accessible;
@dynamic accessControl;
@dynamic accessGroup;
@dynamic creationDate;
@dynamic modificationDate;
@dynamic description;
@dynamic comment;
@dynamic creator;
@dynamic itemType; // type
@dynamic label;
@dynamic isInvisible;
@dynamic isNegative;
@dynamic account;
@dynamic securityDomain;
@dynamic server;
@dynamic protocol;
@dynamic authenticationType;
@dynamic port;
@dynamic path;
@dynamic synchronizable;

- (instancetype)initWithAttributes:(NSArray<XZKeychainAttribute *> *)attributes {
    return [self initWithAttributes:attributes type:(XZKeychainTypeInternetPassword)];
}

- (NSString *)description {
    return [super description];
}

- (void)setDescription:(NSString *)description {
    [super setDescription:description];
}

@end

@implementation XZCertificateKeychain

@dynamic accessible;
@dynamic accessControl;
@dynamic accessGroup;
@dynamic certificateType;
@dynamic certificateEncoding;
@dynamic label;
@dynamic subject;
@dynamic issuer;
@dynamic serialNumber;
@dynamic subjectKeyID;
@dynamic publicKeyHash;
@dynamic synchronizable;

- (instancetype)initWithAttributes:(NSArray<XZKeychainAttribute *> *)attributes {
    return [self initWithAttributes:attributes type:(XZKeychainTypeCertificate)];
}

@end

@implementation XZKeyKeychain

@dynamic accessible;
@dynamic accessControl;
@dynamic accessGroup;
@dynamic keyClass;
@dynamic label;
@dynamic applicationLabel;
@dynamic isPermanent;
@dynamic applicationTag;
@dynamic keyType;
@dynamic keySizeInBits;
@dynamic effectiveKeySize;
@dynamic canEncrypt;
@dynamic canDecrypt;
@dynamic canDerive;
@dynamic canSign;
@dynamic canVerify;
@dynamic canWrap;
@dynamic canUnwrap;
@dynamic synchronizable;

- (instancetype)initWithAttributes:(NSArray<XZKeychainAttribute *> *)attributes {
    return [self initWithAttributes:attributes type:(XZKeychainTypeKey)];
}

@end

@implementation XZIdentityKeychain

@dynamic accessible;
@dynamic accessControl;
@dynamic accessGroup;
@dynamic certificateType;
@dynamic certificateEncoding;
@dynamic label;
@dynamic subject;
@dynamic issuer;
@dynamic serialNumber;
@dynamic subjectKeyID;
@dynamic publicKeyHash;
@dynamic synchronizable;

@dynamic keyClass;
@dynamic applicationLabel;
@dynamic isPermanent;
@dynamic applicationTag;
@dynamic keyType;
@dynamic keySizeInBits;
@dynamic effectiveKeySize;
@dynamic canEncrypt;
@dynamic canDecrypt;
@dynamic canDerive;
@dynamic canSign;
@dynamic canVerify;
@dynamic canWrap;
@dynamic canUnwrap;

- (instancetype)initWithAttributes:(NSArray<XZKeychainAttribute *> *)attributes {
    return [self initWithAttributes:attributes type:(XZKeychainTypeIdentity)];
}

@end
