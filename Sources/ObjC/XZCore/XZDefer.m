//
//  XZDefer.m
//  XZKit
//
//  Created by Xezun on 2021/2/7.
//  Copyright © 2021 Xezun Inc. All rights reserved.
//

#import "XZDefer.h"

void __XZ_DEFER_OBSV__(void (^ _Nonnull * _Nonnull operation)(void)) {
    (*operation)();
}
