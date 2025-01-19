//
//  XZKeychain.h
//  Keychain
//
//  Created by iMac on 16/6/24.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XZKeychainItem.h"
#import "XZKeychainKeyItem.h"
#import "XZKeychainPasswordItem.h"

NS_ASSUME_NONNULL_BEGIN

@class NSArray;

/// XZKeychain 类封装了系统“钥匙串”API的“增删改查”的操作，XZKeychain 所保存的信息只是钥匙串属性信息的一个拷贝，对钥匙串的属性的操作，在调用相应的方法前，并不影响“钥匙串”实际的信息。
@interface XZKeychain<__covariant Item: __kindof XZKeychainItem *> : NSObject

@property (nonatomic, readonly) Item item;

+ (XZKeychain<Item> *)keychainForItem:(Item)item NS_SWIFT_NAME(init(for:));
- (instancetype)init NS_UNAVAILABLE;

/// 读取钥匙串，并钥匙串信息同步到 item 的属性中。
/// @param data 是否同时读取二进制数据
/// @param error 错误输出
- (BOOL)search:(BOOL)data error:(NSError * _Nullable * _Nullable)error;

/// 更新钥匙串。若钥匙串中，有多条与 item 相匹配的条目，那么只会更新第一条，更新后 item 将指向被更新的对象。
/// @param error 如果发生错误，可用此参数输出。
/// @return YES 更新成功；NO 更新失败。
- (BOOL)update:(NSError * _Nullable * _Nullable)error;

/// 根据当前的属性，匹配删除第一个符合条件的钥匙串。如果钥匙串本身不存在，则也返回删除成功。
/// @param error 如果发生错误，可用此参数输出。
/// @return YES 删除成功；NO 删除失败。
- (BOOL)delete:(NSError * _Nullable * _Nullable)error;

/// 根据当前已设置的属性，创建一个钥匙串。如果创建钥匙串成功，对象会与该钥匙串创建关联。
///
/// @note 不同的钥匙串，可能具有不通的关键属性，比如 internet password 不允许插入属性 account 已存在的钥匙串。
/// @param error 如果发生错误，可用此参数输出。
/// @return YES 表示成功创建；NO 创建失败。
- (BOOL)insert:(NSError * _Nullable * _Nullable)error;

@end

@interface XZKeychain (XZExtendedKeychain)

/// 保存密码的通用钥匙串创建方法。
/// - Parameters:
///   - account: 用户名
///   - password: 密码
///   - server: 密码来源或用途
///   - accessGroup: 共享组
+ (XZKeychain<XZKeychainInternetPasswordItem *> *)keychainWithAccount:(nullable NSString *)account password:(nullable NSString *)password server:(nullable NSString *)server accessGroup:(nullable NSString *)accessGroup NS_SWIFT_NAME(keychain(account:password:server:accessGroup:));
/// 保存密码的通用钥匙串创建方法。
/// - Parameters:
///   - account: 用户名
///   - password: 密码
///   - server: 密码来源或用途
+ (XZKeychain<XZKeychainInternetPasswordItem *> *)keychainWithAccount:(nullable NSString *)account password:(nullable NSString *)password server:(nullable NSString *)server NS_SWIFT_NAME(keychain(account:password:server:));

/// 以 kXZGenericPasswordKeychainDeviceIdentifier 作为唯一标识符，以 UUID 作为设备 ID 的钥匙串。
/// 因为存储在钥匙串里的内容，不会因为删除 App 而清空，故可以用已储存的 UUID 作设备的唯一标识。
@property (class, nonatomic, readonly, nullable) NSString *UDID;
+ (nullable NSString *)UDIDForGroup:(nullable NSString *)accessGroup NS_SWIFT_NAME(UDID(for:));

@end

NS_ASSUME_NONNULL_END





