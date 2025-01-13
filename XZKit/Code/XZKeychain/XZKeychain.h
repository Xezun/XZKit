//
//  XZKeychain.h
//  Keychain
//
//  Created by iMac on 16/6/24.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>
@import Security;

NS_ASSUME_NONNULL_BEGIN

enum {
    XZKeychainErrorSuccess = noErr
};

/**
 *  XZKeychain 的类型，以下类型与实际包含的类型是相对应的。
 */
typedef NS_ENUM(NSUInteger, XZKeychainType) {
    XZKeychainTypeGenericPassword = 0,  // 通用密码
    XZKeychainTypeInternetPassword,     // 网络密码
    XZKeychainTypeCertificate,          // 证书
    XZKeychainTypeKey,                  // 密钥
    XZKeychainTypeIdentity,             // 验证
    XZKeychainTypeNotSupported          // 不支持的属性，请勿使用，主要是提供给 for 循环用的。
};

// 钥匙串所拥有的属性
typedef NS_ENUM(NSUInteger, XZKeychainAttribute) {
    // 钥匙串 XZKeychainGenericPassword 支持的属性：
    XZKeychainAttributeAccessible,
    XZKeychainAttributeAccessControl,
    // 模拟器（TARGET_IPHONE_SIMULATOR）没有代码签名，不存在分组。
    // 如果设置分组，添加或更新就会返回 -25243 (errSecNoAccessForItem) 错误。
    XZKeychainAttributeAccessGroup,
    XZKeychainAttributeCreationDate,
    XZKeychainAttributeModificationDate,
    XZKeychainAttributeDescription,
    XZKeychainAttributeComment,
    XZKeychainAttributeCreator,
    XZKeychainAttributeType,
    XZKeychainAttributeLabel,
    XZKeychainAttributeIsInvisible,
    XZKeychainAttributeIsNegative,
    XZKeychainAttributeAccount,  // 帐号
    XZKeychainAttributeService,
    XZKeychainAttributeGeneric,  // 通用属性，XZKeychain 建议把它作为管理 XZKeychainTypeGenericPassword 类型钥匙串的唯一标识符。
    XZKeychainAttributeSynchronizable,
    
    /* 钥匙串 XZKeychainInternetPassword 支持的属性：
     // 注释掉的属性不表示没有，而是已经在列表中了，下同
     XZKeychainAttributeAccessible,
     XZKeychainAttributeAccessControl,
     XZKeychainAttributeAccessGroup,
     XZKeychainAttributeCreationDate,
     XZKeychainAttributeModificationDate,
     XZKeychainAttributeDescription,
     XZKeychainAttributeComment,
     XZKeychainAttributeCreator,
     XZKeychainAttributeType,
     XZKeychainAttributeLabel,
     XZKeychainAttributeIsInvisible,
     XZKeychainAttributeIsNegative,
     XZKeychainAttributeAccount, */
    XZKeychainAttributeSecurityDomain,
    XZKeychainAttributeServer,
    XZKeychainAttributeProtocol,
    XZKeychainAttributeAuthenticationType,
    XZKeychainAttributePort,
    XZKeychainAttributePath,
    // XZKeychainAttributeSynchronizable
    
    // 钥匙串 XZKeychainCertificate 支持的属性：
    // XZKeychainAttributeAccessible,
    // XZKeychainAttributeAccessControl,
    // XZKeychainAttributeAccessGroup,
    XZKeychainAttributeCertificateType,
    XZKeychainAttributeCertificateEncoding,
    // XZKeychainAttributeLabel,
    XZKeychainAttributeSubject,
    XZKeychainAttributeIssuer,
    XZKeychainAttributeSerialNumber,
    XZKeychainAttributeSubjectKeyID,
    XZKeychainAttributePublicKeyHash,
    // XZKeychainAttributeSynchronizable
    
    // 钥匙串 XZKeychainKey 支持的属性：
    // XZKeychainAttributeAccessible,
    // XZKeychainAttributeAccessControl,
    // XZKeychainAttributeAccessGroup,
    XZKeychainAttributeKeyClass,
    // XZKeychainAttributeLabel,
    XZKeychainAttributeApplicationLabel,
    XZKeychainAttributeIsPermanent,
    XZKeychainAttributeApplicationTag,
    XZKeychainAttributeKeyType,
    XZKeychainAttributeKeySizeInBits,
    XZKeychainAttributeEffectiveKeySize,
    XZKeychainAttributeCanEncrypt,
    XZKeychainAttributeCanDecrypt,
    XZKeychainAttributeCanDerive,
    XZKeychainAttributeCanSign,
    XZKeychainAttributeCanVerify,
    XZKeychainAttributeCanWrap,
    XZKeychainAttributeCanUnwrap
    // XZKeychainAttributeSynchronizable
    
    // 钥匙串 XZKeychainIdentity 支持的属性:
    // 由于 XZKeychainIdentity 钥匙串同时包含“私钥”和“证书”，
    // 所以它同时具有 XZKeychainKey 和 XZKeychainCertificate 两种钥匙串的属性。
};

