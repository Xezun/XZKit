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

+ (NSCharacterSet *)xz_letterAndDigitCharacterSet {
    static NSCharacterSet *_letterAndDigitCharacterSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * const str = @""
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz"
        "0123456789";
        _letterAndDigitCharacterSet = [NSCharacterSet characterSetWithCharactersInString:str];
    });
    return _letterAndDigitCharacterSet;
}

@end
