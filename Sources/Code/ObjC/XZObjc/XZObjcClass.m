//
//  XZObjcClass.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcClass.h"
#import "XZObjcIvar.h"
#import "XZObjcProperty.h"
#import "XZObjcMethod.h"

NSNotificationName const XZObjcClassDidDidBecomeInvalidNotification = @"XZObjcClassDidDidBecomeInvalidNotification";

static id withLock(id (^NS_NOESCAPE block)(CFMutableDictionaryRef const storage));

@interface XZObjcClass () {
    NSDictionary<NSString *,XZObjcIvar *> * _Nullable _ivars;
    NSDictionary<NSString *,XZObjcMethod *> * _Nullable _methods;
    NSDictionary<NSString *,XZObjcProperty *> * _Nullable _properties;
}

@property (atomic, readwrite) BOOL isValid;

@end

@implementation XZObjcClass

- (instancetype)initWithClass:(nonnull Class)class {
    self = [super init];
    if (self) {
        _raw = class;
        _isValid = YES;
        _name = NSStringFromClass(class);
        _type = [XZObjcType typeForEncoding:@encode(Class)];
        
        if ([XZObjcClass classForClass:[class superclass]]) {
            {
                unsigned int ivarCount = 0;
                Ivar *list = class_copyIvarList(class, &ivarCount);
                if (list && ivarCount > 0) {
                    NSMutableDictionary * const descriptors = [NSMutableDictionary dictionaryWithCapacity:ivarCount];
                    for (unsigned int i = 0; i < ivarCount; i++) {
                        XZObjcIvar *descriptor = [XZObjcIvar ivarWithIvar:list[i]];
                        if (descriptor) {
                            descriptors[descriptor.name] = descriptor;
                        }
                    }
                    free(list);
                    list = NULL;
                    
                    _ivars = descriptors;
                } else {
                    _ivars = @{};
                }
            }
            
            {
                unsigned int methodCount = 0;
                Method *list = class_copyMethodList(class, &methodCount);
                if (list && methodCount > 0) {
                    NSMutableDictionary *descriptors = [NSMutableDictionary dictionaryWithCapacity:methodCount];
                    for (unsigned int i = 0; i < methodCount; i++) {
                        XZObjcMethod *descriptor = [XZObjcMethod methodWithMethod:list[i]];
                        if (descriptor) {
                            descriptors[descriptor.name] = descriptor;
                        }
                    }
                    free(list);
                    list = NULL;
                    
                    _methods = descriptors;
                } else {
                    _methods = @{};
                }
            }
            
            {
                unsigned int propertyCount = 0;
                objc_property_t *list = class_copyPropertyList(class, &propertyCount);
                if (list && propertyCount > 0) {
                    NSMutableDictionary *descriptors = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
                    for (unsigned int i = 0; i < propertyCount; i++) {
                        XZObjcProperty *descriptor = [XZObjcProperty propertyWithProperty:list[i] class:class];
                        if (descriptor) {
                            descriptors[descriptor.name] = descriptor;
                        }
                    }
                    free(list);
                    list = NULL;
                    
                    _properties = descriptors;
                } else {
                    _properties = @{};
                }
            }
        } else {
            _ivars = @{};
            _methods = @{};
            _properties = @{};
        }
    }
    return self;
}

- (XZObjcClass *)superDescriptor {
    return [XZObjcClass classForClass:[self->_raw superclass]];
}

- (NSString *)description {
    NSString *ivars = nil;
    if (self.ivars.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.ivars enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZObjcIvar * _Nonnull obj, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@, %@>,\n", obj, obj.name, ((id)obj.type.classType ?: obj.type.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        ivars = stringM;
    }
    
    NSString *properties = nil;
    if (self.properties.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.properties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZObjcProperty * _Nonnull obj, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@, %@>,\n", obj, obj.name, ((id)obj.type.classType ?: obj.type.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        properties = stringM;
    }
    
    NSString *methods = nil;
    if (self.methods.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.methods enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZObjcMethod * _Nonnull obj, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@, %@>,\n", obj, obj.name, ((id)obj.type.classType ?: obj.type.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        methods = stringM;
    }
    
    NSString *type = [NSString stringWithFormat:@"<%p, %@>", self.type, (id)self.type.classType ?: self.type.name];
    
    return [NSString stringWithFormat:@"<%@: %p, name: %@, type: %@, ivars: %@, properties: %@, methods: %@>", NSStringFromClass(self.class), self, self.name, type, ivars, properties, methods];
}

- (void)invalidate {
    // 基类不会失效
    if (self.superDescriptor == nil) {
        return;
    }
    
    if (self.isValid) {
        [XZObjcClass invalidateClass:_raw];
    }
}

+ (instancetype)classForClass:(Class)class {
    if (!object_isClass(class)) {
        return nil;
    }
    
    XZObjcClass * const classObject = withLock(^id(CFMutableDictionaryRef const storage) {
        CFTypeRef const value = CFDictionaryGetValue(storage, (__bridge const void *)class);
        return value ? (__bridge id)value : nil;
    });
    if (classObject) {
        return classObject;
    }
    
    // 因为会递归创建超类，不能在锁内创建。
    XZObjcClass * const newClass = [[XZObjcClass alloc] initWithClass:class];
    
    return withLock(^id(CFMutableDictionaryRef const storage) {
        CFTypeRef const oldClass = CFDictionaryGetValue(storage, (__bridge const void *)class);
        if (oldClass) {
            return (__bridge id)oldClass;
        }
        CFDictionarySetValue(storage, (__bridge const void *)class, (__bridge const void *)newClass);
        return newClass;
    });
}

+ (void)invalidate:(Class)rawClass {
    if (!object_isClass(rawClass)) {
        return;
    }
    [self invalidateClass:rawClass];
}

+ (void)invalidateClass:(Class)class {
    XZObjcClass *classObject = withLock(^id(const CFMutableDictionaryRef storage) {
        CFTypeRef const value = CFDictionaryGetValue(storage, (__bridge const void *)class);
        if (value == NULL) {
            return nil;
        }
        
        XZObjcClass *classObject = (__bridge id)value; // ARC 会 retain 这个对象
        classObject.isValid = NO;
        CFDictionaryRemoveValue(storage, (__bridge const void *)class);
        
        return classObject; // autorelease
    });
    
    if (!classObject) {
        return;
    }
    [NSNotificationCenter.defaultCenter postNotificationName:XZObjcClassDidDidBecomeInvalidNotification object:classObject];
}

@end

static id withLock(id (^NS_NOESCAPE block)(CFMutableDictionaryRef const storage)) {
    static CFMutableDictionaryRef _storage = nil;
    static dispatch_semaphore_t _lock;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lock = dispatch_semaphore_create(1);
        _storage = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    });
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    id const value = block(_storage);
    dispatch_semaphore_signal(_lock);
    
    return value;
}
