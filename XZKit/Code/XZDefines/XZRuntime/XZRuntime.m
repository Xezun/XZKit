//
//  XZRuntime.m
//  XZKit
//
//  Created by Xezun on 2021/5/7.
//

#import "XZRuntime.h"

Method xz_objc_class_getMethod(Class const cls, SEL const target) {
    Method __block result = NULL;
    
    xz_objc_class_enumerateMethods(cls, ^BOOL(Method method, NSInteger index) {
        if (method_getName(method) == target) {
            result = method;
            return NO;
        }
        return YES;
    });
    
    return result;
}

void xz_objc_class_enumerateMethods(Class aClass, BOOL (^enumerator)(Method method, NSInteger index)) {
    unsigned int count = 0;
    Method *methods = class_copyMethodList(aClass, &count);
    if (count == 0) {
        return;
    }
    
    for (unsigned int i = 0; i < count; i++) {
        if (!enumerator(methods[i], i)) {
            break;
        }
    }
    free(methods);
}

void xz_objc_class_enumerateVariables(Class aClass, BOOL (^enumerator)(Ivar ivar)) {
    unsigned int count = 0;
    Ivar _Nonnull *ivars = class_copyIvarList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        if (!enumerator(ivars[i])) {
            break;
        }
    }
    free(ivars);
}

NSArray<NSString *> *xz_objc_class_getVariableNames(Class aClass) {
    NSMutableArray * __block arrayM = nil;
    xz_objc_class_enumerateVariables(aClass, ^BOOL(Ivar ivar) {
        NSString *ivarName = [NSString stringWithUTF8String:ivar_getName(ivar)];
        if (arrayM == nil) {
            arrayM = [NSMutableArray arrayWithObject:ivarName];
        } else {
            [arrayM addObject:ivarName];
        }
        return YES;
    });
    return arrayM;
}

void xz_objc_class_exchangeMethods(Class aClass, SEL selector1, SEL selector2) {
    if (aClass == Nil || selector1 == nil || selector2 == nil) {
        return;
    }
    
    Method method1 = class_getInstanceMethod(aClass, selector1);
    if (method1 == nil) return;
    Method method2 = class_getInstanceMethod(aClass, selector2);
    if (method2 == nil) return;
    // 如果添加失败，则替换。
    method_exchangeImplementations(method1, method2);
}

BOOL xz_objc_class_addMethod(Class aClass, SEL selector, Class _Nullable source, SEL _Nullable creation, SEL _Nullable override, SEL _Nullable exchange) {
    if (aClass == Nil || selector == Nil) {
        return NO;
    }
    
    if (source == Nil) {
        if (creation == nil) {
            return NO;
        }
        source = aClass;
    } else if (creation == Nil) {
        if (aClass == source) {
            return NO;
        }
        creation = selector;
    }
    
    // 方法已实现
    if ([aClass instancesRespondToSelector:selector]) {
        Method const oldMethod = xz_objc_class_getMethod(aClass, selector);
        
        // 当前类没有这个方法，说明方法由父类实现，重写方法。
        if (oldMethod == NULL) {
            if (override == NULL) {
                return NO;
            }
            
            Method      const overrideMethod         = class_getInstanceMethod(source, override);
            IMP         const overrideMethodIMP      = method_getImplementation(overrideMethod);
            const char *const overrideMethodEncoding = method_getTypeEncoding(overrideMethod);

            return class_addMethod(aClass, selector, overrideMethodIMP, overrideMethodEncoding);
        }
        
        // 方法已自身实现，交换方法
        if (exchange == NULL) {
            return NO;
        }
        
        // 先将待交换的方法，添加到 aClass 上，然后再交换 aClass 上的两个方法的实现。
        Method exchangeMethod = class_getInstanceMethod(source, exchange);
        if (aClass != source) {
            // 将待交换的方法添加到自身，要先判断自身是否已有这个方法。
            // 虽然可以通过重命名的方法，将方法给 aClass 添加上，
            // 但是这样可能导致调用原方法的代码失效，因为原方法已经被换到重命名后的方法上。
            // 所以这里返回 NO 由开发者处理此问题。
            if ([aClass instancesRespondToSelector:exchange]) {
                return NO;
            }
            
            // 将 exchange 添加到 aClass 上
            if (!class_addMethod(aClass, exchange, method_getImplementation(exchangeMethod), method_getTypeEncoding(exchangeMethod))) {
                return NO;
            }
            
            // 重新获取添加的方法
            exchangeMethod = class_getInstanceMethod(aClass, exchange);
        }
        
        method_exchangeImplementations(oldMethod, exchangeMethod);
        return YES;
    }
    
    // 方法未实现，添加新方法
    Method      const mtd = class_getInstanceMethod(source, creation);
    IMP         const imp = method_getImplementation(mtd);
    const char *const enc = method_getTypeEncoding(mtd);
    return class_addMethod(aClass, selector, imp, enc);
}

