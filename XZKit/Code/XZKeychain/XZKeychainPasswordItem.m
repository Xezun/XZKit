//
//  XZKeychainPasswordItem.m
//  KeyChain
//
//  Created by Xezun on 2025/1/13.
//  Copyright © 2025 Xezun Individual. All rights reserved.
//

#import "XZKeychainPasswordItem.h"
@import Security;

@implementation XZKeychainPasswordItem

- (NSString *)password {
    NSData *data = self.data;
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)setPassword:(NSString *)password {
    self.data = [password dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSDate *)creationDate {
    return _attributes[(id)kSecAttrCreationDate];
}

- (void)setCreationDate:(NSDate *)creationDate {
    _attributes[(id)kSecAttrCreationDate] = creationDate;
}

- (NSDate *)modificationDate {
    return _attributes[(id)kSecAttrModificationDate];
}

- (void)setModificationDate:(NSDate *)modificationDate {
    _attributes[(id)kSecAttrModificationDate] = modificationDate;
}

- (NSString *)description {
    return _attributes[(id)kSecAttrDescription];
}

- (void)setDescription:(NSString *)description {
    _attributes[(id)kSecAttrDescription] = description;
}

- (NSString *)comment {
    return _attributes[(id)kSecAttrComment];
}

- (void)setComment:(NSString *)comment {
    _attributes[(id)kSecAttrComment] = comment;
}

- (UInt32)creator {
    return [_attributes[(id)kSecAttrCreator] unsignedIntValue];
}

- (void)setCreator:(UInt32)creator {
    _attributes[(id)kSecAttrCreator] = @(creator);
}

- (UInt32)type {
    return [_attributes[(id)kSecAttrType] unsignedIntValue];
}

- (void)setType:(UInt32)type {
    _attributes[(id)kSecAttrType] = @(type);
}

- (BOOL)isInvisible {
    return _attributes[(id)kSecAttrIsInvisible];
}

- (void)setInvisible:(BOOL)isInvisible {
    _attributes[(id)kSecAttrIsInvisible] = @(isInvisible);
}

- (BOOL)isNegative {
    return _attributes[(id)kSecAttrIsNegative];
}

- (void)setNegative:(BOOL)isNegative {
    _attributes[(id)kSecAttrIsNegative] = @(isNegative);
}

- (NSString *)account {
    return _attributes[(id)kSecAttrAccount];
}

- (void)setAccount:(NSString *)account {
    _attributes[(id)kSecAttrAccount] = account;
}


@end

@implementation XZKeychainGenericPasswordItem

- (instancetype)init {
    return [super init];
}

- (NSString *)securityClass {
    return (NSString *)kSecClassGenericPassword;
}

- (NSString *)service {
    return _attributes[(id)kSecAttrService];
}

- (void)setService:(NSString *)service {
    _attributes[(id)kSecAttrService] = service;
}

- (NSData *)userInfo {
    return _attributes[(id)kSecAttrGeneric];
}

- (void)setUserInfo:(NSData *)userInfo {
    _attributes[(id)kSecAttrGeneric] = userInfo;
}

@end

@implementation XZKeychainInternetPasswordItem

- (instancetype)init {
    return [super init];
}

- (NSString *)securityClass {
    return (NSString *)kSecClassInternetPassword;
}

- (NSString *)securityDomain {
    return _attributes[(id)kSecAttrSecurityDomain];
}

- (void)setSecurityDomain:(NSString *)securityDomain {
    _attributes[(id)kSecAttrSecurityDomain] = securityDomain;
}

- (NSString *)server {
    return _attributes[(id)kSecAttrServer];
}

- (void)setServer:(NSString *)server {
    _attributes[(id)kSecAttrServer] = server;
}

- (NSString *)protocol {
    return _attributes[(id)kSecAttrProtocol];
}

- (void)setProtocol:(NSString *)protocol {
    _attributes[(id)kSecAttrProtocol] = protocol;
}

- (NSString *)authenticationType {
    return _attributes[(id)kSecAttrAuthenticationType];
}

- (void)setAuthenticationType:(NSString *)authenticationType {
    _attributes[(id)kSecAttrAuthenticationType] = authenticationType;
}

- (NSUInteger)port {
    return [_attributes[(id)kSecAttrPort] unsignedIntegerValue];
}

- (void)setPort:(NSUInteger)port {
    _attributes[(id)kSecAttrPort] = @(port);
}

- (NSString *)path {
    return _attributes[(id)kSecAttrPath];
}

- (void)setPath:(NSString *)path {
    _attributes[(id)kSecAttrPath] = path;
}

@end
