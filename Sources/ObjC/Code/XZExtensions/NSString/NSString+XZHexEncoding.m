//
//  NSString+XZHexEncoding.m
//  XZKit
//
//  Created by 徐臻 on 2025/7/16.
//

#import "NSString+XZHexEncoding.h"

@implementation NSString (XZHexEncoding)

- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding usingEncoding:(NSStringEncoding)stringEncoding {
    NSData * const data = [self dataUsingEncoding:stringEncoding];
    return [data xz_hexEncodedString:hexEncoding];
}

- (NSString *)xz_stringByAddingHexEncodingUsingEncoding:(NSStringEncoding)stringEncoding {
    return [self xz_stringByAddingHexEncoding:(XZLowercaseHexEncoding) usingEncoding:stringEncoding];
}

- (NSString *)xz_stringByAddingHexEncoding:(XZHexEncoding)hexEncoding {
    return [self xz_stringByAddingHexEncoding:hexEncoding usingEncoding:NSUTF8StringEncoding];
}

- (NSString *)xz_stringByAddingHexEncoding {
    return [self xz_stringByAddingHexEncoding:(XZLowercaseHexEncoding)];
}

- (NSString *)xz_stringByRemovingHexEncodingUsingEncoding:(NSStringEncoding)dataEncoding {
    NSData *data = [NSData xz_dataWithHexEncodedString:self];
    return [[NSString alloc] initWithData:data encoding:dataEncoding];
}

- (NSString *)xz_stringByRemovingHexEncoding {
    return [self xz_stringByRemovingHexEncodingUsingEncoding:NSUTF8StringEncoding];
}

@end
