//
//  NSData+XZDataDigester.h
//  XZKit
//
//  Created by Xezun on 2021/2/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (XZDataDigester)

/// 字符串的小写 MD5 值，字符串必须能转换为 utf8 格式，否则返回空字符串。
@property (nonatomic, readonly) NSString *xz_md5 NS_SWIFT_NAME(md5);

/// 字符串的大写 MD5 值，字符串必须能转换为 utf8 格式，否则返回空字符串。
@property (nonatomic, readonly) NSString *xz_MD5 NS_SWIFT_NAME(MD5);

/// 字符串的小写 SHA1 值，字符串必须能转换为 utf8 格式，否则返回空字符串。
@property (nonatomic, readonly) NSString *xz_sha1 NS_SWIFT_NAME(sha1);

/// 字符串的大写 SHA1 值，字符串必须能转换为 utf8 格式，否则返回空字符串。
@property (nonatomic, readonly) NSString *xz_SHA1 NS_SWIFT_NAME(SHA1);

@end

NS_ASSUME_NONNULL_END
