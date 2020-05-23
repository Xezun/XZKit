//
//  XZKitRuntime.m
//  XZKit
//
//  Created by 徐臻 on 2019/3/27.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import "XZKit+Runtime.h"

NSString * _Nonnull xz_objc_class_name_create(Class _Nonnull existedClass) XZ_OBJC_FUNCTION_OVERLOADABLE {
    return xz_objc_class_name_create(NSStringFromClass(existedClass));
}

NSString * _Nonnull xz_objc_class_name_create(NSString * _Nonnull classNameBase) XZ_OBJC_FUNCTION_OVERLOADABLE {
    NSString *className = [NSString stringWithFormat:@"XZKit.%@", classNameBase];
    long flag = 1;
    while (objc_getClass(className.UTF8String) != nil) {
        className = [NSString stringWithFormat:@"XZKit.%@.%ld", classNameBase, flag++];
    }
    return className;
}

void xz_objc_class_exchangeMethodImplementations(Class aClass, SEL selector1, SEL selector2) {
    Method method1 = class_getInstanceMethod(aClass, selector1);
    Method method2 = class_getInstanceMethod(aClass, selector2);
    // 如果添加失败，则替换。
    if (!class_addMethod(aClass, selector1, method_getImplementation(method2), method_getTypeEncoding(method1))) {
        method_exchangeImplementations(method1, method2);
    }
}

void xz_objc_class_enumerateInstanceVariables(Class aClass, void (^block)(Ivar ivar)) {
    unsigned int count = 0;
    Ivar _Nonnull *ivars = class_copyIvarList(aClass, &count);
    if (count == 0) {
        return;
    }
    for (unsigned int i = 0; i < count; i++) {
        block(ivars[i]);
    }
    free(ivars);
}

NSArray<NSString *> *xz_objc_class_getInstanceVariableNames(Class aClass) {
    NSMutableArray * __block arrayM = nil;
    xz_objc_class_enumerateInstanceVariables(aClass, ^(Ivar ivar) {
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if (arrayM == nil) {
            arrayM = [NSMutableArray arrayWithObject:ivarName];
        } else {
            [arrayM addObject:ivarName];
        }
    });
    return arrayM;
}

void xz_objc_class_enumerateInstanceMethods(Class aClass, void (^block)(Method method)) {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(aClass, &count);
    if (count == 0) {
        return;
    }
    for (unsigned int i = 0; i < count; i++) {
        block(methods[i]);
    }
    free(methods);
}

NSArray<NSString *> *xz_objc_class_getInstanceMethodSelectors(Class aClass) {
    NSMutableArray * __block arrayM = nil;
    xz_objc_class_enumerateInstanceMethods(aClass, ^(Method method) {
        NSString *methodName = NSStringFromSelector(method_getName(method));
        if (arrayM == nil) {
            arrayM = [NSMutableArray arrayWithObject:methodName];
        } else {
            [arrayM addObject:methodName];
        }
    });
    return arrayM;
}