const char *xz_objc_class_getMethodTypeEncoding(Class aClass, SEL selector) {
    if (aClass == Nil || selector == nil) {
        return NULL;
    }
    Method method = class_getInstanceMethod(aClass, selector);
    if (method == nil) {
        return NULL;
    }
    return method_getTypeEncoding(method);
}

BOOL xz_objc_class_addMethodWithBlock(Class aClass, SEL selector, const char *encoding, id _Nullable creation, id _Nullable override, id (^ _Nullable exchange)(SEL exchange)) {
    if (aClass == Nil || selector == Nil) {
        return NO;
    }
    
    if (creation == nil && override == nil && exchange == nil) {
        return NO;
    }
    
    // 方法已实现
    if ([aClass instancesRespondToSelector:selector]) {
        Method const oldMethod = xz_objc_class_getMethod(aClass, selector);
        if (encoding == NULL) {
            encoding = method_getTypeEncoding(class_getInstanceMethod(aClass, selector));
        }
        
        // 当前类没有这个方法，说明方法由父类实现，重写方法。
        if (oldMethod == NULL) {
            if (override == NULL) {
                return NO;
            }
            
            IMP const overrideIMP = imp_implementationWithBlock(override);
            if (overrideIMP == nil) {
                return NO;
            }
            
            return class_addMethod(aClass, selector, overrideIMP, encoding);
        }
        
        // 方法已自身实现，交换方法
        if (exchange == nil) {
            return NO;
        }
        
        // 动态生成一个可以用于添加交换方法的方法名
        SEL exchangeSEL = nil;
        NSString * const baseName = NSStringFromSelector(selector);
        NSInteger index = 0;
        do {
            NSString *newName = [NSString stringWithFormat:@"__xz_exchange_%ld_%@", (long)index++, baseName];
            exchangeSEL = sel_registerName(newName.UTF8String);
        } while ([aClass instancesRespondToSelector:exchangeSEL]);
        
        // 生成方法 IMP
        id const exchangeBlock = exchange(exchangeSEL);
        if (exchangeBlock == nil) {
            return NO;
        }
        
        IMP const exchangeIMP = imp_implementationWithBlock(exchangeBlock);
        if (exchangeIMP == nil) {
            return NO;
        }
        
        // 将 exchange 添加到 aClass 上
        if (!class_addMethod(aClass, exchangeSEL, exchangeIMP, encoding)) {
            return NO;
        }
        
        // 交换方法
        Method exchangeMethod = class_getInstanceMethod(aClass, exchangeSEL);
        method_exchangeImplementations(oldMethod, exchangeMethod);
        return YES;
    }
    
    // 方法未实现，添加新方法
    if (creation == nil || encoding == NULL) {
        return NO;
    }
    
    IMP const imp = imp_implementationWithBlock(creation);
    return class_addMethod(aClass, selector, imp, encoding);
}

#pragma mark - 创建类

Class xz_objc_createClassWithName(Class superClass, NSString *name, NS_NOESCAPE XZRuntimeCreateClassBlock _Nullable block) {
    NSCParameterAssert([name isKindOfClass:NSString.class] && name.length > 0);
    const char * const className = name.UTF8String;
    
    Class newClass = objc_getClass(className);
    if (newClass != Nil) {
        return Nil;
    }
    
    newClass = objc_allocateClassPair(superClass, className, 0);
    if (newClass != Nil) {
        if (block != nil) {
            block(newClass);
        }
        objc_registerClassPair(newClass);
    }
    
    return newClass;
}

Class xz_objc_createClass(Class superClass, NS_NOESCAPE XZRuntimeCreateClassBlock _Nullable block)  {
    NSCParameterAssert(superClass != Nil);
    NSString *name = NSStringFromClass(superClass);
    if (![name hasPrefix:@"XZKit."]) {
        name = [NSString stringWithFormat:@"XZKit.%@", name];
    }
   
    Class newClass = xz_objc_createClassWithName(superClass, name, block);
    
    NSInteger i = 0;
    while (newClass == Nil) {
        NSString *newName = [NSString stringWithFormat:@"%@.%ld", name, (long)(i++)];
        newClass = xz_objc_createClassWithName(superClass, newName, block);
    }
    
    return newClass;
}


#pragma mark - 添加方法

