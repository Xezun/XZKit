//
//  XZTimestamp.m
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import "XZTimestamp.h"
#import <sys/time.h>

NSTimeInterval XZTimestamp() {
    struct timeval tv;
    if (gettimeofday(&tv, NULL)) {
        return NSDate.date.timeIntervalSince1970;
    };
    NSTimeInterval sec = tv.tv_sec;
    NSTimeInterval u_sec = tv.tv_usec * 1.0e-6L;
    return (sec + u_sec);
}
