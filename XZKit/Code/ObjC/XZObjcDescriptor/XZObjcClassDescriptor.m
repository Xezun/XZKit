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

@interface XZObjcClassDescriptor ()

@end

@implementation XZObjcClassDescriptor

- (instancetype)initWithClass:(nonnull Class)aClass {
    self = [super init];
    if (self) {
        _raw = aClass;
        _super = [XZObjcClassDescriptor descriptorForClass:[aClass superclass]];
        _name = NSStringFromClass(aClass);
        _type = [XZObjcTypeDescriptor descriptorForTypeEncoding:@encode(Class)];
        _ivars = @{};
        _methods = @{};
        _properties = @{};
        
        _needsUpdate = (_super != Nil);
        [self updateIfNeeded];
    }
    return self;
}

- (void)updateIfNeeded {
    if (!_needsUpdate) {
        return;
    }
    _needsUpdate = NO;
    
    Class const aClass = self.raw;
    
    unsigned int methodCount = 0;
    Method *methods = class_copyMethodList(aClass, &methodCount);
    if (methods && methodCount > 0) {
        NSMutableDictionary *descriptors = [NSMutableDictionary dictionaryWithCapacity:methodCount];
        for (unsigned int i = 0; i < methodCount; i++) {
            XZObjcMethodDescriptor *descriptor = [XZObjcMethodDescriptor descriptorForMethod:methods[i]];
            if (descriptor && descriptor.name) {
                descriptors[descriptor.name] = descriptor;
            }
        }
        free(methods);
        methods = NULL;
        
        _methods = descriptors;
    } else if (_methods.count > 0) {
        _methods = @{};
    }

    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(aClass, &propertyCount);
    if (properties && propertyCount > 0) {
        NSMutableDictionary *descriptors = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
        for (unsigned int i = 0; i < propertyCount; i++) {
            XZObjcPropertyDescriptor *descriptor = [XZObjcPropertyDescriptor descriptorForProperty:properties[i] forClass:aClass];
            if (descriptor) {
                descriptors[descriptor.name] = descriptor;
            }
        }
        free(properties);
        properties = NULL;
        
        _properties = descriptors;
    } else if (_properties.count > 0) {
        _properties = @{};
    }

    unsigned int ivarCount = 0;
    Ivar *ivars = class_copyIvarList(aClass, &ivarCount);
    if (ivars && ivarCount > 0) {
        NSMutableDictionary * const descriptors = [NSMutableDictionary dictionaryWithCapacity:ivarCount];
        for (unsigned int i = 0; i < ivarCount; i++) {
            XZObjcIvarDescriptor *descriptor = [XZObjcIvarDescriptor descriptorForIvar:ivars[i]];
            if (descriptor && descriptor.name) {
                descriptors[descriptor.name] = descriptor;
            }
        }
        free(ivars);
        ivars = NULL;
        
        _ivars = descriptors;
    } else if (_ivars.count > 0) {
        _ivars = @{};
    }
}

- (void)setNeedsUpdate {
    _needsUpdate = (_super != nil);
}

+ (instancetype)descriptorForClass:(Class)aClass {
    if (!object_isClass(aClass)) {
        return nil;
    }
    NSAssert(object_isClass(aClass), @"参数必须为 Class 对象");
    
    static const void * const _descriptor = &_descriptor;
    XZObjcClassDescriptor *descriptor = objc_getAssociatedObject(aClass, _descriptor);
    if (descriptor) {
        return descriptor;
    }
    descriptor = [[XZObjcClassDescriptor alloc] initWithClass:aClass];
    objc_setAssociatedObject(aClass, _descriptor, descriptor, OBJC_ASSOCIATION_RETAIN);
    return descriptor;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, name: %@, type: %@, ivars: %@, properties: %@, methods: %@>", NSStringFromClass(self.class), self, self.name, self.type, self.ivars, self.properties, self.methods];
}

@end
