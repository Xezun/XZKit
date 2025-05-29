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

- (void)sendActionWithValue:(id)value forKey:(XZMocoaKey)key sender:(id)sender {
    switch (_count) {
        case -1: {
            _handler(sender, _target, value, key);
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
                    void * const pointer = [(NSValue *)value pointerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, void *))objc_msgSend)(_target, _action, pointer);
                            break;
                        case 2:
                            ((void (*)(id, SEL, void *, id))objc_msgSend)(_target, _action, pointer, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, void *, id, XZMocoaKey))objc_msgSend)(_target, _action, pointer, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeChar: {
                    char const charValue = [value charValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, char))objc_msgSend)(_target, _action, charValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, char, id))objc_msgSend)(_target, _action, charValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, char, id, XZMocoaKey))objc_msgSend)(_target, _action, charValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnsignedChar: {
                    unsigned char const ucharValue = [value unsignedCharValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, unsigned char))objc_msgSend)(_target, _action, ucharValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, unsigned char, id))objc_msgSend)(_target, _action, ucharValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, unsigned char, id, XZMocoaKey))objc_msgSend)(_target, _action, ucharValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeInt: {
                    int const intValue = [value intValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, int))objc_msgSend)(_target, _action, intValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, int, id))objc_msgSend)(_target, _action, intValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, int, id, XZMocoaKey))objc_msgSend)(_target, _action, intValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnsignedInt: {
                    unsigned int const uintValue = [value unsignedIntValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, unsigned int))objc_msgSend)(_target, _action, uintValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, unsigned int, id))objc_msgSend)(_target, _action, uintValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, unsigned int, id, XZMocoaKey))objc_msgSend)(_target, _action, uintValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeShort: {
                    short const shortValue = [value shortValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, short))objc_msgSend)(_target, _action, shortValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, short, id))objc_msgSend)(_target, _action, shortValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, short, id, XZMocoaKey))objc_msgSend)(_target, _action, shortValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnsignedShort: {
                    unsigned short const ushortValue = [value unsignedShortValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, unsigned short))objc_msgSend)(_target, _action, ushortValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, unsigned short, id))objc_msgSend)(_target, _action, ushortValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, unsigned short, id, XZMocoaKey))objc_msgSend)(_target, _action, ushortValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeLong: {
                    long const longValue = [value longValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, long))objc_msgSend)(_target, _action, longValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, long, id))objc_msgSend)(_target, _action, longValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, long, id, XZMocoaKey))objc_msgSend)(_target, _action, longValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnsignedLong: {
                    unsigned long const ulongValue = [value unsignedLongValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, unsigned long))objc_msgSend)(_target, _action, ulongValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, unsigned long, id))objc_msgSend)(_target, _action, ulongValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, unsigned long, id, XZMocoaKey))objc_msgSend)(_target, _action, ulongValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeLongLong: {
                    long long const longlongValue = [value longLongValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, long long))objc_msgSend)(_target, _action, longlongValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, long long, id))objc_msgSend)(_target, _action, longlongValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, long long, id, XZMocoaKey))objc_msgSend)(_target, _action, longlongValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeUnsignedLongLong: {
                    unsigned long long const ulonglongValue = [value unsignedLongLongValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, unsigned long long))objc_msgSend)(_target, _action, ulonglongValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, unsigned long long, id))objc_msgSend)(_target, _action, ulonglongValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, unsigned long long, id, XZMocoaKey))objc_msgSend)(_target, _action, ulonglongValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeFloat: {
                    float const floatValue = [value floatValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, float))objc_msgSend)(_target, _action, floatValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, float, id))objc_msgSend)(_target, _action, floatValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, float, id, XZMocoaKey))objc_msgSend)(_target, _action, floatValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeDouble: {
                    double const doubleValue = [value doubleValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, double))objc_msgSend)(_target, _action, doubleValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, double, id))objc_msgSend)(_target, _action, doubleValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, double, id, XZMocoaKey))objc_msgSend)(_target, _action, doubleValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeLongDouble: {
                    long double const longDoubleValue = [value doubleValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, long double))objc_msgSend)(_target, _action, longDoubleValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, long double, id))objc_msgSend)(_target, _action, longDoubleValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, long double, id, XZMocoaKey))objc_msgSend)(_target, _action, longDoubleValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeBool: {
                    BOOL const boolValue = [value boolValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, BOOL))objc_msgSend)(_target, _action, boolValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, BOOL, id))objc_msgSend)(_target, _action, boolValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, BOOL, id, XZMocoaKey))objc_msgSend)(_target, _action, boolValue, key, sender);
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
                    char * const stringValue = (char *)[(NSValue *)value pointerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, char *))objc_msgSend)(_target, _action, stringValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, char *, id))objc_msgSend)(_target, _action, stringValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, char *, id, XZMocoaKey))objc_msgSend)(_target, _action, stringValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeSEL: {
                    SEL const selectorValue = (SEL)[(NSValue *)value pointerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, SEL))objc_msgSend)(_target, _action, selectorValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, SEL, id))objc_msgSend)(_target, _action, selectorValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, SEL, id, XZMocoaKey))objc_msgSend)(_target, _action, selectorValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypePointer: {
                    void * const pointerValue = [(NSValue *)value pointerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, void *))objc_msgSend)(_target, _action, pointerValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, void *, id))objc_msgSend)(_target, _action, pointerValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, void *, id, XZMocoaKey))objc_msgSend)(_target, _action, pointerValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeArray: {
                    void * const arrayValue = [(NSValue *)value pointerValue];
                    switch (_count) {
                        case 1:
                            ((void (*)(id, SEL, void *))objc_msgSend)(_target, _action, arrayValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, void *, id))objc_msgSend)(_target, _action, arrayValue, key);
                            break;
                        case 3:
                            ((void (*)(id, SEL, void *, id, XZMocoaKey))objc_msgSend)(_target, _action, arrayValue, key, sender);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZObjcTypeBitField:
                case XZObjcTypeUnion:
                case XZObjcTypeStruct: {
                    #pragma pack(push)
                    #pragma pack(1)
                    typedef struct { UInt8 a; }                 xz_size_t_1;
                    typedef struct { UInt8 a; xz_size_t_1 b; }  xz_size_t_2;
                    typedef struct { UInt8 a; xz_size_t_2 b; }  xz_size_t_3;
                    typedef struct { UInt8 a; xz_size_t_3 b; }  xz_size_t_4;
                    typedef struct { UInt8 a; xz_size_t_4 b; }  xz_size_t_5;
                    typedef struct { UInt8 a; xz_size_t_5 b; }  xz_size_t_6;
                    typedef struct { UInt8 a; xz_size_t_6 b; }  xz_size_t_7;
                    typedef struct { UInt8 a; xz_size_t_7 b; }  xz_size_t_8;
                    typedef struct { UInt8 a; xz_size_t_8 b; }  xz_size_t_9;
                    typedef struct { UInt8 a; xz_size_t_9 b; }  xz_size_t_10;
                    typedef struct { UInt8 a; xz_size_t_10 b; } xz_size_t_11;
                    typedef struct { UInt8 a; xz_size_t_11 b; } xz_size_t_12;
                    typedef struct { UInt8 a; xz_size_t_12 b; } xz_size_t_13;
                    typedef struct { UInt8 a; xz_size_t_13 b; } xz_size_t_14;
                    typedef struct { UInt8 a; xz_size_t_14 b; } xz_size_t_15;
                    typedef struct { UInt8 a; xz_size_t_15 b; } xz_size_t_16;
                    typedef struct { UInt8 a; xz_size_t_16 b; } xz_size_t_17;
                    typedef struct { UInt8 a; xz_size_t_17 b; } xz_size_t_18;
                    typedef struct { UInt8 a; xz_size_t_18 b; } xz_size_t_19;
                    typedef struct { UInt8 a; xz_size_t_19 b; } xz_size_t_20;
                    typedef struct { UInt8 a; xz_size_t_20 b; } xz_size_t_21;
                    typedef struct { UInt8 a; xz_size_t_21 b; } xz_size_t_22;
                    typedef struct { UInt8 a; xz_size_t_22 b; } xz_size_t_23;
                    typedef struct { UInt8 a; xz_size_t_23 b; } xz_size_t_24;
                    typedef struct { UInt8 a; xz_size_t_24 b; } xz_size_t_25;
                    typedef struct { UInt8 a; xz_size_t_25 b; } xz_size_t_26;
                    typedef struct { UInt8 a; xz_size_t_26 b; } xz_size_t_27;
                    typedef struct { UInt8 a; xz_size_t_27 b; } xz_size_t_28;
                    typedef struct { UInt8 a; xz_size_t_28 b; } xz_size_t_29;
                    typedef struct { UInt8 a; xz_size_t_29 b; } xz_size_t_30;
                    typedef struct { UInt8 a; xz_size_t_30 b; } xz_size_t_31;
                    typedef struct { UInt8 a; xz_size_t_31 b; } xz_size_t_32;
                    typedef struct { UInt8 a; xz_size_t_32 b; } xz_size_t_33;
                    typedef struct { UInt8 a; xz_size_t_33 b; } xz_size_t_34;
                    typedef struct { UInt8 a; xz_size_t_34 b; } xz_size_t_35;
                    typedef struct { UInt8 a; xz_size_t_35 b; } xz_size_t_36;
                    typedef struct { UInt8 a; xz_size_t_36 b; } xz_size_t_37;
                    typedef struct { UInt8 a; xz_size_t_37 b; } xz_size_t_38;
                    typedef struct { UInt8 a; xz_size_t_38 b; } xz_size_t_39;
                    typedef struct { UInt8 a; xz_size_t_39 b; } xz_size_t_40;
                    typedef struct { UInt8 a; xz_size_t_40 b; } xz_size_t_41;
                    typedef struct { UInt8 a; xz_size_t_41 b; } xz_size_t_42;
                    typedef struct { UInt8 a; xz_size_t_42 b; } xz_size_t_43;
                    typedef struct { UInt8 a; xz_size_t_43 b; } xz_size_t_44;
                    typedef struct { UInt8 a; xz_size_t_44 b; } xz_size_t_45;
                    typedef struct { UInt8 a; xz_size_t_45 b; } xz_size_t_46;
                    typedef struct { UInt8 a; xz_size_t_46 b; } xz_size_t_47;
                    typedef struct { UInt8 a; xz_size_t_47 b; } xz_size_t_48;
                    typedef struct { UInt8 a; xz_size_t_48 b; } xz_size_t_49;
                    typedef struct { UInt8 a; xz_size_t_49 b; } xz_size_t_50;
                    typedef struct { UInt8 a; xz_size_t_50 b; } xz_size_t_51;
                    typedef struct { UInt8 a; xz_size_t_51 b; } xz_size_t_52;
                    typedef struct { UInt8 a; xz_size_t_52 b; } xz_size_t_53;
                    typedef struct { UInt8 a; xz_size_t_53 b; } xz_size_t_54;
                    typedef struct { UInt8 a; xz_size_t_54 b; } xz_size_t_55;
                    typedef struct { UInt8 a; xz_size_t_55 b; } xz_size_t_56;
                    typedef struct { UInt8 a; xz_size_t_56 b; } xz_size_t_57;
                    typedef struct { UInt8 a; xz_size_t_57 b; } xz_size_t_58;
                    typedef struct { UInt8 a; xz_size_t_58 b; } xz_size_t_59;
                    typedef struct { UInt8 a; xz_size_t_59 b; } xz_size_t_60;
                    typedef struct { UInt8 a; xz_size_t_60 b; } xz_size_t_61;
                    typedef struct { UInt8 a; xz_size_t_61 b; } xz_size_t_62;
                    typedef struct { UInt8 a; xz_size_t_62 b; } xz_size_t_63;
                    typedef struct { UInt8 a; xz_size_t_63 b; } xz_size_t_64;
                    #pragma pack(pop)
                    
                    #define case_type_size(_size_) \
                    case _size_: { \
                        __NSX_PASTE__(xz_size_t_, _size_) cValue = {0}; \
                        [(NSValue *)value getValue:&value size:_size_]; \
                        switch (_count) { \
                            case 1: \
                                ((void (*)(id, SEL, __NSX_PASTE__(xz_size_t_, _size_)))objc_msgSend)(_target, _action, cValue); \
                                break; \
                            case 2: \
                                ((void (*)(id, SEL, __NSX_PASTE__(xz_size_t_, _size_), id))objc_msgSend)(_target, _action, cValue, key); \
                                break; \
                            case 3: \
                                ((void (*)(id, SEL, __NSX_PASTE__(xz_size_t_, _size_), id, XZMocoaKey))objc_msgSend)(_target, _action, cValue, key, sender); \
                                break; \
                            default: \
                                break; \
                        } \
                        break; \
                    }
                    switch (_type.size) {
                        case_type_size(1);
                        case_type_size(2);
                        case_type_size(3);
                        case_type_size(4);
                        case_type_size(5);
                        case_type_size(6);
                        case_type_size(7);
                        case_type_size(8);
                        case_type_size(9);
                        case_type_size(10);
                        case_type_size(11);
                        case_type_size(12);
                        case_type_size(13);
                        case_type_size(14);
                        case_type_size(15);
                        case_type_size(16);
                        case_type_size(17);
                        case_type_size(18);
                        case_type_size(19);
                        case_type_size(20);
                        case_type_size(31);
                        case_type_size(32);
                        case_type_size(33);
                        case_type_size(34);
                        case_type_size(35);
                        case_type_size(36);
                        case_type_size(37);
                        case_type_size(38);
                        case_type_size(39);
                        case_type_size(40);
                        case_type_size(41);
                        case_type_size(42);
                        case_type_size(43);
                        case_type_size(44);
                        case_type_size(45);
                        case_type_size(46);
                        case_type_size(47);
                        case_type_size(48);
                        case_type_size(49);
                        case_type_size(50);
                        case_type_size(51);
                        case_type_size(52);
                        case_type_size(53);
                        case_type_size(54);
                        case_type_size(55);
                        case_type_size(56);
                        case_type_size(57);
                        case_type_size(58);
                        case_type_size(59);
                        case_type_size(60);
                        case_type_size(61);
                        case_type_size(62);
                        case_type_size(63);
                        case_type_size(64);
                        default:
                            break;
                    }
                    #undef case_type_size
                    
                    break;
                }
                case XZObjcTypeClass:
                case XZObjcTypeObject:
                default: {
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
