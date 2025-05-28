//
//  XZMocoaTargetAction.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import "XZMocoaTargetAction.h"
#import "XZMocoaViewModel.h"
@import ObjectiveC;
@import XZObjcDescriptor;

struct Foobar {
    NSInteger a0;
    NSInteger a1;
    NSInteger a2;
    NSInteger a3;
    NSInteger a4;
    NSInteger a5;
    NSInteger a6;
    NSInteger a7;
    NSInteger a8;
    NSInteger a9;
};

@implementation XZMocoaTargetAction {
    NSInteger _count;
    XZObjcTypeDescriptor *_type;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        Method const method = class_getInstanceMethod(object_getClass(target), action);
        XZObjcMethodDescriptor * const descriptor = [XZObjcMethodDescriptor descriptorWithMethod:method];
        
        _count   = descriptor.argumentsTypes.count - 2;
        NSAssert(_count <= 3, @"[XZMocoa] 通过视图模型的 %@ 方法绑定的方法，最多支持三个参数", NSStringFromSelector(@selector(addTarget:action:forKey:)));
        _type    = (_count >= 1 ? descriptor.argumentsTypes[2] : nil);
        _target  = target;
        _action  = action;
        _handler = nil;
    }
    return self;
}

- (instancetype)initWithTarget:(id)target handler:(XZMocoaTargetHandler)handler {
    self = [super init];
    if (self) {
        _count   = -1;
        _type    = nil;
        _target  = target;
        _action  = nil;
        _handler = [handler copy];
    }
    return self;
}

- (void)sendActionForKey:(XZMocoaKey)key value:(id const)object sender:(id)sender {
    switch (_count) {
        case -1: {
            _handler(sender, _target, object, key);
            break;
        }
        case 0: {
            ((void (*)(id, SEL))objc_msgSend)(_target, _action);
            break;
        }
        case 1:
        case 2:
        case 3: {
            switch (_type.type) {
                case XZObjcTypeUnknown: {
                    void * const value = [(NSValue *)object pointerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, void *))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, void *, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, void *, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeChar: {
                    char const value = [object charValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, char))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, char, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, char, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnsignedChar: {
                    unsigned char const value = [object unsignedCharValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, unsigned char))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, unsigned char, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, unsigned char, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeInt: {
                    int const value = [object intValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, int))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, int, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, int, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnsignedInt: {
                    unsigned int const value = [object unsignedIntValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, unsigned int))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, unsigned int, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, unsigned int, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeShort: {
                    short const value = [object shortValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, short))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, short, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, short, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnsignedShort: {
                    unsigned short const value = [object unsignedShortValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, unsigned short))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, unsigned short, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, unsigned short, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeLong: {
                    long const value = [object longValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, long))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, long, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, long, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnsignedLong: {
                    unsigned long const value = [object unsignedLongValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, unsigned long))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, unsigned long, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, unsigned long, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeLongLong: {
                    long long const value = [object longLongValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, long long))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, long long, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, long long, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnsignedLongLong: {
                    unsigned long long const value = [object unsignedLongLongValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, unsigned long long))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, unsigned long long, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, unsigned long long, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeFloat: {
                    float const value = [object floatValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, float))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, float, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, float, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeDouble: {
                    double const value = [object doubleValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, double))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, double, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, double, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeLongDouble: {
                    long double const value = [object doubleValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, long double))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, long double, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, long double, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeBool: {
                    BOOL const value = [object boolValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, BOOL))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, BOOL, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, BOOL, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeVoid: {
                    break;
                }
                case XZObjcTypeString: {
                    char * const value = (char *)[(NSValue *)object pointerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, char *))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, char *, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, char *, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeClass: {
                    Class const value = (Class)(object);
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, Class))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, Class, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, Class, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeSEL: {
                    SEL const value = (SEL)[(NSValue *)object pointerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, SEL))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, SEL, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, SEL, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypePointer: {
                    void * const value = [(NSValue *)object pointerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, void *))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, void *, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, void *, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeBitField: {
                    NSInteger const value = [object integerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, NSInteger))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, NSInteger, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, NSInteger, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeArray: {
                    void * const value = [(NSValue *)object pointerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, void *))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, void *, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, void *, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnion: {
                    struct Foobar value;
                    [(NSValue *)object getValue:&value size:_type.size];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, struct Foobar))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, struct Foobar, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, struct Foobar, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeStruct: {
                    struct Foobar value;
                    [(NSValue *)object getValue:&value size:_type.size];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, struct Foobar))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, struct Foobar, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, struct Foobar, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeObject: {
                    id const value = object;
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, id))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, id, id))objc_msgSend)(_target, _action, value, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, id, XZMocoaKey))objc_msgSend)(_target, _action, value, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                default: {
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, id))objc_msgSend)(_target, _action, object);
                            break;
                        case 2:
                            ((void (*)(id, SEL, id, id))objc_msgSend)(_target, _action, object, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, id, XZMocoaKey))objc_msgSend)(_target, _action, object, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
            }
            break;
        }
        default: {
            // 超过 3 个无法处理
            break;
        }
    }
}

@end
