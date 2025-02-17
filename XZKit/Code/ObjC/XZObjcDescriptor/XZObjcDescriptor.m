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
BOOL XZObjcIsScalarNumber(XZObjcType type) {
    switch (type) {
        case XZObjcTypeChar:
        case XZObjcTypeInt:
        case XZObjcTypeShort:
        case XZObjcTypeLong:
        case XZObjcTypeLongLong:
        case XZObjcTypeUnsignedChar:
        case XZObjcTypeUnsignedInt:
        case XZObjcTypeUnsignedShort:
        case XZObjcTypeUnsignedLong:
        case XZObjcTypeUnsignedLongLong:
        case XZObjcTypeFloat:
        case XZObjcTypeDouble:
        case XZObjcTypeLongDouble:
        case XZObjcTypeBool:
            return YES;
        case XZObjcTypeVoid:
        case XZObjcTypeString:
        case XZObjcTypeObject:
        case XZObjcTypeClass:
        case XZObjcTypeSEL:
        case XZObjcTypeArray:
        case XZObjcTypeStruct:
        case XZObjcTypeUnion:
        case XZObjcTypeBitField:
        case XZObjcTypePointer:
        case XZObjcTypeUnknown:
            return NO;
    }
}
