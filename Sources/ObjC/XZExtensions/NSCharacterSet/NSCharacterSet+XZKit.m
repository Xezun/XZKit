//
//  NSCharacterSet+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/11/18.
//

#import "NSCharacterSet+XZKit.h"

@implementation NSCharacterSet (XZKit)

+ (NSCharacterSet *)xz_URIAllowedCharacterSet {
    static NSCharacterSet *_URIAllowedCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * const str = @""
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "0123456789"
        ";,/?:@&=+$-_.!~*'()#";
        _URIAllowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:str];
    });
    return _URIAllowedCharacterSet;
}

+ (NSCharacterSet *)xz_URIComponentAllowedCharacterSet {
    static NSCharacterSet *_URIComponentAllowedCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * const str = @""
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "0123456789"
        "().!~*'-_";
        _URIComponentAllowedCharacterSet = [NSCharacterSet characterSetWithCharactersInString:str];
    });
    return _URIComponentAllowedCharacterSet;
}

+ (NSCharacterSet *)xz_URLAllowedCharacterSet {
    static NSCharacterSet *_URLAllowedCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // https://datatracker.ietf.org/doc/html/rfc2396
        NSString * const URIReserved = @""
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "0123456789"
        ";/?:@&=+$,"
        "-_.!~*'()"
        "<>#%\""
        "{}|\\^[]`";
        NSMutableCharacterSet *characterSetM = [NSMutableCharacterSet characterSetWithCharactersInString:URIReserved];
        [characterSetM formUnionWithCharacterSet:NSCharacterSet.URLUserAllowedCharacterSet];
        [characterSetM formUnionWithCharacterSet:NSCharacterSet.URLPasswordAllowedCharacterSet];
        [characterSetM formUnionWithCharacterSet:NSCharacterSet.URLHostAllowedCharacterSet];
        [characterSetM formUnionWithCharacterSet:NSCharacterSet.URLPathAllowedCharacterSet];
        [characterSetM formUnionWithCharacterSet:NSCharacterSet.URLQueryAllowedCharacterSet];
        [characterSetM formUnionWithCharacterSet:NSCharacterSet.URLFragmentAllowedCharacterSet];
        _URLAllowedCharacterSet = [characterSetM copy];
    });
    return _URLAllowedCharacterSet;
}

+ (NSCharacterSet *)xz_alphaDigitCharacterSet {
    static NSCharacterSet *_alphaDigitCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * const str = @""
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "0123456789";
        _alphaDigitCharacterSet = [NSCharacterSet characterSetWithCharactersInString:str];
    });
    return _alphaDigitCharacterSet;
}

@end
