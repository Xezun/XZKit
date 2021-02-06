//
//  XZKitDEBUG.m
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#define XZKIT_PROTECTED
#import "XZKitDEBUG.h"

bool XZKitDebugMode = NO;

@implementation NSObject (XZKitDEBUG)

+ (void)load {
    XZKitDebugMode = (bool)[NSProcessInfo.processInfo.arguments containsObject:@"-XZKitDEBUG"];
}

@end
