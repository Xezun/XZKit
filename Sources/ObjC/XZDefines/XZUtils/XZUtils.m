//
//  XZUtils.m
//  XZKit
//
//  Created by Xezun on 2023/8/6.
//

#import "XZUtils.h"
#import <sys/time.h>
#import "NSCharacterSet+XZKit.h"

NSTimeInterval const XZAnimationDuration = 0.35;

NSComparisonResult XZVersionCompare(NSString *version1, NSString *version2) {
    if (version1 == version2) {
        return NSOrderedSame;
    }
    if (![version1 isKindOfClass:NSString.class]) {
        if ([version2 isKindOfClass:NSString.class]) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }
    if (![version2 isKindOfClass:NSString.class]) {
        return NSOrderedDescending;
    }
    if ([version1 isEqualToString:version2]) {
        return NSOrderedSame;
    }
    if (version1.length == 0) {
        return NSOrderedAscending;
    }
    if (version2.length == 0) {
        return NSOrderedDescending;
    }
    NSArray<NSString *> * const subversions1 = [version1 componentsSeparatedByString:@"."];
    NSArray<NSString *> * const subversions2 = [version2 componentsSeparatedByString:@"."];
    for (NSInteger i = 0; i < subversions1.count; i++) {
        if (i < subversions2.count) {
            switch ([subversions1[0] compare:subversions2[0]]) {
                case NSOrderedSame:
                    continue;
                case NSOrderedAscending:
                    return NSOrderedAscending;
                case NSOrderedDescending:
                    return NSOrderedDescending;
            }
        } else {
            return NSOrderedDescending;
        }
    }
    return NSOrderedAscending;
}

NSTimeInterval XZTimestamp(void) {
    struct timeval aTime;
    gettimeofday(&aTime, NULL);
    NSTimeInterval sec = aTime.tv_sec;
    NSTimeInterval u_sec = aTime.tv_usec * 1.0e-6L;
    return (sec + u_sec);
}

NSURL * _Nullable NSURLFromString(NSString * _Nullable urlString) {
    if (![urlString isKindOfClass:NSString.class]) {
        return nil;
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    if (url) {
        return url;
    }
    
    if (@available(iOS 17.0, *)) {
        url = [NSURL URLWithString:urlString encodingInvalidCharacters:YES];
        if (url) {
            return url;
        }
    }
    
    NSCharacterSet * const URLAllowedCharacterSet = NSCharacterSet.xz_URLAllowedCharacterSet;
    if ([urlString rangeOfCharacterFromSet:URLAllowedCharacterSet].location != NSNotFound) {
        urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:URLAllowedCharacterSet];
        url = [NSURL URLWithString:urlString];
    }
    
    return url;
}

NSURL *NSURLMake(NSString *format, ...) {
    va_list arguments;
    va_start(arguments, format);
    NSString * const urlString = [[NSString alloc] initWithFormat:format arguments:arguments];
    NSURL    * const url       = NSURLFromString(urlString);
    va_end(arguments);
    return url;
}