@class XZKeychainItem;

/// XZKeychain 类封装了系统“钥匙串”API的“增删改查”的操作，XZKeychain 所保存的信息只是钥匙串属性信息的一个拷贝，对钥匙串的属性的操作，在调用相应的方法前，并不影响“钥匙串”实际的信息。
@interface XZKeychain<Item: XZKeychainItem *> : NSObject <NSCopying>

@property (nonatomic, readonly) Item query;

+ (XZKeychain<Item> *)keychainForItem:(Item)item NS_SWIFT_NAME(init(for:));

/// 所有符合条件的钥匙串条目。
@property (nonatomic, readonly) NSArray<Item> *items;

/**
 *  更新钥匙串。信息，在更新前，对象必须已经关联了具体的钥匙，否则更新操作将不会执行（返回NO）。
 *
 *  @param error 如果发生错误，可用此参数输出。
 *
 *  @return YES 更新成功；NO 更新失败。
 */
- (BOOL)update:(NSError * _Nullable * _Nullable)error;

/**
 *  根据当前的属性，匹配删除第一个符合条件的钥匙串。如果钥匙串本身不存在，则也返回删除成功。
 *
 *  @param error 如果发生错误，可用此参数输出。
 *
 *  @return YES 删除成功；NO 删除失败。
 */
- (BOOL)remove:(NSError * _Nullable * _Nullable)error;

/**
 *  根据当前已设置的属性，创建一个钥匙串。如果创建钥匙串成功，对象会与该钥匙串创建关联。如果是一个已经调用 -search: 方法并返回成功的对象，调用本方法将会返回错误。
 *
 *  @param error 如果发生错误，可用此参数输出。
 *
 *  @return YES 表示成功创建；NO 创建失败。
 */
- (BOOL)insert:(NSError * _Nullable * _Nullable)error;


/**
 *  放弃所有已设置的属性，恢复到默认值或nil。
 */
- (void)reset;







/**
 *  标识钥匙串的类型。
 */
@property (nonatomic, readonly) XZKeychainType type;

/**
 *  钥匙串所有属性的集合。
 */
@property (nonatomic, copy, readonly) NSDictionary * _Nullable attributes;

/**
 *  初始化创建一个 XZKeychain 对象：
 *  因为 XZKeychain 只是钥匙串信息的一个拷贝，所以通过初始化方法创建的 XZKeychain 对象，并不具备操作某一具体的钥匙串的能力；
 *  一般情况下，您需要设置它的属性（可以匹配到一个具体的钥匙串的一个或多个属性），然后调用 -search: 方法，对象就会匹配指定的钥匙串并建立关联。
 *
 *  @param type 指定钥匙串的类型。
 *
 *  @return 指定类型的 XZKeychain 对象。
 */
+ (nullable instancetype)keychainWithType:(XZKeychainType)type;
- (nullable instancetype)initWithType:(XZKeychainType)type NS_DESIGNATED_INITIALIZER;

/**
 *  获取和设置“钥匙串”属性的方法。属性大多是 NSData 或 NSString 类型。
 *
 *  setter1: [keychain setValue:@"anAccount" forAttribute:XZKeychainAttributeAccount]; 
 *  setter2: keychain[XZKeychainAttributeAccount] = @"anAccount";
 *  getter1: id aValue = [keychain valueForAttribute:XZKeychainAttributeAccount];
 *  getter2: id aValue = keychain[XZKeychainAttributeAccount];
 *
 */
