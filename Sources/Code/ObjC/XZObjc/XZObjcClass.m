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

@interface XZObjcClass () {
    NSDictionary<NSString *,XZObjcIvar *> * _Nullable _ivars;
    NSDictionary<NSString *,XZObjcMethod *> * _Nullable _methods;
    NSDictionary<NSString *,XZObjcProperty *> * _Nullable _properties;
}

@property (atomic, readwrite) BOOL isValid;

@end

@implementation XZObjcClass

- (instancetype)initWithClass:(nonnull Class)aClass {
    self = [super init];
    if (self) {
        _raw = aClass;
        _isValid = YES;
        _name = NSStringFromClass(aClass);
        _type = [XZObjcType typeForType:(XZStdcTypeClass)];
        
        // 不处理基类（没有超类的类）。
        if (class_getSuperclass(aClass) == Nil) {
            _ivars = @{};
            _methods = @{};
            _properties = @{};
        }
    }
    return self;
}

- (XZObjcClass *)superClass {
    return [XZObjcClass classWithClass:class_getSuperclass(_raw)];
}

- (NSDictionary<NSString *,XZObjcIvar *> *)ivars {
    if (_ivars) {
        return _ivars;
    }
    
    unsigned int ivarCount = 0;
    Ivar *list = class_copyIvarList(_raw, &ivarCount);
    if (ivarCount > 0) {
        _ivars = [NSMutableDictionary dictionaryWithCapacity:ivarCount];
        for (unsigned int i = 0; i < ivarCount; i++) {
            XZObjcIvar *ivar = [XZObjcIvar ivarWithIvar:list[i]];
            if (ivar) {
                ((NSMutableDictionary *)_ivars)[ivar.name] = ivar;
            }
        }
    }
    free(list);
    list = NULL;
    
    return _ivars;
}

- (NSDictionary<NSString *,XZObjcProperty *> *)properties {
    if (_properties) {
        return _properties;
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *list = class_copyPropertyList(_raw, &propertyCount);
    if (propertyCount > 0) {
        _properties = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
        for (unsigned int i = 0; i < propertyCount; i++) {
            XZObjcProperty *property = [XZObjcProperty propertyWithProperty:list[i] class:_raw];
            if (property) {
                ((NSMutableDictionary *)_properties)[property.name] = property;
            }
        }
    }
    free(list);
    list = NULL;
    
    return _properties;
}

- (NSDictionary<NSString *,XZObjcMethod *> *)methods {
    if (_methods) {
        return _methods;
    }
    
    unsigned int methodCount = 0;
    Method *list = class_copyMethodList(_raw, &methodCount);
    if (methodCount > 0) {
        _methods = [NSMutableDictionary dictionaryWithCapacity:methodCount];
        for (unsigned int i = 0; i < methodCount; i++) {
            XZObjcMethod *method = [XZObjcMethod methodWithMethod:list[i]];
            if (method) {
                ((NSMutableDictionary *)_methods)[method.name] = method;
            }
        }
    }
    free(list);
    list = NULL;
    
    return _methods;
}

- (NSString *)description {
    NSString *ivars = nil;
    if (self.ivars.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.ivars enumerateKeysAndObjectsUsingBlock:^(NSString *key, XZObjcIvar *obj, BOOL *stop) {
            [stringM appendFormat:@"        %@ %@, \n", obj.type.name, key];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 3, 1)];
        [stringM appendString:@"    ]"];
        ivars = stringM;
    }
    
    NSString *properties = nil;
    if (self.properties.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.properties enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, XZObjcProperty * _Nonnull obj, BOOL * _Nonnull stop) {
            [stringM appendFormat:@"        %@ %@, \n", obj.type.name, key];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 3, 1)];
        [stringM appendString:@"    ]"];
        properties = stringM;
    }
    
    NSString *methods = nil;
    if (self.methods.count > 0) {
        NSMutableString *stringM = [[NSMutableString alloc] initWithString:@"[\n"];
        [self.methods enumerateKeysAndObjectsUsingBlock:^(NSString *methodName, XZObjcMethod * _Nonnull obj, BOOL * _Nonnull stop) {
            NSRange range = NSMakeRange(0, methodName.length);
            if (obj.arguments.count > 2) {
                for (NSInteger i = 2; i < obj.arguments.count; i++) {
                    range = [methodName rangeOfString:@":" options:kNilOptions range:range];
                    NSString *argument = [NSString stringWithFormat:@":(%@) ", obj.arguments[i].name];
                    methodName = [methodName stringByReplacingCharactersInRange:range withString:argument];
                    range.location += 1;
                    range.length = methodName.length - range.location;
                }
                methodName = [methodName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
            }
            [stringM appendFormat:@"        -(%@)%@, \n", obj.type.name, methodName];
        }];
        [stringM deleteCharactersInRange:NSMakeRange(stringM.length - 3, 1)];
        [stringM appendString:@"    ]"];
        methods = stringM;
    }
    
    NSString *type = self.type.name;
    
    return [NSString stringWithFormat:@"<\n"
            "    %@: %p, \n"
            "    name: %@, \n"
            "    type: %@, \n"
            "    ivars: %@, \n"
            "    properties: %@, \n"
            "    methods: %@ \n"
            ">", self.class, self, self.name, type, ivars, properties, methods];
}

+ (instancetype)classWithClass:(Class)class {
    if (!object_isClass(class)) {
        return nil;
    }
    return [[XZObjcClass alloc] initWithClass:class];
}

@end
