//
//  XZObjcClassDescriptor.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcClassDescriptor.h"
#import "XZObjcIvarDescriptor.h"
#import "XZObjcPropertyDescriptor.h"
#import "XZObjcMethodDescriptor.h"

NSNotificationName const XZObjcClassDidChangeNotification = @"XZObjcClassDidChangeNotification";

/// 在 block 中，可以安全的访问存储。
static id withStorage(id (^block)(CFMutableDictionaryRef const storage)) {
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

@interface XZObjcClassDescriptor () {
    NSDictionary<NSString *,XZObjcIvarDescriptor *> * _Nullable _ivars;
    NSDictionary<NSString *,XZObjcMethodDescriptor *> * _Nullable _methods;
    NSDictionary<NSString *,XZObjcPropertyDescriptor *> * _Nullable _properties;
}

@property (atomic, readwrite) BOOL isValid;

@end

@implementation XZObjcClassDescriptor

- (instancetype)initWithClass:(nonnull Class)rawClass {
    self = [super init];
    if (self) {
        _raw = rawClass;
        _isValid = YES;
        _name = NSStringFromClass(rawClass);
        _type = [XZObjcTypeDescriptor descriptorForType:@encode(Class)];
        
        if ([XZObjcClassDescriptor descriptorForClass:[rawClass superclass]]) {
            {
                unsigned int ivarCount = 0;
                Ivar *list = class_copyIvarList(rawClass, &ivarCount);
                if (list && ivarCount > 0) {
                    NSMutableDictionary * const descriptors = [NSMutableDictionary dictionaryWithCapacity:ivarCount];
                    for (unsigned int i = 0; i < ivarCount; i++) {
                        XZObjcIvarDescriptor *descriptor = [XZObjcIvarDescriptor descriptorForIvar:list[i]];
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
                        XZObjcMethodDescriptor *descriptor = [XZObjcMethodDescriptor descriptorForMethod:list[i]];
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
                        XZObjcPropertyDescriptor *descriptor = [XZObjcPropertyDescriptor descriptorForProperty:list[i] ofClass:rawClass];
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

- (XZObjcClassDescriptor *)superDescriptor {
    return [XZObjcClassDescriptor descriptorForClass:[self->_raw superclass]];
}

- (NSString *)description {
    NSString *ivars = nil;
    if (self.ivars.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.ivars enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZObjcIvarDescriptor * _Nonnull obj, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@, %@>,\n", obj, obj.name, ((id)obj.type.subtype ?: obj.type.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        ivars = stringM;
    }
    
    NSString *properties = nil;
    if (self.properties.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.properties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZObjcPropertyDescriptor * _Nonnull obj, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"    <%p, %@, %@>,\n", obj, obj.name, ((id)obj.type.subtype ?: obj.type.name)];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 2, 1)];
        [stringM appendString:@"]"];
        properties = stringM;
    }
    
    NSString *methods = nil;
    if (self.methods.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.methods enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZObjcMethodDescriptor * _Nonnull obj, BOOL * _Nonnull stop) {
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
    [XZObjcClassDescriptor invalidateDescriptor:self];
}

+ (instancetype)descriptorForClass:(Class)rawClass {
    if (!object_isClass(rawClass)) {
        return nil;
    }
    
    XZObjcClassDescriptor * const descriptor = withStorage(^id(CFMutableDictionaryRef const storage) {
        CFTypeRef const value = CFDictionaryGetValue(storage, (__bridge const void *)rawClass);
        return value ? (__bridge_transfer id)CFRetain(value) : nil;
    });
    if (descriptor) {
        return descriptor;
    }
    
    XZObjcClassDescriptor * const newDescriptor = [[XZObjcClassDescriptor alloc] initWithClass:rawClass];
    return withStorage(^id(CFMutableDictionaryRef const storage) {
        CFTypeRef const oldDescriptor = CFDictionaryGetValue(storage, (__bridge const void *)rawClass);
        if (oldDescriptor) {
            return (__bridge_transfer id)CFRetain(oldDescriptor);
        }
        CFDictionarySetValue(storage, (__bridge const void *)rawClass, (__bridge const void *)newDescriptor);
        return newDescriptor;
    });
}

+ (void)invalidateDescriptor:(XZObjcClassDescriptor *)descriptor {
    if (descriptor.superDescriptor == nil) {
        return;
    }
    if (!descriptor.isValid) {
        return;
    }
    
    descriptor = withStorage(^id(const CFMutableDictionaryRef storage) {
        if (!descriptor.isValid) {
            return nil;
        }
        descriptor.isValid = NO;

        Class const rawClass = descriptor.raw;
        CFDictionaryRemoveValue(storage, (__bridge const void *)rawClass);
        
        return descriptor;
    });
    
    if (descriptor) {
        [NSNotificationCenter.defaultCenter postNotificationName:XZObjcClassDidChangeNotification object:descriptor];
    }
}

+ (void)invalidateForClass:(Class)rawClass {
    if (!object_isClass(rawClass)) {
        return;
    }
    
    XZObjcClassDescriptor *descriptor = withStorage(^id(const CFMutableDictionaryRef storage) {
        CFTypeRef const value = CFDictionaryGetValue(storage, (__bridge const void *)rawClass);
        if (value == NULL) {
            return nil;
        }
        return (__bridge_transfer id)CFRetain(value);
    });
    
    if (descriptor) {
        [self invalidateDescriptor:descriptor];
    }
}



@end
