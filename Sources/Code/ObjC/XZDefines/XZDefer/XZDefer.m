//
//  XZDefer.m
//  XZKit
//
//  Created by Xezun on 2023/8/6.
//

#import "XZDefer.h"

#ifndef XZ_DEFER
void __xz_defer_imp__(__strong __xz_defer_t__ _Nonnull * _Nonnull statements) {
    (*statements)();
}
#endif
