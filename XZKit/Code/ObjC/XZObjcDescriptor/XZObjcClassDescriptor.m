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

NSNotificationName const XZObjcClassNeedsUpdateNotification = @"XZObjcClassNeedsUpdateNotification";
NSString *         const XZObjcClassUpdateTypeUserInfoKey   = @"XZObjcClassUpdateTypeUserInfoKey";
NSString *         const XZObjcClassUpdateTypeIvars         = @"XZObjcClassUpdateTypeIvars";
NSString *         const XZObjcClassUpdateTypeMethods       = @"XZObjcClassUpdateTypeMethods";
NSString *         const XZObjcClassUpdateTypeProperties    = @"XZObjcClassUpdateTypeProperties";

@interface XZObjcClassDescriptor () {
    NSDictionary<NSString *,XZObjcIvarDescriptor *> * _Nullable _ivars;
    NSDictionary<NSString *,XZObjcMethodDescriptor *> * _Nullable _methods;
    NSDictionary<NSString *,XZObjcPropertyDescriptor *> * _Nullable _properties;
}

@end

@implementation XZObjcClassDescriptor

- (instancetype)initWithClass:(nonnull Class)aClass {
    self = [super init];
    if (self) {
        _raw = aClass;
        _super = [XZObjcClassDescriptor descriptorForClass:[aClass superclass]];
        _name = NSStringFromClass(aClass);
        _type = [XZObjcTypeDescriptor descriptorWithObjcType:@encode(Class)];
        _ivars = _super ? nil : @{};
        _methods = _super ? nil : @{};
        _properties = _super ? nil : @{};
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
    if (_super) {
        _ivars = nil;
        [NSNotificationCenter.defaultCenter postNotificationName:XZObjcClassNeedsUpdateNotification object:self userInfo:@{
            XZObjcClassUpdateTypeUserInfoKey: XZObjcClassUpdateTypeIvars
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
    if (_super) {
        _methods = nil;
        [NSNotificationCenter.defaultCenter postNotificationName:XZObjcClassNeedsUpdateNotification object:self userInfo:@{
            XZObjcClassUpdateTypeUserInfoKey: XZObjcClassUpdateTypeMethods
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
            XZObjcPropertyDescriptor *descriptor = [XZObjcPropertyDescriptor descriptorForProperty:list[i] forClass:raw];
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
    if (_super) {
        _properties = nil;
        [NSNotificationCenter.defaultCenter postNotificationName:XZObjcClassNeedsUpdateNotification object:self userInfo:@{
            XZObjcClassUpdateTypeUserInfoKey: XZObjcClassUpdateTypeProperties
        }];
    }
}

+ (instancetype)descriptorForClass:(Class)aClass {
    if (!object_isClass(aClass)) {
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
    XZObjcClassDescriptor *descriptor = CFDictionaryGetValue(_storage, (__bridge const void *)aClass);
    dispatch_semaphore_signal(_lock);
    
    if (descriptor) {
        return descriptor;
    }
    descriptor = [[XZObjcClassDescriptor alloc] initWithClass:aClass];
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    XZObjcClassDescriptor *descriptor2 = CFDictionaryGetValue(_storage, (__bridge const void *)aClass);
    if (descriptor2 == nil) {
        CFDictionarySetValue(_storage, (__bridge const void *)aClass, (__bridge const void *)descriptor);
    } else {
        descriptor = descriptor2;
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
