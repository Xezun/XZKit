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
@import XZExtensions;

@implementation XZMocoaTargetAction {
    /// action 的参数数量，不包括 self 和 SEL
    NSInteger _numberOfArguments;
    /// value 参数的值类型。
    XZObjcTypeDescriptor *_valueArgumentType;
}

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        _target  = target;
        _action  = action;
        
        Method const method = class_getInstanceMethod(object_getClass(target), action);
        
        _numberOfArguments = method_getNumberOfArguments(method);
        if (_numberOfArguments < 2) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"参数错误" userInfo:nil];
        }
        if (_numberOfArguments > 5) {
            @throw [NSException exceptionWithName:NSGenericException reason:@"视图模型 target-action 机制最多支持三个参数" userInfo:nil];
        }
        _numberOfArguments -= 2;
        
        switch (_numberOfArguments) {
            case 0: {
                _valueArgumentType = nil;
                break;
            }
            case 1: {
                const char *encoding = method_copyArgumentType(method, 2);
                _valueArgumentType = [XZObjcTypeDescriptor descriptorForObjcType:encoding];
                free((void *)encoding);
                break;
            }
            case 2: {
                const char *encoding = method_copyArgumentType(method, 3);
                _valueArgumentType = [XZObjcTypeDescriptor descriptorForObjcType:encoding];
                free((void *)encoding);
                break;
            }
            case 3: {
                const char *encoding = method_copyArgumentType(method, 4);
                _valueArgumentType = [XZObjcTypeDescriptor descriptorForObjcType:encoding];
                free((void *)encoding);
                break;
            }
            default: {
                _valueArgumentType = nil;
                break;
            }
        }
        
        _handler = nil;
    }
    return self;
}

- (instancetype)initWithTarget:(id)target handler:(XZMocoaTargetHandler)handler {
    self = [super init];
    if (self) {
        _numberOfArguments = -1;
        _valueArgumentType = nil;
        _target  = target;
        _action  = nil;
        _handler = [handler copy];
    }
    return self;
}

