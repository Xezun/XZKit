//
//  XZKeyedObject.m
//  XZKeyedObject
//
//  Created by M. X. Z. on 2016/10/26.
//  Copyright © 2016年 mlibai. All rights reserved.
//

#import "XZKeyedObject.h"


/**
 XZKeyedObject 类实现它的属性
 
 @param aClass XZKeyedObject类和子类
 @param descriptor 属性描述结构体 XZPropertyDescriptorRef
 */
static void ko_implement_dynamic_property(Class aClass, XZPropertyDescriptorRef descriptor);

/**
 XZKeyedObject 创建一个遵循了指定协议的子类
 
 @param aProtocol 协议
 @return XZKeyedObject 子类
 */
static Class ko_subclassing_by_conforming_to_protocol(Class superclass, Protocol *aProtocol);

static NSMutableDictionary *ko_info_layz_load(XZKeyedObject *keyedObject);
static NSMutableDictionary *ko_info_if_loaded(XZKeyedObject *keyedObject);
static void ko_info_setter(XZKeyedObject *keyedObject, NSMutableDictionary *info);

// 归档和绑定 info 用的 key 。
static NSString *const kXZKeyedObjectInfoDictionaryKey = @"kXZKeyedObjectInfoDictionaryKey";

@implementation XZKeyedObject

+ (void)initialize {
    unsigned int property_count = 0;
    objc_property_t *property_list = class_copyPropertyList([self class], &property_count);
    for (int i = 0; i < property_count; i ++) {
        XZPropertyDescriptorRef descriptor = XZPropertyDescriptorCreate(property_list[i]);
        ko_implement_dynamic_property(self, descriptor);
        XZPropertyDescriptorRelease(descriptor);
    }
    free(property_list);
}

+ (instancetype)keyedObjectWithDictionary:(NSDictionary *)keyedValues {
    return [self keyedObjectWithDictionary:keyedValues keyMap:nil];
}

+ (instancetype)keyedObjectWithDictionary:(NSDictionary *)keyedValues keyMap:(NSDictionary<NSString *,NSString *> *)keyMap {
    return [[self alloc] initWithDictionary:keyedValues keyMap:keyMap];
}

- (instancetype)init {
    return [self initWithDictionary:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)keyedValues {
    return [self initWithDictionary:keyedValues keyMap:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)keyedValues keyMap:(NSDictionary<NSString *,NSString *> *)keyMap {
    self = [super init];
    if (self != nil) {
        if (keyedValues != nil) {
            NSMutableDictionary *dictM = keyedValues.mutableCopy;
            [keyMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull property, BOOL * _Nonnull stop) {
                dictM[property] = dictM[key];
                [dictM removeObjectForKey:key];
            }];
            ko_info_setter(self, dictM);
        }
    }
    return self;
}

#pragma mark - <NSCoding>

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        NSMutableDictionary *dictM = [aDecoder decodeObjectOfClass:[NSMutableDictionary class] forKey:kXZKeyedObjectInfoDictionaryKey];
        ko_info_setter(self, dictM);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSMutableDictionary *dictM = ko_info_if_loaded(self);
    if (dictM != nil) {
        [aCoder encodeObject:dictM forKey:kXZKeyedObjectInfoDictionaryKey];
    }
}

#pragma mark - <NSCopying>

- (id)copyWithZone:(NSZone *)zone {
    return [(XZKeyedObject *)[[self class] alloc] initWithDictionary:ko_info_if_loaded(self)];
}

#pragma mark - Public Methods

- (id)objectForKey:(NSString *)aKey {
    return [self objectForKeyedSubscript:aKey];
}

- (id)objectForKeyedSubscript:(NSString *)key {
    return [ko_info_if_loaded(self) objectForKeyedSubscript:key];
}

- (void)setObject:(id)anObject forKey:(NSString *)aKey {
    [self setObject:anObject forKeyedSubscript:aKey];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString *)key {
    [ko_info_layz_load(self) setObject:obj forKeyedSubscript:key];
}

- (void)setValuesForKeysWithDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    [self addEntriesFromDictionary:keyedValues];
}

