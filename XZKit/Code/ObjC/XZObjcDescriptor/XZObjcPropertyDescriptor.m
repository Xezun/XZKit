//
//  XZObjcPropertyDescriptor.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcPropertyDescriptor.h"
#import "XZObjcIvarDescriptor.h"

@implementation XZObjcPropertyDescriptor

+ (instancetype)descriptorWithProperty:(objc_property_t)property ofClass:(Class)aClass {
    if (!property) {
        return nil;
    }

    const char * const name = property_getName(property);

    if (name == nil || strlen(name) == 0) {
        return nil;
    }

    XZObjcQualifiers qualifiers = kNilOptions;
    XZObjcIvarDescriptor *_ivar = nil;
    SEL _getter = nil;
    SEL _setter = nil;
    const char *typeEncoding = NULL;
    
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);

    for (unsigned int i = 0; i < attrCount; i++) {
        const char * const attrValue = attrs[i].value;
        if (attrValue == NULL) {
            continue;
        }
        const char * const attrName  = attrs[i].name;
        if (attrName == NULL) {
            continue;
        }
        switch (attrName[0]) {
            case 'T': { // Type encoding
                typeEncoding = attrValue;
                break;
            }

            case 'V': { // Instance variable
                if (attrValue) {
                    Ivar ivar = class_getInstanceVariable(aClass, attrValue);
                    if (ivar) {
                        _ivar = [XZObjcIvarDescriptor descriptorWithIvar:ivar];
                    }
                }
                break;
            }

            case 'R': {
                qualifiers |= XZObjcQualifierReadonly;
                break;
            }

            case 'C': {
                qualifiers |= XZObjcQualifierCopy;
                break;
            }

            case '&': {
                qualifiers |= XZObjcQualifierRetain;
                break;
            }

            case 'N': {
                qualifiers |= XZObjcQualifierNonatomic;
                break;
            }

            case 'D': {
                qualifiers |= XZObjcQualifierDynamic;
                break;
            }

            case 'W': {
                qualifiers |= XZObjcQualifierWeak;
                break;
            }

            case 'G': {
                qualifiers |= XZObjcQualifierGetter;

                if (attrValue) {
                    _getter = sel_getUid(attrValue);
                }
                break;
            }

            case 'S': {
                qualifiers |= XZObjcQualifierSetter;

                if (attrValue) {
                    _setter = sel_getUid(attrValue);
                }
                break;
            }

            default:
                break;
        }
    }
    
    XZObjcTypeDescriptor *_type = [XZObjcTypeDescriptor descriptorForObjcType:typeEncoding qualifiers:qualifiers];
    if (_type == nil) {
        return nil;
    }
    
    if (attrs) {
        free(attrs);
        attrs = NULL;
    }

    if (!_getter) {
        _getter = sel_getUid(name);

        if (_getter == nil) {
            return nil;
        }
    }

    if (!_setter && !(qualifiers & XZObjcQualifierReadonly)) {
        NSString *setterName = [NSString stringWithFormat:@"set%c%s:", toupper(name[0]), name + 1];
        _setter = NSSelectorFromString(setterName);
    }
    
    NSString *_name = [NSString stringWithCString:name encoding:(NSASCIIStringEncoding)];
    return [[self alloc] initWithProperty:property name:_name type:_type ivar:_ivar getter:_getter setter:_setter];
}

- (instancetype)initWithProperty:(objc_property_t)property name:(NSString *)name type:(XZObjcTypeDescriptor *)type ivar:(XZObjcIvarDescriptor *)ivar getter:(SEL)getter setter:(SEL)setter {
    self = [super init];

    if (self != nil) {
        _raw = property;
        _name = name;
        _type = type;
        _ivar = ivar;
        _getter = getter;
        _setter = setter;
    }

    return self;
}

- (NSString *)description {
    NSString * const className = NSStringFromClass(self.class);
    NSString * const type   = [NSString stringWithFormat:@"<%p: %@>", self.type, ((id)self.type.subtype ?: self.type.name)];
    NSString * const getter = NSStringFromSelector(self.getter);
    NSString * const setter = (self.setter ? NSStringFromSelector(self.setter) : nil);
    return [NSString stringWithFormat:@"<%@: %p, name: %@, type: %@, ivar: %p, getter: %@, setter: %@>", className, self, self.name, type, self.ivar, getter, setter];
}

@end
