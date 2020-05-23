//
//  NSString.m
//  XZKit
//
//  Created by Xezun on 2018/7/25.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import "NSString+XZKit.h"
#import "NSData+XZKit.h"

@implementation NSString (XZDataDigester)

- (NSString *)xz_md5 {
    return [[self dataUsingEncoding:(NSUTF8StringEncoding)] xz_md5];
}

- (NSString *)xz_MD5 {
    return [[self dataUsingEncoding:(NSUTF8StringEncoding)] xz_MD5];
}

- (NSString *)xz_sha1 {
    return [[self dataUsingEncoding:(NSUTF8StringEncoding)] xz_sha1];
}

- (NSString *)xz_SHA1 {
    return [[self dataUsingEncoding:(NSUTF8StringEncoding)] xz_SHA1];
}

@end


