//
//  XZUtils.m
//  XZKit
//
//  Created by Xezun on 2023/8/6.
//

#import "XZUtils.h"
#import <sys/time.h>

NSTimeInterval const XZAnimationDuration = 0.35;

NSComparisonResult XZVersionStringCompare(NSString *version1, NSString *version2) {
    if (![version1 isKindOfClass:NSString.class]) {
        return NSOrderedAscending;
    }
    if (![version2 isKindOfClass:NSString.class]) {
        return NSOrderedDescending;
    }
    if ([version1 isEqualToString:version2]) {
        return NSOrderedSame;
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


