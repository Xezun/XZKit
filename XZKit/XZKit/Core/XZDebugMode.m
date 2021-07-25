//
//  XZKitDEBUG.m
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import "XZDebugMode.h"

BOOL XZKitDebugMode = NO;

void __XZKIT_DEBUG_LOADER__(void) XZ_INIT {
    XZKitDebugMode = (bool)[NSProcessInfo.processInfo.arguments containsObject:@"-XZKitDEBUG"];
}