BOOL xz_objc_class_copyMethod(Class source, SEL sourceSelector, Class target, SEL targetSelector) {
    if (source == Nil || sourceSelector == nil) {
        return NO;
    }
    
    if (target == Nil) {
        if (targetSelector == nil) {
            return NO;
        }
        target = source;
    } else if (targetSelector == nil) {
        if (source == target) {
            return NO;
        }
        targetSelector = sourceSelector;
    }
    
    if ([target instancesRespondToSelector:targetSelector]) {
        if (xz_objc_class_getMethod(target, targetSelector) != nil) {
            return NO;
        }
    }
    
    Method       const mtd = class_getInstanceMethod(source, sourceSelector);
    IMP          const imp = method_getImplementation(mtd);
    const char * const enc = method_getTypeEncoding(mtd);
    
    return class_addMethod(target, targetSelector, imp, enc);
}

NSInteger xz_objc_class_copyMethods(Class source, Class target) {
    NSInteger __block result = 0;
    
    unsigned int count = 0;
    Method *oldMethods = class_copyMethodList(target, &count);
    xz_objc_class_enumerateMethods(source, ^BOOL(Method method, NSInteger index) {
        // 不复制同名的方法
        for (unsigned int i = 0; i < count; i++) {
            if (oldMethods[i] == method) return YES;
            if (method_getName(oldMethods[i]) == method_getName(method)) return YES;
        }
        // 复制方法
        SEL          const sel = method_getName(method);
        IMP          const imp = method_getImplementation(method);
        const char * const enc = method_getTypeEncoding(method);
        if (class_addMethod(target, sel, imp, enc)) {
            result += 1;
        }
        return YES;
    });
    free(oldMethods);
    
    return result;
}

NSHashTable *xz_objc_protocol_getInstanceMethods(Protocol *aProtocol) {
    NSHashTable * const table = [NSHashTable hashTableWithOptions:(NSPointerFunctionsOpaquePersonality)];
    
    Protocol * const root = @protocol(NSObject);
    
    unsigned int count = 0;
    Protocol * __unsafe_unretained _Nonnull * const list = protocol_copyProtocolList(aProtocol, &count);
    
    unsigned int i = -1;
    while (YES) {
        if (aProtocol != root) {
            unsigned int count = 0;
            struct objc_method_description *list = protocol_copyMethodDescriptionList(aProtocol, YES, YES, &count);
            for (unsigned int i = 0; i < count; i++) {
                NSHashInsert(table, list[i].name);
            }
            
            count = 0;
            list = protocol_copyMethodDescriptionList(aProtocol, NO, YES, &count);
            for (unsigned int i = 0; i < count; i++) {
                NSLog(@"%@", NSStringFromSelector(list[i].name));
                NSHashInsert(table, list[i].name);
            }
        }
        i += 1;
        if (i >= count) {
            break;
        }
        aProtocol = list[i];
    }
    
    return table;
}

NSHashTable *xz_objc_class_getImplementedProtocolMethods(Class aClass, NSHashTable *protocolMethods) {
    NSHashTable * const table = [NSHashTable hashTableWithOptions:(NSPointerFunctionsOpaquePersonality)];
    unsigned int count = 0;
    Method *list = class_copyMethodList(aClass, &count);
    for (unsigned int i = 0; i < count; i++) {
        SEL const name = method_getName(list[i]);
        if (NSHashGet(protocolMethods, name)) {
            NSHashInsert(table, method_getName(list[i]));
        }
    }
    
    aClass = [aClass superclass];
    if (aClass && aClass != [NSObject class]) {
        [table unionHashTable:xz_objc_class_getImplementedProtocolMethods(aClass, protocolMethods)];
    }
    
    return table;
}

#if XZ_FRAMEWORK
void xz_objc_msgSendSuper_void_id(id receiver, Class receiverClass, SEL selector, id param1) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    ((void (*)(struct objc_super *, SEL, id))objc_msgSendSuper)(&_super, selector, param1);
}
void xz_objc_msgSend_void_id(id receiver, SEL selector, id param1) {
    ((void (*)(id, SEL, id))objc_msgSend)(receiver, selector, param1);
}

void xz_objc_msgSendSuper_void_id_bool(id receiver, Class receiverClass, SEL selector, id param1, BOOL param2) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    ((void (*)(struct objc_super *, SEL, id, BOOL))objc_msgSendSuper)(&_super, selector, param1, param2);
}
void xz_objc_msgSend_void_id_bool(id receiver, SEL selector, id param1, BOOL param2) {
    ((void (*)(id, SEL, id, BOOL))objc_msgSend)(receiver, selector, param1, param2);
}

id xz_objc_msgSendSuper_id_bool(id receiver, Class receiverClass, SEL selector, BOOL param1) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    return ((id (*)(struct objc_super *, SEL, BOOL))objc_msgSendSuper)(&_super, selector, param1);
}
id xz_objc_msgSend_id_bool(id receiver, SEL selector, BOOL param1) {
    return ((id (*)(id, SEL, BOOL))objc_msgSend)(receiver, selector, param1);
}

