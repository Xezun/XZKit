//
//  XZObjcProperty.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/26.
//

#import "XZObjcProperty.h"
#import "XZObjcType.h"
#import "XZObjcIvar.h"

@implementation XZObjcProperty

+ (instancetype)propertyWithProperty:(objc_property_t)property forClass:(Class)class {
    if (!property) {
        return nil;
    }

    const char * const name = property_getName(property);

    if (name == nil || strlen(name) == 0) {
        return nil;
    }
    
    XZObjcType *    _type = nil;
    XZObjcIvar *    _ivar = nil;
    SEL             _getter = NULL;
    SEL             _setter = NULL;
    XZStdcModifiers _modifiers = kNilOptions;
    
    unsigned int attributeCount;
    objc_property_attribute_t *attributeLists = property_copyAttributeList(property, &attributeCount);
    for (unsigned int i = 0; i < attributeCount; i++) {
        objc_property_attribute_t const attribute = attributeLists[i];
        switch (attribute.name[0]) {
            case 'T': { // Type encoding
                _type = [XZObjcType typeForEncoding:attribute.value];
                break;
            }

            case 'V': { // Instance variable
                if (attribute.value) {
                    Ivar ivar = class_getInstanceVariable(class, attribute.value);
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

                if (attribute.value) {
                    _getter = sel_getUid(attribute.value);
                }
                break;
            }

            case 'S': {
                _modifiers |= XZStdcModifierSetter;

                if (attribute.value) {
                    _setter = sel_getUid(attribute.value);
                }
                break;
            }

            default:
                break;
        }
    }
    free(attributeLists);
    attributeLists = NULL;
    
    if (_type == nil) {
        return nil;
    }
    
    if (_getter == NULL) {
        _getter = sel_getUid(name);

        if (_getter == NULL || !class_respondsToSelector(class, _getter)) {
            return nil;
        }
    }
    
    if (_setter == NULL) {
        if ((_modifiers & XZStdcModifierReadonly)) {
            // 只读属性
        } else {
            NSString *setterName = [NSString stringWithFormat:@"set%c%s:", toupper(name[0]), name + 1];
            _setter = NSSelectorFromString(setterName);
            if (_setter == NULL) {
                _modifiers |= XZStdcModifierReadonly;
            } else if (!class_respondsToSelector(class, _setter)) {
                _setter = NULL;
                _modifiers |= XZStdcModifierReadonly;
            }
        }
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
    NSString * const type   = self.type.name;
    NSString * const getter = NSStringFromSelector(self.getter);
    NSString * const setter = (self.setter ? NSStringFromSelector(self.setter) : nil);
    NSString * const modifiers = NSStringFromXZStdcModifiers(self.modifiers);
    return [NSString stringWithFormat:@"<%@: %p, { \n"
            "    name: %@, \n"
            "    type: %@, \n"
            "    ivar: %@, \n"
            "    getter: %@, \n"
            "    setter: %@, \n"
            "    modifiers: %@ \n"
            "}>", className, self, self.name, type, self.ivar.name, getter, setter, modifiers];
}

@end