- (void)sendActionWithValue:(id)value forKey:(XZMocoaKey)key sender:(id)sender {
    switch (_numberOfArguments) {
        case 0: {
            ((void (*)(id, SEL))objc_msgSend)(_target, _action);
            break;
        }
        case 1:
        case 2:
        case 3: {
            switch (_valueArgumentType.type) {
                case XZObjcTypeUnknown: {
                    void *pointerValue = NULL;
                    [(NSValue *)value getValue:&pointerValue size:sizeof(void *)];
                    switch (_numberOfArguments) {
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
                case XZObjcTypeChar: {
                    char charValue = 0;
                    // 使用 getValue:size: 而不是 charValue 取值，是为了避免没有使用 NSNumber 而是直接使用 NSValue 封装的标量值
                    [(NSValue *)value getValue:&charValue size:sizeof(char)];
                    switch (_numberOfArguments) {
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
                    unsigned char ucharValue = 0;
                    [(NSValue *)value getValue:&ucharValue size:sizeof(unsigned char)];
                    switch (_numberOfArguments) {
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
                    int intValue = 0;
                    [(NSValue *)value getValue:&intValue size:sizeof(int)];
                    switch (_numberOfArguments) {
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
                    unsigned int uintValue = 0;
                    [(NSValue *)value getValue:&uintValue size:sizeof(unsigned int)];
                    switch (_numberOfArguments) {
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
                    short shortValue = 0;
                    [(NSValue *)value getValue:&shortValue size:sizeof(short)];
                    switch (_numberOfArguments) {
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
                    unsigned short ushortValue = 0;
                    [(NSValue *)value getValue:&ushortValue size:sizeof(unsigned short)];
                    switch (_numberOfArguments) {
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
                    long longValue = 0;
                    [(NSValue *)value getValue:&longValue size:sizeof(long)];
                    switch (_numberOfArguments) {
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
                    unsigned long ulongValue = 0;
                    [(NSValue *)value getValue:&ulongValue size:sizeof(unsigned long)];
                    switch (_numberOfArguments) {
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
                    long long longlongValue = 0;
                    [(NSValue *)value getValue:&longlongValue size:sizeof(long long)];
                    switch (_numberOfArguments) {
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
                    unsigned long long ulonglongValue = 0;
                    [(NSValue *)value getValue:&ulonglongValue size:sizeof(unsigned long long)];
                    switch (_numberOfArguments) {
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
                    float floatValue = 0;
                    [(NSValue *)value getValue:&floatValue size:sizeof(float)];
                    switch (_numberOfArguments) {
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
                    double doubleValue = 0;
                    [(NSValue *)value getValue:&doubleValue size:sizeof(double)];
                    switch (_numberOfArguments) {
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
                    long double longDoubleValue = 0;
                    [(NSValue *)value getValue:&longDoubleValue size:sizeof(long double)];
                    switch (_numberOfArguments) {
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
                    BOOL boolValue = 0;
                    [(NSValue *)value getValue:&boolValue size:sizeof(BOOL)];
                    switch (_numberOfArguments) {
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
                    char * stringValue = 0;
                    [(NSValue *)value getValue:&stringValue size:sizeof(char *)];
                    switch (_numberOfArguments) {
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
                    SEL selectorValue = 0;
                    [(NSValue *)value getValue:&selectorValue size:sizeof(SEL)];
                    switch (_numberOfArguments) {
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
                    void * pointerValue = 0;
                    [(NSValue *)value getValue:&pointerValue size:sizeof(void *)];
                    switch (_numberOfArguments) {
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
                    void * arrayValue = 0;
                    [(NSValue *)value getValue:&arrayValue size:sizeof(void *)];
                    switch (_numberOfArguments) {
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
                case XZObjcTypeUnion: {
                    // 共用体的情况比较复杂，暂不支持：
                    // 1. NSInvocation 不支持带自定义共用体参数的方法。
                    // 2. 不能简单地直接使用共用体的最大数据类型，因为数据在函数参数传递的过程中，会发生改变。
                    //
                    // 在 testUnionConvertion 单元测试中，假如有类型为 {int, double} 的共用体，
                    // a. 将共用体存储到 NSValue 中
                    // b. 用 double 取出来
                    // c. 由于在然后将 double 赋值给参数类型为 double 的函数
                    // d. 使用 double 类型通过 objc_msgSend 发送消息
                    // 即使函数实际参数是原始的共用体，也无法复原原始的共用体，因为 double 内存布局为 1 符号位，11 指数位，52 小数位
                    // 如果存储 int 值，那么实际只填充了前12位，那么这个 double 会因为没有小数位，而被认为实际是 0
                    size_t const size = _valueArgumentType.size;
                    if (size < 2) {
                        UInt8 bitValue = 0;
                        [(NSValue *)value getValue:&bitValue size:sizeof(UInt8)];
                        switch (_numberOfArguments) {
                            case 1:
                                ((void (*)(id, SEL, UInt8))objc_msgSend)(_target, _action, bitValue);
                                break;
                            case 2:
                                ((void (*)(id, SEL, UInt8, id))objc_msgSend)(_target, _action, bitValue, key);
                                break;
                            case 3:
                                ((void (*)(id, SEL, UInt8, id, XZMocoaKey))objc_msgSend)(_target, _action, bitValue, key, sender);
                                break;
                            default:
                                break;
                        }
                    } else if (size < 4) {
                        UInt16 bitValue = 0;
                        [(NSValue *)value getValue:&bitValue size:sizeof(UInt16)];
                        switch (_numberOfArguments) {
                            case 1:
                                ((void (*)(id, SEL, UInt16))objc_msgSend)(_target, _action, bitValue);
                                break;
                            case 2:
                                ((void (*)(id, SEL, UInt16, id))objc_msgSend)(_target, _action, bitValue, key);
                                break;
                            case 3:
                                ((void (*)(id, SEL, UInt16, id, XZMocoaKey))objc_msgSend)(_target, _action, bitValue, key, sender);
                                break;
                            default:
                                break;
                        }
                    } else if (size < 8) {
                        UInt32 bitValue = 0;
                        [(NSValue *)value getValue:&bitValue size:sizeof(UInt32)];
                        switch (_numberOfArguments) {
                            case 1:
                                ((void (*)(id, SEL, UInt32))objc_msgSend)(_target, _action, bitValue);
                                break;
                            case 2:
                                ((void (*)(id, SEL, UInt32, id))objc_msgSend)(_target, _action, bitValue, key);
                                break;
                            case 3:
                                ((void (*)(id, SEL, UInt32, id, XZMocoaKey))objc_msgSend)(_target, _action, bitValue, key, sender);
                                break;
                            default:
                                break;
                        }
                    } else if (size < 16) {
                        UInt64 bitValue = 0;
                        [(NSValue *)value getValue:&bitValue size:sizeof(UInt64)];
                        switch (_numberOfArguments) {
                            case 1:
                                ((void (*)(id, SEL, UInt64))objc_msgSend)(_target, _action, bitValue);
                                break;
                            case 2:
                                ((void (*)(id, SEL, UInt64, id))objc_msgSend)(_target, _action, bitValue, key);
                                break;
                            case 3:
                                ((void (*)(id, SEL, UInt64, id, XZMocoaKey))objc_msgSend)(_target, _action, bitValue, key, sender);
                                break;
                            default:
                                break;
                        }
                    } else if (size < 32) {
                        typedef struct { UInt64 a; UInt64 b; } XZ_UInt128;
                        XZ_UInt128 bitValue = {0};
                        [(NSValue *)value getValue:&bitValue size:sizeof(XZ_UInt128)];
                        switch (_numberOfArguments) {
                            case 1:
                                ((void (*)(id, SEL, XZ_UInt128))objc_msgSend)(_target, _action, bitValue);
                                break;
                            case 2:
                                ((void (*)(id, SEL, XZ_UInt128, id))objc_msgSend)(_target, _action, bitValue, key);
                                break;
                            case 3:
                                ((void (*)(id, SEL, XZ_UInt128, id, XZMocoaKey))objc_msgSend)(_target, _action, bitValue, key, sender);
                                break;
                            default:
                                break;
                        }
                    } else if (size < 64) {
                        typedef struct { UInt64 a; UInt64 b; UInt64 c; UInt64 d; } XZ_UInt256;
                        XZ_UInt256 bitValue = {0};
                        [(NSValue *)value getValue:&bitValue size:sizeof(XZ_UInt256)];
                        switch (_numberOfArguments) {
                            case 1:
                                ((void (*)(id, SEL, XZ_UInt256))objc_msgSend)(_target, _action, bitValue);
                                break;
                            case 2:
                                ((void (*)(id, SEL, XZ_UInt256, id))objc_msgSend)(_target, _action, bitValue, key);
                                break;
                            case 3:
                                ((void (*)(id, SEL, XZ_UInt256, id, XZMocoaKey))objc_msgSend)(_target, _action, bitValue, key, sender);
                                break;
                            default:
                                break;
                        }
                    } else if (size < 128) {
                        typedef struct { UInt64 a; UInt64 b; UInt64 c; UInt64 d; UInt64 e; UInt64 f; UInt64 g; UInt64 h; } XZ_UInt512;
                        XZ_UInt512 bitValue = {0};
                        [(NSValue *)value getValue:&bitValue size:sizeof(XZ_UInt512)];
                        switch (_numberOfArguments) {
                            case 1:
                                ((void (*)(id, SEL, XZ_UInt512))objc_msgSend)(_target, _action, bitValue);
                                break;
                            case 2:
                                ((void (*)(id, SEL, XZ_UInt512, id))objc_msgSend)(_target, _action, bitValue, key);
                                break;
                            case 3:
                                ((void (*)(id, SEL, XZ_UInt512, id, XZMocoaKey))objc_msgSend)(_target, _action, bitValue, key, sender);
                                break;
                            default:
                                break;
                        }
                    } else {
                        typedef struct {
                            UInt64 a; UInt64 b; UInt64 c; UInt64 d; UInt64 e; UInt64 f; UInt64 g; UInt64 h;
                            UInt64 i; UInt64 j; UInt64 k; UInt64 l; UInt64 m; UInt64 n; UInt64 o; UInt64 p;
                        } XZ_UInt1024;
                        XZ_UInt1024 bitValue = {0};
                        [(NSValue *)value getValue:&bitValue size:sizeof(XZ_UInt1024)];
                        switch (_numberOfArguments) {
                            case 1:
                                ((void (*)(id, SEL, XZ_UInt1024))objc_msgSend)(_target, _action, bitValue);
                                break;
                            case 2:
                                ((void (*)(id, SEL, XZ_UInt1024, id))objc_msgSend)(_target, _action, bitValue, key);
                                break;
                            case 3:
                                ((void (*)(id, SEL, XZ_UInt1024, id, XZMocoaKey))objc_msgSend)(_target, _action, bitValue, key, sender);
                                break;
                            default:
                                break;
                        }
                    }
                    break;
                }
                case XZObjcTypeStruct: {
                    void *buffer = calloc(_valueArgumentType.size, 1);
                    [(NSValue *)value getValue:buffer size:_valueArgumentType.size];
                    
                    Method              const method     = class_getInstanceMethod(object_getClass(_target), _action);
                    NSMethodSignature * const signature  = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
                    NSInvocation *      const invocation = [NSInvocation invocationWithMethodSignature:signature];
                    
                    invocation.target   = _target;
                    invocation.selector = _action;
                    for (int i = 0; i < _numberOfArguments; i++) {
                        switch (i) {
                            case 0:
                                [invocation setArgument:buffer atIndex:2];
                                break;
                            case 1:
                                [invocation setArgument:(__bridge void *)key atIndex:3];
                                break;
                            case 2:
                                [invocation setArgument:(__bridge void *)sender atIndex:4];
                                break;
                            default:
                                break;
                        }
                    }
                    [invocation invoke];
                    
                    free(buffer);
                    break;
                }
                case XZObjcTypeClass:
                case XZObjcTypeObject:
                default: {
                    switch (_numberOfArguments) {
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