- (void)addEntriesFromDictionary:(NSDictionary<NSString *,id> *)keyedValues {
    [ko_info_layz_load(self) addEntriesFromDictionary:keyedValues];
}

#pragma mark - setters & getters

- (NSDictionary *)keyedValues {
    return [ko_info_if_loaded(self) copy];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, keyedValues: %@>", NSStringFromClass([self class]), self, [self keyedValues]];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([NSMutableDictionary instancesRespondToSelector:aSelector]) {
        return ko_info_if_loaded(self);
    }
    return [super forwardingTargetForSelector:aSelector];
}

@end

@implementation XZKeyedObject (XZExtendedKeyedObject)

+ (Class)subclassingByConformingToProtocol:(Protocol *)aProtocol {
    return ko_subclassing_by_conforming_to_protocol([self class], aProtocol);
}

+ (XZKeyedObject *)keyedObjectByConformingToProtocol:(Protocol *)aProtocol {
    return [[ko_subclassing_by_conforming_to_protocol([self class], aProtocol) alloc] init];
}

+ (XZKeyedObject *)keyedObjectByConformingToProtocol:(Protocol *)aProtocol keyedValues:(NSDictionary<NSString *,id> *)keyedVales {
    return [self keyedObjectByConformingToProtocol:aProtocol keyedValues:keyedVales keyMap:nil];
}

+ (XZKeyedObject *)keyedObjectByConformingToProtocol:(Protocol *)aProtocol keyedValues:(NSDictionary<NSString *,id> *)keyedVales keyMap:(NSDictionary<NSString *,NSString *> *)keyMap {
    return [(XZKeyedObject *)[ko_subclassing_by_conforming_to_protocol([self class], aProtocol) alloc] initWithDictionary:keyedVales keyMap:keyMap];
}

@end





static id ko_property_getter_block_maker(XZPropertyDescriptorRef descriptor);
static id ko_property_setter_block_maker(XZPropertyDescriptorRef descriptor);

static void ko_implement_dynamic_property(Class aClass, XZPropertyDescriptorRef descriptor) {
    SEL getter = sel_registerName(descriptor->getter);
    if (!class_respondsToSelector(aClass, getter)) {
        id getter_block = ko_property_getter_block_maker(descriptor);
        if (getter_block != nil) {
            IMP getterIMP = imp_implementationWithBlock(getter_block);
            char *method_types = calloc(strlen(descriptor->type_encoding) + 3, sizeof(char));
            strcpy(method_types, descriptor->type_encoding);
            strcat(method_types, "@:");
            class_addMethod(aClass, getter, getterIMP, method_types);
            free(method_types);
        }
    }
    if (!descriptor->isReadonly) {
        SEL setter = sel_registerName(descriptor->setter);
        if (!class_respondsToSelector(aClass, setter)) {
            id setter_block = ko_property_setter_block_maker(descriptor);
            if (setter_block != nil) {
                IMP setterIMP = imp_implementationWithBlock(setter_block);
                char *method_types = calloc(strlen(descriptor->type_encoding) + 4, sizeof(char));
                strcpy(method_types, "v@:");
                strcat(method_types, descriptor->type_encoding);
                class_addMethod(aClass, setter, setterIMP, method_types);
                free(method_types);
            }
        }
    }
}

