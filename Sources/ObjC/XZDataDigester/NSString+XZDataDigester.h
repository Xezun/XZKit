//
//  NSString+XZDataDigester.h
//  XZKit
//
//  Created by Xezun on 2018/7/25.
//  Copyright © 2018年 Xezun Individual. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (XZDataDigester)

/// 字符串的小写 MD5 值，字符串必须能转换为 utf8 格式，否则返回 nil 值。
@property (nonatomic, readonly, nullable) NSString *xz_md5 NS_SWIFT_NAME(md5);

/// 字符串的大写 MD5 值，字符串必须能转换为 utf8 格式，否则返回 nil 值。
@property (nonatomic, readonly, nullable) NSString *xz_MD5 NS_SWIFT_NAME(MD5);

/// 字符串的小写 SHA1 值，字符串必须能转换为 utf8 格式，否则返回 nil 值。
@property (nonatomic, readonly, nullable) NSString *xz_sha1 NS_SWIFT_NAME(sha1);

/// 字符串的大写 SHA1 值，字符串必须能转换为 utf8 格式，否则返回 nil 值。
@property (nonatomic, readonly, nullable) NSString *xz_SHA1 NS_SWIFT_NAME(SHA1);

/// 字符串的小写 SHA256 值，字符串必须能转换为 utf8 格式，否则返回 nil 值。
@property (nonatomic, readonly, nullable) NSString *xz_sha256 NS_SWIFT_NAME(sha256);

/// 字符串的大写 SHA256 值，字符串必须能转换为 utf8 格式，否则返回 nil 值。
@property (nonatomic, readonly, nullable) NSString *xz_SHA256 NS_SWIFT_NAME(SHA256);

/// 字符串的小写 SHA512 值，字符串必须能转换为 utf8 格式，否则返回 nil 值。
@property (nonatomic, readonly, nullable) NSString *xz_sha512 NS_SWIFT_NAME(sha512);

/// 字符串的大写 SHA512 值，字符串必须能转换为 utf8 格式，否则返回 nil 值。
@property (nonatomic, readonly, nullable) NSString *xz_SHA512 NS_SWIFT_NAME(SHA512);

@end

NS_ASSUME_NONNULL_END

