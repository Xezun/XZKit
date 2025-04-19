//
//  XZObjcDescriptor.h
//  XZKit
//
//  Created by Xezun on 2024/9/28.

#import <Foundation/Foundation.h>
#import "XZObjcType.h"
#import "XZObjcIvarDescriptor.h"
#import "XZObjcPropertyDescriptor.h"
#import "XZObjcMethodDescriptor.h"
#import "XZObjcClassDescriptor.h"

/// 类型是否为标量数值类型。
/// - Parameter type: 类型枚举
FOUNDATION_EXPORT BOOL XZObjcIsScalarNumber(XZObjcRaw type) NS_REFINED_FOR_SWIFT;
