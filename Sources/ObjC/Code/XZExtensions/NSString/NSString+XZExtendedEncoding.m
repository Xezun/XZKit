//
//  NSString+XZExtendedEncoding.m
//  XZKit
//
//  Created by 徐臻 on 2025/7/16.
//

#import "NSString+XZExtendedEncoding.h"
#import "NSCharacterSet+XZKit.h"

@implementation NSString (XZExtendedEncoding)

- (NSString *)xz_stringByAddingPercentEncoding {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.xz_letterAndDigitCharacterSet];
}

- (NSString *)xz_stringByAddingURIEncoding {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.xz_URIAllowedCharacterSet];
}

- (NSString *)xz_stringByAddingURIComponentEncoding {
    return [self stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.xz_URIComponentAllowedCharacterSet];
}

- (NSString *)xz_stringByRemovingURIEncoding {
    return [self stringByRemovingPercentEncoding];
}

- (NSString *)xz_stringByRemovingURIComponentEncoding {
    return [self stringByRemovingPercentEncoding];
}

- (NSString *)xz_stringByTransformingMandarinToLatin {
    return [self xz_stringByTransformingMandarinToLatin:YES];
}

- (NSString *)xz_stringByTransformingMandarinToLatin:(BOOL)removesDiacriticMarkings {
    CFMutableStringRef mString = CFStringCreateMutableCopy(kCFAllocatorDefault, self.length, (__bridge CFStringRef)self);
    
    CFStringTransform(mString, nil, kCFStringTransformMandarinLatin, false);
    if (removesDiacriticMarkings) {
        CFStringTransform(mString, nil, kCFStringTransformStripDiacritics, false);
    }
    
    return (__bridge_transfer NSString *)mString;
}

@end
