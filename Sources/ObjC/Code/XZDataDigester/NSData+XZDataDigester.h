//
//  NSData+XZDataDigester.h
//  XZKit
//
//  Created by Xezun on 2021/2/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (XZDataDigester)

/// 二进制数据的小写 MD5 值。
@property (nonatomic, readonly) NSString *xz_md5 NS_SWIFT_NAME(md5);

/// 二进制数据的大写 MD5 值。
@property (nonatomic, readonly) NSString *xz_MD5 NS_SWIFT_NAME(MD5);

/// 二进制数据的小写 SHA1 值。
@property (nonatomic, readonly) NSString *xz_sha1 NS_SWIFT_NAME(sha1);

/// 二进制数据的大写 SHA1 值。
@property (nonatomic, readonly) NSString *xz_SHA1 NS_SWIFT_NAME(SHA1);

/// 二进制数据的小写 SHA256 值。
@property (nonatomic, readonly) NSString *xz_sha256 NS_SWIFT_NAME(sha256);

/// 二进制数据的大写 SHA256 值。
@property (nonatomic, readonly) NSString *xz_SHA256 NS_SWIFT_NAME(SHA256);

/// 二进制数据的小写 SHA512 值。
@property (nonatomic, readonly) NSString *xz_sha512 NS_SWIFT_NAME(sha512);

/// 二进制数据的大写 SHA512 值。
@property (nonatomic, readonly) NSString *xz_SHA512 NS_SWIFT_NAME(SHA512);

@end

NS_ASSUME_NONNULL_END
