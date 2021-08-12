//
//  XZKitDEBUG.m
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import "XZDebugMode.h"

BOOL XZKitDebugMode = NO;

void __XZKIT_MODE_INIT__(void) {
    XZKitDebugMode = (bool)[NSProcessInfo.processInfo.arguments containsObject:@"-XZKitDEBUG"];
}
