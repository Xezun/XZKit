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

static id withStorage(id (^NS_NOESCAPE block)(CFMutableDictionaryRef const storage));

@interface XZObjcClass () {
    NSDictionary<NSString *,XZObjcIvar *> * _Nullable _ivars;
    NSDictionary<NSString *,XZObjcMethod *> * _Nullable _methods;
    NSDictionary<NSString *,XZObjcProperty *> * _Nullable _properties;
}

@property (atomic, readwrite) BOOL isValid;

@end

@implementation XZObjcClass

- (instancetype)initWithClass:(nonnull Class)rawClass {
    self = [super init];
    if (self) {
        _raw = rawClass;
        _isValid = YES;
        _name = NSStringFromClass(rawClass);
        _type = [XZObjcType typeForEncoding:@encode(Class)];
        
        if ([XZObjcClass classForClass:[rawClass superclass]]) {
            {
                unsigned int ivarCount = 0;
                Ivar *list = class_copyIvarList(rawClass, &ivarCount);
                if (list && ivarCount > 0) {
                    NSMutableDictionary * const descriptors = [NSMutableDictionary dictionaryWithCapacity:ivarCount];
                    for (unsigned int i = 0; i < ivarCount; i++) {
                        XZObjcIvar *descriptor = [XZObjcIvar ivarForIvar:list[i]];
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
                Method *list = class_copyMethodList(rawClass, &methodCount);
                if (list && methodCount > 0) {
                    NSMutableDictionary *descriptors = [NSMutableDictionary dictionaryWithCapacity:methodCount];
                    for (unsigned int i = 0; i < methodCount; i++) {
                        XZObjcMethod *descriptor = [XZObjcMethod methodForMethod:list[i]];
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
                objc_property_t *list = class_copyPropertyList(rawClass, &propertyCount);
                if (list && propertyCount > 0) {
                    NSMutableDictionary *descriptors = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
                    for (unsigned int i = 0; i < propertyCount; i++) {
                        XZObjcProperty *descriptor = [XZObjcProperty propertyForProperty:list[i] forClass:rawClass];
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
            [stringM appendFormat:@"    <%p, %@, %@>,\n", obj, obj.name, ((id)obj.type.subtype ?: obj.type.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        ivars = stringM;
    }
    
    NSString *properties = nil;
    if (self.properties.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.properties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZObjcProperty * _Nonnull obj, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@, %@>,\n", obj, obj.name, ((id)obj.type.subtype ?: obj.type.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        properties = stringM;
    }
    
    NSString *methods = nil;
    if (self.methods.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.methods enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZObjcMethod * _Nonnull obj, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@, %@>,\n", obj, obj.name, ((id)obj.type.subtype ?: obj.type.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        methods = stringM;
    }
    
    NSString *type = [NSString stringWithFormat:@"<%p, %@>", self.type, (id)self.type.subtype ?: self.type.name];
    
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

+ (instancetype)classForClass:(Class)rawClass {
    if (!object_isClass(rawClass)) {
        return nil;
    }
    
    XZObjcClass * const aClass = withStorage(^id(CFMutableDictionaryRef const storage) {
        CFTypeRef const value = CFDictionaryGetValue(storage, (__bridge const void *)rawClass);
        return value ? (__bridge id)value : nil;
    });
    if (aClass) {
        return aClass;
    }
    
    XZObjcClass * const newClass = [[XZObjcClass alloc] initWithClass:rawClass];
    return withStorage(^id(CFMutableDictionaryRef const storage) {
        CFTypeRef const oldClass = CFDictionaryGetValue(storage, (__bridge const void *)rawClass);
        if (oldClass) {
            return (__bridge id)oldClass;
        }
        CFDictionarySetValue(storage, (__bridge const void *)rawClass, (__bridge const void *)newClass);
        return newClass;
    });
}

+ (void)invalidate:(Class)rawClass {
    if (!object_isClass(rawClass)) {
        return;
    }
    [self invalidateClass:rawClass];
}

+ (void)invalidateClass:(Class)rawClass {
    XZObjcClass *aClass = withStorage(^id(const CFMutableDictionaryRef storage) {
        CFTypeRef const value = CFDictionaryGetValue(storage, (__bridge const void *)rawClass);
        if (value == NULL) {
            return nil;
        }
        
        ((__bridge XZObjcClass *)value).isValid = NO;
        CFDictionaryRemoveValue(storage, (__bridge const void *)rawClass);
        
        return (__bridge id)value;
    });
    
    if (aClass) {
        [NSNotificationCenter.defaultCenter postNotificationName:XZObjcClassDidDidBecomeInvalidNotification object:aClass];
    }
}

@end

static id withStorage(id (^NS_NOESCAPE block)(CFMutableDictionaryRef const storage)) {
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
