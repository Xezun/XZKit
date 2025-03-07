//
//  XZRuntime.m
//  XZKit
//
//  Created by Xezun on 2019/3/27.
//  Copyright © 2019 XEZUN INC. All rights reserved.
//

#import "XZRuntime.h"

#pragma mark - Create

Class xz_objc_class_create(Class superClass, NSString *name, NS_NOESCAPE XZRuntimeClassing _Nullable classing) XZ_OVERLOADABLE {
    NSCParameterAssert([name isKindOfClass:NSString.class] && name.length > 0);
    const char * const className = name.UTF8String;
    
    Class newClass = objc_getClass(className);
    if (newClass != Nil) {
        return Nil;
    }
    
    if (newClass == Nil) {
        newClass = objc_allocateClassPair(superClass, className, 0);
        if (newClass != Nil) {
            if (classing != nil) {
                classing(newClass);
            }
            objc_registerClassPair(newClass);
        }
    }
    
    return newClass;
}

Class xz_objc_class_create(Class superClass, NS_NOESCAPE XZRuntimeClassing _Nullable classing) XZ_OVERLOADABLE {
    NSCParameterAssert(superClass != Nil);
    NSString *name = NSStringFromClass(superClass);
    if (![name hasPrefix:@"XZKit."]) {
        name = [NSString stringWithFormat:@"XZKit.%@", name];
    }
   
    Class newClass = xz_objc_class_create(superClass, name, classing);
    
    NSInteger i = 0;
    while (newClass == Nil && i < 1024) {
        name = [NSString stringWithFormat:@"%@.%ld", name, (long)(i++)];
        newClass = xz_objc_class_create(superClass, name, classing);
    }
    
    return newClass;
}


#pragma mark - Add Method

BOOL xz_objc_class_addMethod(Class target, Method method, id _Nullable implementation) XZ_OVERLOADABLE {
    if (target == Nil || method == nil) {
        return NO;
    }
    SEL const sel = method_getName(method);
    IMP const imp = implementation ? imp_implementationWithBlock(implementation) : method_getImplementation(method);
    const char * const encoding = method_getTypeEncoding(method);
    return class_addMethod(target, sel, imp, encoding);
}

BOOL xz_objc_class_copyMethod(Class target, Class source, SEL selector, id _Nullable implementation) XZ_OVERLOADABLE {
    if (source == Nil || selector == nil) {
        return NO;
    }
    Method const method = class_getInstanceMethod(source, selector);
    return xz_objc_class_addMethod(target, method, implementation);
}

NSInteger xz_objc_class_addMethods(Class target, Class source) {
    NSInteger __block count = 0;
    xz_objc_class_enumerateMethods(source, ^(Method method) {
        if (xz_objc_class_addMethod(target, method, nil)) {
            count += 1;
        }
    });
    return count;
}

#pragma mark - 给类添加实例变量

BOOL xz_objc_class_addVariable(Class target, Ivar ivar, size_t size, uint8_t alignment) XZ_OVERLOADABLE {
    if (target == Nil || ivar == nil) {
        return NO;
    }
    const char * const name = ivar_getName(ivar);
    const char * const type = ivar_getTypeEncoding(ivar);
    return class_addIvar(target, name, size, alignment, type);
}

BOOL xz_objc_class_addVariable(Class target, Ivar ivar) XZ_OVERLOADABLE {
    XZObjcTypeDescriptor *descriptor = [XZObjcTypeDescriptor descriptorWithTypeEncoding:ivar_getTypeEncoding(ivar)];
    return xz_objc_class_addVariable(target, ivar, descriptor.size, descriptor.alignment);
}

BOOL xz_objc_class_copyVariable(Class target, NSString *name, Class source) XZ_OVERLOADABLE {
    Ivar ivar = class_getInstanceVariable(source, name.UTF8String);
    return xz_objc_class_addVariable(target, ivar);
}

NSInteger xz_objc_class_copyVariables(Class target, Class source) {
    NSInteger __block count = 0;
    xz_objc_class_enumerateVariables(source, ^(Ivar ivar) {
        if (xz_objc_class_addVariable(target, ivar)) {
            count += 1;
        }
    });
    return count;
}


#pragma mark - 其他方法

void xz_objc_class_exchangeMethodImplementations(Class aClass, SEL selector1, SEL selector2) {
    Method method1 = class_getInstanceMethod(aClass, selector1);
    Method method2 = class_getInstanceMethod(aClass, selector2);
    // 如果添加失败，则替换。
    if (!class_addMethod(aClass, selector1, method_getImplementation(method2), method_getTypeEncoding(method1))) {
        method_exchangeImplementations(method1, method2);
    }
}

void xz_objc_class_enumerateVariables(Class aClass, void (^block)(Ivar ivar)) {
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

NSArray<NSString *> *xz_objc_class_getVariableNames(Class aClass) {
    NSMutableArray * __block arrayM = nil;
    xz_objc_class_enumerateVariables(aClass, ^(Ivar ivar) {
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if (arrayM == nil) {
            arrayM = [NSMutableArray arrayWithObject:ivarName];
        } else {
            [arrayM addObject:ivarName];
        }
    });
    return arrayM;
}

void xz_objc_class_enumerateMethods(Class aClass, void (^block)(Method method)) {
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

NSArray<NSString *> *xz_objc_class_getMethodSelectors(Class aClass) {
    NSMutableArray * __block arrayM = nil;
    xz_objc_class_enumerateMethods(aClass, ^(Method method) {
        NSString *methodName = NSStringFromSelector(method_getName(method));
        if (arrayM == nil) {
            arrayM = [NSMutableArray arrayWithObject:methodName];
        } else {
            [arrayM addObject:methodName];
        }
    });
    return arrayM;
}

