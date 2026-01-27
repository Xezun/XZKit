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

- (instancetype)initWithClass:(nonnull Class)aClass {
    self = [super init];
    if (self) {
        _raw = aClass;
        _isValid = YES;
        _name = NSStringFromClass(aClass);
        _type = [XZObjcType typeForType:(XZStdcTypeClass)];
        
        // 不处理基类（没有超类的类）。
        if (class_getSuperclass(aClass)) {
            {
                NSDictionary *ivars = nil;
                
                unsigned int ivarCount = 0;
                Ivar *list = class_copyIvarList(aClass, &ivarCount);
                if (ivarCount > 0) {
                    ivars = [NSMutableDictionary dictionaryWithCapacity:ivarCount];
                    for (unsigned int i = 0; i < ivarCount; i++) {
                        XZObjcIvar *ivar = [XZObjcIvar ivarWithIvar:list[i]];
                        if (ivar) {
                            ((NSMutableDictionary *)ivars)[ivar.name] = ivar;
                        }
                    }
                }
                free(list);
                list = NULL;
                
                _ivars = ivars ?: @{};
            }
            
            {
                NSDictionary *methods = nil;
                
                unsigned int methodCount = 0;
                Method *list = class_copyMethodList(aClass, &methodCount);
                if (methodCount > 0) {
                    methods = [NSMutableDictionary dictionaryWithCapacity:methodCount];
                    for (unsigned int i = 0; i < methodCount; i++) {
                        XZObjcMethod *method = [XZObjcMethod methodWithMethod:list[i]];
                        if (method) {
                            ((NSMutableDictionary *)methods)[method.name] = method;
                        }
                    }
                }
                free(list);
                list = NULL;
                
                _methods = methods ?: @{};
            }
            
            {
                NSDictionary *properties = nil;
                
                unsigned int propertyCount = 0;
                objc_property_t *list = class_copyPropertyList(aClass, &propertyCount);
                if (propertyCount > 0) {
                    properties = [NSMutableDictionary dictionaryWithCapacity:propertyCount];
                    for (unsigned int i = 0; i < propertyCount; i++) {
                        XZObjcProperty *property = [XZObjcProperty propertyWithProperty:list[i] class:aClass];
                        if (property) {
                            ((NSMutableDictionary *)properties)[property.name] = property;
                        }
                    }
                }
                free(list);
                list = NULL;
                
                _properties = properties ?: @{};
            }
        } else {
            _ivars = @{};
            _methods = @{};
            _properties = @{};
        }
    }
    return self;
}

- (XZObjcClass *)superClass {
    return [XZObjcClass classForClass:class_getSuperclass(_raw)];
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
    if (self.superClass == nil) {
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