static id ko_property_getter_block_maker(XZPropertyDescriptorRef descriptor) {
    NSString *propertyName = [NSString stringWithUTF8String:descriptor->name];
    switch (descriptor->dataTypeDescriptor->type) {
        case XZDataType_char:
        case XZDataType_unsigned_char: {
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                char cValue = 0;
                [value getValue:&cValue];
                return cValue;
            });
        }
        case XZDataType_int:
        case XZDataType_unsigned_int: {
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                int cValue = 0;
                [value getValue:&cValue];
                return cValue;
            });
        }
        case XZDataType_short:
        case XZDataType_unsigned_short: {
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                short cValue = 0;
                [value getValue:&cValue];
                return cValue;
            });
        }
        case XZDataType_long:
        case XZDataType_unsigned_long: {
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                long cValue = 0;
                [value getValue:&cValue];
                return cValue;
            });
        }
        case XZDataType_long_long:
        case XZDataType_unsigned_long_long: {
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                long long cValue = 0;
                [value getValue:&cValue];
                return cValue;
            });
        }
        case XZDataType_float: {
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                float cValue = 0;
                [value getValue:&cValue];
                return cValue;
            });
        }
        case XZDataType_double: {
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                double cValue = 0;
                [value getValue:&cValue];
                return cValue;
            });
        }
        case XZDataType_bool: {
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                BOOL cValue = 0;
                [value getValue:&cValue];
                return cValue;
            });
        }
        case XZDataType_void: // void meens return nothing. not getter
            return (^(XZKeyedObject *keyedObj) {
                return;
            });;
        case XZDataType_char_v: { // c string
            return (^(XZKeyedObject *keyedObj) {
                NSString *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                return value.UTF8String;
            });
        }
        case XZDataType_id: {
            if (descriptor->isCopy) {
                return (^(XZKeyedObject *keyedObj){
                    return [[ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName] copy];
                });
            } else {
                return (^(XZKeyedObject *keyedObj){
                    return [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                });
            }
        }
        case XZDataType_Class:
            return (^(XZKeyedObject *keyedObj){
                Class class = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                return class;
            });
        case XZDataType_SEL:
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                SEL cValue = NULL;
                [value getValue:&cValue];
                return cValue;
            });
            // structure
        case XZDataType_CGRect:
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                CGRect cValue = CGRectZero;
                [value getValue:&cValue];
                return cValue;
            });
        case XZDataType_CGSize:
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                CGSize cValue = CGSizeZero;
                [value getValue:&cValue];
                return cValue;
            });
        case XZDataType_CGPoint:
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                CGPoint cValue = CGPointZero;
                [value getValue:&cValue];
                return cValue;
            });
        case XZDataType_CGVector:
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                CGVector cValue = CGVectorMake(0, 0);
                [value getValue:&cValue];
                return cValue;
            });
        case XZDataType_UIOffset:
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                UIOffset cValue = UIOffsetZero;
                [value getValue:&cValue];
                return cValue;
            });
        case XZDataType_UIEdgeInsets:
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                UIEdgeInsets cValue = UIEdgeInsetsZero;
                [value getValue:&cValue];
                return cValue;
            });
        case XZDataType_CGAffineTransform:
            return (^(XZKeyedObject *keyedObj){
                NSValue *value = [ko_info_layz_load(keyedObj) objectForKeyedSubscript:propertyName];
                CGAffineTransform cValue = CGAffineTransformIdentity;
                [value getValue:&cValue];
                return cValue;
            });
        default: {
            return (^(XZKeyedObject *keyedObj) {
                NSLog(@"XZKeyedObject：属性 %@ 的数据类型不被支持。", propertyName);
                return NULL;
            });
        }
            break;
    }
}

