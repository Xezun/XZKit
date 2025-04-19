//
//  XZObjcDescriptor.m
//  YYModel <https://github.com/ibireme/YYModel>
//
//  Created by ibireme on 15/5/9.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <objc/runtime.h>
#import "XZObjcDescriptor.h"

/// Whether the type is c number.
BOOL XZObjcIsScalarNumber(XZObjcRaw type) {
    switch (type) {
        case XZObjcRawChar:
        case XZObjcRawInt:
        case XZObjcRawShort:
        case XZObjcRawLong:
        case XZObjcRawLongLong:
        case XZObjcRawUnsignedChar:
        case XZObjcRawUnsignedInt:
        case XZObjcRawUnsignedShort:
        case XZObjcRawUnsignedLong:
        case XZObjcRawUnsignedLongLong:
        case XZObjcRawFloat:
        case XZObjcRawDouble:
        case XZObjcRawLongDouble:
        case XZObjcRawBool:
            return YES;
        case XZObjcRawVoid:
        case XZObjcRawString:
        case XZObjcRawObject:
        case XZObjcRawClass:
        case XZObjcRawSEL:
        case XZObjcRawArray:
        case XZObjcRawStruct:
        case XZObjcRawUnion:
        case XZObjcRawBitField:
        case XZObjcRawPointer:
        case XZObjcRawUnknown:
            return NO;
    }
}