id xz_objc_msgSendSuper_id_id_bool(id receiver, Class receiverClass, SEL selector, id param1, BOOL param2) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    return ((id (*)(struct objc_super *, SEL, id, BOOL))objc_msgSendSuper)(&_super, selector, param1, param2);
}
id xz_objc_msgSend_id_id_bool(id receiver, SEL selector, id param1, BOOL param2) {
    return ((id (*)(id, SEL, id, BOOL))objc_msgSend)(receiver, selector, param1, param2);
}

void xz_objc_msgSendSuper_void_bool(id receiver, Class receiverClass, SEL selector, BOOL param1) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    ((void (*)(struct objc_super *, SEL, BOOL))objc_msgSendSuper)(&_super, selector, param1);
}
void xz_objc_msgSend_void_bool(id receiver, SEL selector, BOOL param1) {
    ((void (*)(id, SEL, BOOL))objc_msgSend)(receiver, selector, param1);
}


id xz_objc_msgSendSuper_id_id_integer_id_id(id receiver, Class receiverClass, SEL selector, id param1, NSInteger param2, id param3, id param4) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    return ((id(*)(struct objc_super *, SEL, id, NSInteger, id, id))objc_msgSendSuper)(&_super, selector, param1, param2, param3, param4);
}
id xz_objc_msgSend_id_id_integer_id_id(id receiver, SEL selector, id param1, NSInteger param2, id param3, id param4) {
    return ((id(*)(id, SEL, id, NSInteger, id, id))objc_msgSend)(receiver, selector, param1, param2, param3, param4);
}

id xz_objc_msgSendSuper_id_id_id(id receiver, Class receiverClass, SEL selector, id param1, id param2) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    return ((id(*)(struct objc_super *,SEL,id,id))objc_msgSendSuper)(&_super, selector, param1, param2);
}
id xz_objc_msgSend_id_id_id(id receiver, SEL selector, id param1, id param2) {
    return ((id(*)(id,SEL,id,id))objc_msgSend)(receiver, selector, param1, param2);
}

CGRect xz_objc_msgSendSuper_rect(id receiver, Class receiverClass, SEL selector) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    return ((CGRect(*)(struct objc_super *, SEL))objc_msgSendSuper)(&_super, selector);
}

CGRect xz_objc_msgSend_rect(id receiver, SEL selector) {
     return ((CGRect(*)(id, SEL))objc_msgSend)(receiver, selector);
}


void xz_objc_msgSendSuper_void_rect(id receiver, Class receiverClass, SEL selector, CGRect param1) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    ((void (*)(struct objc_super *, SEL, CGRect))objc_msgSendSuper)(&_super, selector, param1);
}
void xz_objc_msgSend_void_rect(id receiver, SEL selector, CGRect param1) {
    ((void (*)(id, SEL, CGRect))objc_msgSend)(receiver, selector, param1);
}

BOOL xz_objc_msgSendSuper_bool(id receiver, Class receiverClass, SEL selector) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    return ((BOOL (*)(struct objc_super *, SEL))objc_msgSendSuper)(&_super, selector);
}
BOOL xz_objc_msgSend_bool(id receiver, SEL selector) {
    return ((BOOL (*)(id, SEL))objc_msgSend)(receiver, selector);
}


void xz_objc_msgSendSuper_void(id receiver, Class receiverClass, SEL selector) {
     struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    ((void (*)(struct objc_super *, SEL))objc_msgSendSuper)(&_super, selector);
}
void xz_objc_msgSend_void(id receiver, SEL selector) {
    ((void (*)(id, SEL))objc_msgSend)(receiver, selector);
}


void xz_objc_msgSendSuper_void_id_integer(id receiver, Class receiverClass, SEL selector, id param1, NSInteger param2) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    ((void (*)(struct objc_super *, SEL, id, NSInteger))objc_msgSendSuper)(&_super, selector, param1, param2);
}
void xz_objc_msgSend_void_id_integer(id receiver, SEL selector, id param1, NSInteger param2) {
    ((void(*)(id, SEL, id, NSInteger))objc_msgSend)(receiver, selector, param1, param2);
}

void xz_objc_msgSendSuper_void_id_id(id receiver, Class receiverClass, SEL selector, id param1, id param2) {
    struct objc_super _super = {
        .receiver = receiver,
        .super_class = class_getSuperclass(receiverClass)
    };
    ((void (*)(struct objc_super *, SEL, id, id))objc_msgSendSuper)(&_super, selector, param1, param2);
}
void xz_objc_msgSend_void_id_id(id receiver, SEL selector, id param1, id param2) {
    ((void (*)(id, SEL, id, id))objc_msgSend)(receiver, selector, param1, param2);
}
#endif