static id ko_property_setter_block_maker(XZPropertyDescriptorRef descriptor) {
    NSString *propertyName = [NSString stringWithUTF8String:descriptor->name];
    switch (descriptor->dataTypeDescriptor->type) {
        case XZDataType_char:
        case XZDataType_unsigned_char:
            return (^(XZKeyedObject *keyedObject, char cValue) {
                NSNumber *objValue = [NSNumber numberWithChar:cValue];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_int:
        case XZDataType_unsigned_int:
            return (^(XZKeyedObject *keyedObject, int cValue) {
                NSNumber *objValue = [NSNumber numberWithInt:cValue];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_short:
        case XZDataType_unsigned_short:
            return (^(XZKeyedObject *keyedObject, short cValue) {
                NSNumber *objValue = [NSNumber numberWithShort:cValue];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_long:
        case XZDataType_unsigned_long:
            return (^(XZKeyedObject *keyedObject, long cValue) {
                NSNumber *objValue = [NSNumber numberWithLong:cValue];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_long_long:
        case XZDataType_unsigned_long_long:
            return (^(XZKeyedObject *keyedObject, long long cValue) {
                NSNumber *objValue = [NSNumber numberWithLongLong:cValue];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_float:
            return (^(XZKeyedObject *keyedObject, float cValue) {
                NSNumber *objValue = [NSNumber numberWithFloat:cValue];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_double:
            return (^(XZKeyedObject *keyedObject, double cValue) {
                NSNumber *objValue = [NSNumber numberWithDouble:cValue];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_bool:
            return (^(XZKeyedObject *keyedObject, BOOL cValue) {
                NSNumber *objValue = [NSNumber numberWithBool:cValue];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_void:
            return nil;
        case XZDataType_char_v:
            return (^(XZKeyedObject *keyedObject, char *cValue) {
                NSString *objValue = [NSString stringWithUTF8String:cValue];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_id: {
            if (descriptor->isCopy) {
                return (^(XZKeyedObject *keyedObject, id objValue) {
                    [ko_info_layz_load(keyedObject) setObject:[objValue copy] forKeyedSubscript:propertyName];
                });
            } else {
                return (^(XZKeyedObject *keyedObject, id objValue) {
                    [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
                });
            }
        }
        case XZDataType_Class:
            return (^(XZKeyedObject *keyedObject, Class objValue) {
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_SEL:
            return (^(XZKeyedObject *keyedObject, SEL cValue) {
                NSValue *objValue = [NSValue valueWithPointer:cValue];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
            // structure
        case XZDataType_CGRect:
            return (^(XZKeyedObject *keyedObject, CGRect cValue) {
                NSValue *objValue =  [[NSValue alloc] initWithBytes:&cValue objCType:@encode(CGRect)];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_CGSize:
            return (^(XZKeyedObject *keyedObject, CGSize cValue) {
                NSValue *objValue = [[NSValue alloc] initWithBytes:&cValue objCType:@encode(CGSize)];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_CGPoint:
            return (^(XZKeyedObject *keyedObject, CGPoint cValue) {
                NSValue *objValue = [[NSValue alloc] initWithBytes:&cValue objCType:@encode(CGPoint)];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_CGVector:
            return (^(XZKeyedObject *keyedObject, CGVector cValue) {
                NSValue *objValue = [[NSValue alloc] initWithBytes:&cValue objCType:@encode(CGVector)];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_UIOffset:
            return (^(XZKeyedObject *keyedObject, UIOffset cValue) {
                NSValue *objValue = [[NSValue alloc] initWithBytes:&cValue objCType:@encode(UIOffset)];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_UIEdgeInsets:
            return (^(XZKeyedObject *keyedObject, UIEdgeInsets cValue) {
                NSValue *objValue = [[NSValue alloc] initWithBytes:&cValue objCType:@encode(UIEdgeInsets)];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        case XZDataType_CGAffineTransform:
            return (^(XZKeyedObject *keyedObject, CGAffineTransform cValue) {
                NSValue *objValue = [[NSValue alloc] initWithBytes:&cValue objCType:@encode(CGAffineTransform)];
                [ko_info_layz_load(keyedObject) setObject:objValue forKeyedSubscript:propertyName];
            });
        default: {
            return (^(XZKeyedObject *keyedObject, void *value) {
                NSLog(@"XZKeyedObject：属性 %@ 的数据类型不被支持。", propertyName);
            });
            break;
        }
    }
}

static dispatch_queue_t ko_subclassing_queue() {
    static dispatch_queue_t queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.mlibai.XZKeyedObject.subclassing.queue", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

static const void * const ko_protocol_associated_class = &ko_protocol_associated_class;

static Class ko_create_subclass_for_protocol(Class superclass, const char *subclass_name, Protocol *aProtocol) {
    Class __block subclass = Nil;
    
    dispatch_sync(ko_subclassing_queue(), ^{
        subclass = objc_getAssociatedObject(aProtocol, ko_protocol_associated_class);
        if (subclass != Nil) {
            return;
        }
        
        subclass = objc_allocateClassPair(superclass, subclass_name, 0);
        
        if (subclass != Nil) {
            class_addProtocol(subclass, aProtocol);
            unsigned int properties_count = 0;
            objc_property_t *properties = protocol_copyPropertyList(aProtocol, &properties_count);
            for (int i = 0; i < properties_count; i ++) {
                objc_property_t property_t = properties[i];
                const char *property_name = property_getName(property_t);
                unsigned int attributes_count = 0;
                const objc_property_attribute_t *property_attributes = property_copyAttributeList(property_t, &attributes_count);
                class_addProperty(subclass, property_name, property_attributes, attributes_count);
                free((void *)property_attributes);
            }
            free(properties);
        }
    });
    
    return subclass;
}

static inline BOOL is_ko_subclass_and_conformed_protocol(Class subclass, Protocol *aProtocol) {
    return ([subclass isSubclassOfClass:[XZKeyedObject class]] && class_conformsToProtocol(subclass, aProtocol));
}

static Class ko_subclassing_by_conforming_to_protocol(Class superclass, Protocol *aProtocol) {
    Class __block subclass = objc_getAssociatedObject(aProtocol, ko_protocol_associated_class);
    if (subclass != Nil) {
        return subclass;
    }
    
    const char *const protocol_name = protocol_getName(aProtocol);
    subclass = objc_getClass(protocol_name);
    
    if (subclass != Nil) {
        if (is_ko_subclass_and_conformed_protocol(subclass, aProtocol)) {
            objc_setAssociatedObject(aProtocol, ko_protocol_associated_class, subclass, OBJC_ASSOCIATION_ASSIGN);
        } else { // if the class is not available, create...
            size_t const name_len = strlen(protocol_name);
            char *subclass_name = calloc(name_len + 6 + 1, sizeof(char));
            
            // create a valid name. {$PROTOCOL_NAME}+"_"+[0-9]{5}
            strcpy(subclass_name, protocol_name);
            subclass_name[name_len] = '_';
            
            size_t const start = name_len - 1 + 2;
            
            subclass_name[start] = '0';
            for (size_t i = 0, p = start; i < 100000; i++) {
                subclass = objc_getClass(subclass_name);
                if (subclass == nil) {
                    break;
                } else if (is_ko_subclass_and_conformed_protocol(subclass, aProtocol)) {
                    objc_setAssociatedObject(aProtocol, ko_protocol_associated_class, subclass, OBJC_ASSOCIATION_ASSIGN);
                    free(subclass_name);
                    return subclass;
                }
                
                size_t n = p;
                do {
                    if (subclass_name[n] < '9') { // 不需要进位
                        subclass_name[n] += 1;
                        break;
                    } else { // 需要进位
                        if (n > start) { //
                            subclass_name[n] = '0';
                            n -= 1;
                            continue;
                        }
                        subclass_name[start] = '1';
                        p += 1;
                        subclass_name[p] = '0';
                        break;
                    }
                } while (YES);
            }
            
            subclass = ko_create_subclass_for_protocol(superclass, subclass_name, aProtocol);
            objc_setAssociatedObject(aProtocol, ko_protocol_associated_class, subclass, OBJC_ASSOCIATION_ASSIGN);
            free((void *)subclass_name);
        }
        return subclass;
    }
    
    subclass = ko_create_subclass_for_protocol(superclass, protocol_name, aProtocol);
    objc_setAssociatedObject(aProtocol, ko_protocol_associated_class, subclass, OBJC_ASSOCIATION_ASSIGN);
    return subclass;
}

static NSMutableDictionary *ko_info_layz_load(XZKeyedObject *keyedObject) {
    NSMutableDictionary *dictM = objc_getAssociatedObject(keyedObject, &kXZKeyedObjectInfoDictionaryKey);
    if (dictM != nil) {
        return dictM;
    }
    dictM = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(keyedObject, &kXZKeyedObjectInfoDictionaryKey, dictM, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return dictM;
}


static NSMutableDictionary *ko_info_if_loaded(XZKeyedObject *keyedObject) {
    return objc_getAssociatedObject(keyedObject, &kXZKeyedObjectInfoDictionaryKey);
}

static void ko_info_setter(XZKeyedObject *keyedObject, NSMutableDictionary *info) {
    objc_setAssociatedObject(keyedObject, &kXZKeyedObjectInfoDictionaryKey, info, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
