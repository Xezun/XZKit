//
//  NSString.h
//  XZKit
//
//  Created by Xezun on 2018/7/25.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (XZDataDigester)

/// 字符串的小写 MD5 值，字符串必须能转换为 utf8 格式，否则返回空字 符串。
@property (nonatomic, readonly, nonnull) NSString *xz_md5 NS_SWIFT_NAME(md5);
/// 字符串的大写 MD5 值，字符串必须能转换为 utf8 格式，否则返回空字符串。
@property (nonatomic, readonly, nonnull) NSString *xz_MD5 NS_SWIFT_NAME(MD5);
/// 字符串的小写 SHA1 值，字符串必须能转换为 utf8 格式，否则返回空字符串。
@property (nonatomic, readonly, nonnull) NSString *xz_sha1 NS_SWIFT_NAME(sha1);
/// 字符串的大写 SHA1 值，字符串必须能转换为 utf8 格式，否则返回空字符串。
@property (nonatomic, readonly, nonnull) NSString *xz_SHA1 NS_SWIFT_NAME(SHA1);

@end