- (void)setValue:(nullable id)value forAttribute:(XZKeychainAttribute)attribute;
- (void)setObject:(nullable id)anObject forAttribute:(XZKeychainAttribute)attribute;
- (nullable id)valueForAttribute:(XZKeychainAttribute)attribute;
- (nullable id)objectForAttribute:(XZKeychainAttribute)attribute;
- (void)setObject:(nullable id)obj atIndexedSubscript:(XZKeychainAttribute)attribute;
- (nullable id)objectAtIndexedSubscript:(XZKeychainAttribute)attribute;

/**
 *  XZKeychain 对象根据它当前已设置的属性，匹配并复制第一个符合条件的钥匙串的信息；
 *  XZKeychain 将查询到的信息全部拷贝下来，通过存取方法可以获取这些值的信息；
 *  这个方法可以调用多次，每次都是根据当前设置的属性信息匹配并查找（第一条），所以当属性发生改变时，调用这个方法后可能获取到的信息并不完全一样。
 *
 *  @param error 如果查询钥匙串发生错误，将通过此参数传回。
 *
 *  @return YES 表示匹配到钥匙串，NO 表示没有匹配到钥匙串。
 */
- (BOOL)search:(NSError * _Nullable * _Nullable)error;

/**
 *  放弃所有已设置的属性，恢复到默认值或nil。
 */
- (void)reset;

/**
 *  根据当前已设置的属性，创建一个钥匙串。如果创建钥匙串成功，对象会与该钥匙串创建关联。如果是一个已经调用 -search: 方法并返回成功的对象，调用本方法将会返回错误。
 *
 *  @param error 如果发生错误，可用此参数输出。
 *
 *  @return YES 表示成功创建；NO 创建失败。
 */
- (BOOL)insert:(NSError * _Nullable * _Nullable)error;

/**
 *  根据当前的属性，匹配删除第一个符合条件的钥匙串。如果钥匙串本身不存在，则也返回删除成功。
 *
 *  @param error 如果发生错误，可用此参数输出。
 *
 *  @return YES 删除成功；NO 删除失败。
 */
- (BOOL)remove:(NSError * _Nullable * _Nullable)error;

/**
 *  更新钥匙串信息，在更新前，对象必须已经关联了具体的钥匙，否则更新操作将不会执行（返回NO）。
 *
 *  @param error 如果发生错误，可用此参数输出。
 *
 *  @return YES 更新成功；NO 更新失败。
 */
- (BOOL)update:(NSError * _Nullable * _Nullable)error; //

/**
 *  根据当前的属性，匹配返回所有符合条件的钥匙串。
 *
 *  @param error 如果发生错误，可用此参数输出。
 *
 *  @return 包含所有匹配结果的集合。
 */
- (NSArray<XZKeychain *> * _Nullable)match:(NSError * _Nullable * _Nullable)error; //

/**
 *  获取所有钥匙串。
 *
 *  @return 包含所有有钥匙串信息的 XZKeychain 对象集合。
 */
+ (NSArray<XZKeychain *> * _Nullable)allKeychains; // 所有钥匙串

/**
 *  获取某一类型下的所有钥匙串。
 *
 *  @param type 钥匙串的类型，枚举值。
 *
 *  @return 包含指定类型钥匙串信息的 XZKeychain 对象集合。
 */
+ (NSArray<XZKeychain *> * _Nullable)allKeychainsWithType:(XZKeychainType)type;

/**
 *  通过 XZKeychain 对象，指定钥匙串的基本信息，调用此方法获取信息相匹配的钥匙串。
 *
 *  @param matches 包含指定匹配信息的 XZKeychain 对象。
 *  @param errors  对于每一个待匹配的 XZKeychain 对象，获取匹配的钥匙串时，都可能发生错误，该字典以待匹配 XZKeychain 对象为键，返回匹配过程中包含的错误信息。
 *
 *  @return 所有符合匹配条件的包含钥匙串信息的 XZKeychain 对象集合。该返回结果只包含匹配没有发生错误的筛选条件。
 */
+ (NSArray<XZKeychain *> * _Nullable)match:(NSArray<XZKeychain *> * _Nullable)matches errors:(NSDictionary<XZKeychain *, NSError *> * _Nullable * _Nullable)errors;

