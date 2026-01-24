//
//  XZObjcProperty.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcProperty.h"
#import "XZObjcIvar.h"

@implementation XZObjcProperty

+ (instancetype)propertyWithProperty:(objc_property_t)property class:(Class)aClass {
    if (!property) {
        return nil;
    }

    const char * const name = property_getName(property);

    if (name == nil || strlen(name) == 0) {
        return nil;
    }

    XZStdcModifiers _modifiers = kNilOptions;
    XZObjcIvar *    _ivar = nil;
    SEL             _getter = nil;
    SEL             _setter = nil;
    
    const char * typeEncoding = NULL;
    unsigned int attrCount;
    objc_property_attribute_t *attrLists = property_copyAttributeList(property, &attrCount);

    for (unsigned int i = 0; i < attrCount; i++) {
        const char * const attrValue = attrLists[i].value;
        if (attrValue == NULL) {
            continue;
        }
        const char * const attrName  = attrLists[i].name;
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
                        _ivar = [XZObjcIvar ivarWithIvar:ivar];
                    }
                }
                break;
            }

            case 'R': {
                _modifiers |= XZStdcModifierReadonly;
                break;
            }

            case 'C': {
                _modifiers |= XZStdcModifierCopy;
                break;
            }

            case '&': {
                _modifiers |= XZStdcModifierRetain;
                break;
            }

            case 'N': {
                _modifiers |= XZStdcModifierNonatomic;
                break;
            }

            case 'D': {
                _modifiers |= XZStdcModifierDynamic;
                break;
            }

            case 'W': {
                _modifiers |= XZStdcModifierWeak;
                break;
            }

            case 'G': {
                _modifiers |= XZStdcModifierGetter;

                if (attrValue) {
                    _getter = sel_getUid(attrValue);
                }
                break;
            }

            case 'S': {
                _modifiers |= XZStdcModifierSetter;

                if (attrValue) {
                    _setter = sel_getUid(attrValue);
                }
                break;
            }

            default:
                break;
        }
    }
    
    XZObjcType *_type = [XZObjcType typeForEncoding:typeEncoding];
    if (_type == nil) {
        return nil;
    }
    
    if (attrLists) {
        free(attrLists);
        attrLists = NULL;
    }

    if (!_getter) {
        _getter = sel_getUid(name);

        if (_getter == nil) {
            return nil;
        }
    }

    if (!_setter && !(_modifiers & XZStdcModifierReadonly)) {
        NSString *setterName = [NSString stringWithFormat:@"set%c%s:", toupper(name[0]), name + 1];
        _setter = NSSelectorFromString(setterName);
    }
    
    NSString *_name = [NSString stringWithCString:name encoding:(NSASCIIStringEncoding)];
    return [[self alloc] initWithProperty:property name:_name type:_type ivar:_ivar modifiers:_modifiers getter:_getter setter:_setter];
}

- (instancetype)initWithProperty:(objc_property_t)property name:(NSString *)name type:(XZObjcType *)type ivar:(XZObjcIvar *)ivar modifiers:(XZStdcModifiers)modifiers getter:(SEL)getter setter:(SEL)setter {
    self = [super init];
    if (self != nil) {
        _raw = property;
        _name = name;
        _type = type;
        _ivar = ivar;
        _modifiers = modifiers;
        _getter = getter;
        _setter = setter;
    }
    return self;
}

- (NSString *)description {
    NSString * const className = NSStringFromClass(self.class);
    NSString * const type   = [NSString stringWithFormat:@"<%p: %@>", self.type, ((id)self.type.classType ?: self.type.name)];
    NSString * const getter = NSStringFromSelector(self.getter);
    NSString * const setter = (self.setter ? NSStringFromSelector(self.setter) : nil);
    return [NSString stringWithFormat:@"<%@: %p, name: %@, type: %@, ivar: %p, getter: %@, setter: %@>", className, self, self.name, type, self.ivar, getter, setter];
}

@end
