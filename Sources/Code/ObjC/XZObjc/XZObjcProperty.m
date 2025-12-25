//
//  XZObjcProperty.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcProperty.h"
#import "XZObjcIvar.h"

@implementation XZObjcProperty

+ (instancetype)propertyForProperty:(objc_property_t)rawProperty forClass:(Class)aClass {
    if (!rawProperty) {
        return nil;
    }

    const char * const name = property_getName(rawProperty);

    if (name == nil || strlen(name) == 0) {
        return nil;
    }

    XZStdcModifiers modifiers = kNilOptions;
    XZObjcIvar *_ivar = nil;
    SEL _getter = nil;
    SEL _setter = nil;
    const char *typeEncoding = NULL;
    
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(rawProperty, &attrCount);

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
                        _ivar = [XZObjcIvar ivarForIvar:ivar];
                    }
                }
                break;
            }

            case 'R': {
                modifiers |= XZStdcModifierReadonly;
                break;
            }

            case 'C': {
                modifiers |= XZStdcModifierCopy;
                break;
            }

            case '&': {
                modifiers |= XZStdcModifierRetain;
                break;
            }

            case 'N': {
                modifiers |= XZStdcModifierNonatomic;
                break;
            }

            case 'D': {
                modifiers |= XZStdcModifierDynamic;
                break;
            }

            case 'W': {
                modifiers |= XZStdcModifierWeak;
                break;
            }

            case 'G': {
                modifiers |= XZStdcModifierGetter;

                if (attrValue) {
                    _getter = sel_getUid(attrValue);
                }
                break;
            }

            case 'S': {
                modifiers |= XZStdcModifierSetter;

                if (attrValue) {
                    _setter = sel_getUid(attrValue);
                }
                break;
            }

            default:
                break;
        }
    }
    
    XZObjcType *_type = [XZObjcType typeWithEncoding:typeEncoding modifiers:modifiers];
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

    if (!_setter && !(modifiers & XZStdcModifierReadonly)) {
        NSString *setterName = [NSString stringWithFormat:@"set%c%s:", toupper(name[0]), name + 1];
        _setter = NSSelectorFromString(setterName);
    }
    
    NSString *_name = [NSString stringWithCString:name encoding:(NSASCIIStringEncoding)];
    return [[self alloc] initWithProperty:rawProperty name:_name type:_type ivar:_ivar getter:_getter setter:_setter];
}

- (instancetype)initWithProperty:(objc_property_t)property name:(NSString *)name type:(XZObjcType *)type ivar:(XZObjcIvar *)ivar getter:(SEL)getter setter:(SEL)setter {
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