// 不可复制，返回对象自身。主要是为了用作字典键值而提供的。
- (nonnull id)copyWithZone:(NSZone * _Nullable)zone;

@end


FOUNDATION_EXTERN NSString * const _Nonnull kXZGenericPasswordKeychainDeviceIdentifier;

/**
 *  通用密码钥匙串：XZKeychain.type = XZKeychainGenericPassword。
 *  关于 AccessGroup 钥匙串共享的两种设置方法：
 *  1, 首先，需要在项目中创建一个如下结构的 plist 文件，将文件名作为 group 参数传入；
 *     然后，在 Target -> Build settings -> Code Sign Entitlements 设置签名授权为该 plist 文件。
 *     ┌────────────────────────────────────────────────────────────────────────────────────┐
 *     │<dict>                                                                              │
 *     │    <key>keychain-access-groups</key>                                               │
 *     │    <array>                                                                         │
 *     │        <string>YOUR_APP_ID_HERE.com.yourcompany.keychain</string>                  │
 *     │        <string>YOUR_APP_ID_HERE.com.yourcompany.keychainSuite</string>             │
 *     │    </array>                                                                        │
 *     │</dict>                                                                             │
 *     └──────────────────────────────────────────────────────────────────────────────────────┘
 *  2, 在 Target -> Capabilities -> Keychain Sharing 中设置。
 */
@interface XZKeychain (XZGenericPasswordKeychain)

/**
 *  建议用 XZKeychainAttributeGeneric 属性作为 XZGenericPasswordKeychain 的唯一标识。
 */
@property (nonatomic, strong) NSString * _Nullable identifier;  // XZKeychainAttributeGeneric

/**
 *  返回的是 XZKeychainAttributeAccount 属性的值。
 */
@property (nonatomic, strong) NSString * _Nullable account;     // XZKeychainAttributeAccount

/**
 *  密码并非钥匙串的属性，在第一次调用该方法时，从钥匙串中获取。
 */
@property (nonatomic, strong) NSString * _Nullable password;

@property (nonatomic, strong) NSString * _Nullable accessGroup;

/**
 *  构造一个 XZGenericPasswordKeychain。
 *
 *  @param identifier XZKeychainAttributeGeneric 属性被用作唯一标识符。
 *
 *  @return XZKeychain 对象，type = XZKeychainTypeGenericPassword。
 */
+ (nullable instancetype)keychainWithIdentifier:(NSString * _Nullable)identifier;
+ (nullable instancetype)keychainWithAccessGroup:(NSString * _Nullable)accessGroup identifier:(NSString * _Nullable)identifier;

/**
 *  保存密码的便利方法。
 *
 *  @param password    密码
 *  @param account     帐号
 *  @param accessGroup 分组
 *  @param identifier  唯一标识
 *
 *  @return YES 保存成功，NO 保存失败
 */
+ (BOOL)setPassword:(NSString * _Nullable)password forAccount:(NSString * _Nullable)account accessGroup:(NSString * _Nullable)accessGroup identifier:(NSString * _Nullable)identifier;
+ (BOOL)setPassword:(NSString * _Nullable)password forAccount:(NSString * _Nullable)account identifier:(NSString * _Nullable)identifier;

/**
 *  获取密码的便利方法。
 *
 *  @param account     帐号
 *  @param accessGroup 分组
 *  @param identifier  唯一标识
 *
 *  @return 已保存的密码。如果没有找到则返回 nil 。
 */
+ (NSString * _Nullable)passwordForAccount:(NSString * _Nullable)account accessGroup:(NSString * _Nullable)accessGroup identifier:(NSString * _Nullable)identifier;
+ (NSString * _Nullable)passwordForAccount:(NSString * _Nullable)account identifier:(NSString * _Nullable)identifier;



/**
 *  以 kXZGenericPasswordKeychainDeviceIdentifier 作为唯一标识符，以 UUID 作为设备 ID 的钥匙串。
 *  因为存储在钥匙串里的内容，不会因为删除 App 而清空，故可以用已储存的 UUID 作设备的唯一标识。
 */
+ (NSString * _Nullable)deviceIdentifier;
+ (NSString * _Nullable)deviceIdentifierForAccessGroup:(NSString * _Nullable)accessGroup;

@end

NS_ASSUME_NONNULL_END





