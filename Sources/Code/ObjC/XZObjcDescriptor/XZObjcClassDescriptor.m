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

NSNotificationName const XZObjcClassDidUpdateNotification = @"XZObjcClassDidUpdateNotification";
NSString *         const XZObjcClassUpdatesUserInfoKey    = @"XZObjcClassUpdatesUserInfoKey";
NSString *         const XZObjcClassUpdateIvars           = @"XZObjcClassUpdateIvars";
NSString *         const XZObjcClassUpdateMethods         = @"XZObjcClassUpdateMethods";
NSString *         const XZObjcClassUpdateProperties      = @"XZObjcClassUpdateProperties";

@interface XZObjcClassDescriptor () {
    NSDictionary<NSString *,XZObjcIvarDescriptor *> * _Nullable _ivars;
    NSDictionary<NSString *,XZObjcMethodDescriptor *> * _Nullable _methods;
    NSDictionary<NSString *,XZObjcPropertyDescriptor *> * _Nullable _properties;
}

@end

@implementation XZObjcClassDescriptor

- (instancetype)initWithClass:(nonnull Class)rawClass {
    self = [super init];
    if (self) {
        _raw = rawClass;
        _superDescriptor = [XZObjcClassDescriptor descriptorForClass:[rawClass superclass]];
        _name = NSStringFromClass(rawClass);
        _type = [XZObjcTypeDescriptor descriptorForType:@encode(Class)];
        _ivars = _superDescriptor ? nil : @{};
        _methods = _superDescriptor ? nil : @{};
        _properties = _superDescriptor ? nil : @{};
    }
    return self;
}

- (NSDictionary<NSString *,XZObjcIvarDescriptor *> *)ivars {
    if (_ivars) {
        return _ivars;
    }
    
    unsigned int ivarCount = 0;
    Ivar *list = class_copyIvarList(self.raw, &ivarCount);
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
    return _ivars;
}

- (void)setNeedsUpdateIvars {
    if (_superDescriptor) {
        _ivars = nil;
        [NSNotificationCenter.defaultCenter postNotificationName:XZObjcClassDidUpdateNotification object:self userInfo:@{
            XZObjcClassUpdatesUserInfoKey: XZObjcClassUpdateIvars
        }];
    }
}

- (NSDictionary<NSString *,XZObjcMethodDescriptor *> *)methods {
    if (_methods) {
        return _methods;
    }
    unsigned int methodCount = 0;
    Method *list = class_copyMethodList(self.raw, &methodCount);
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
    return _methods;
}

- (void)setNeedsUpdateMethods {
    if (_superDescriptor) {
        _methods = nil;
        [NSNotificationCenter.defaultCenter postNotificationName:XZObjcClassDidUpdateNotification object:self userInfo:@{
            XZObjcClassUpdatesUserInfoKey: XZObjcClassUpdateMethods
        }];
    }
}

- (NSDictionary<NSString *,XZObjcPropertyDescriptor *> *)properties {
    if (_properties) {
        return _properties;
    }
    
    Class const raw = self.raw;
    
    unsigned int propertyCount = 0;
    objc_property_t *list = class_copyPropertyList(raw, &propertyCount);
    if (list && propertyCount > 0) {
        NSMutableDictionary *descriptors = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
        for (unsigned int i = 0; i < propertyCount; i++) {
            XZObjcPropertyDescriptor *descriptor = [XZObjcPropertyDescriptor descriptorForProperty:list[i] ofClass:raw];
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
    
    return _properties;
}

- (void)setNeedsUpdateProperties {
    if (_superDescriptor) {
        _properties = nil;
        [NSNotificationCenter.defaultCenter postNotificationName:XZObjcClassDidUpdateNotification object:self userInfo:@{
            XZObjcClassUpdatesUserInfoKey: XZObjcClassUpdateProperties
        }];
    }
}

+ (instancetype)descriptorForClass:(Class)rawClass {
    if (!object_isClass(rawClass)) {
        return nil;
    }
    
    static CFMutableDictionaryRef _storage = nil;
    
    static dispatch_semaphore_t _lock;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _lock = dispatch_semaphore_create(1);
        _storage = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    });
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    XZObjcClassDescriptor *descriptor = CFDictionaryGetValue(_storage, (__bridge const void *)rawClass);
    dispatch_semaphore_signal(_lock);
    
    if (descriptor) {
        return descriptor;
    }
    descriptor = [[XZObjcClassDescriptor alloc] initWithClass:rawClass];
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    XZObjcClassDescriptor *newDescriptor = CFDictionaryGetValue(_storage, (__bridge const void *)rawClass);
    if (newDescriptor == nil) {
        CFDictionarySetValue(_storage, (__bridge const void *)rawClass, (__bridge const void *)descriptor);
    } else {
        descriptor = newDescriptor;
    }
    dispatch_semaphore_signal(_lock);
    
    return descriptor;
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

@end
