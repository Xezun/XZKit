//
//  XZMocoaTargetAction.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import "XZMocoaTargetAction.h"
#import "XZObjcType.h"
#import "XZMocoaViewModel.h"
@import ObjectiveC;

@implementation XZMocoaTargetAction {
    /// action 的参数数量，不包括 self 和 SEL
    NSInteger _numberOfArguments;
    /// value 参数的值类型。
    XZObjcType *_valueArgumentType;
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
                _valueArgumentType = [XZObjcType typeForEncoding:encoding];
                free((void *)encoding);
                break;
            }
            case 2: {
                const char *encoding = method_copyArgumentType(method, 3);
                _valueArgumentType = [XZObjcType typeForEncoding:encoding];
                free((void *)encoding);
                break;
            }
            case 3: {
                const char *encoding = method_copyArgumentType(method, 4);
                _valueArgumentType = [XZObjcType typeForEncoding:encoding];
                free((void *)encoding);
                break;
            }
            default: {
                _valueArgumentType = nil;
                break;
            }
        }
        
        // 共用体的情况比较复杂，暂不支持：
        // 1. NSInvocation 不支持带自定义共用体参数的方法。
        // 2. 不能简单地直接使用共用体的最大数据类型，因为数据在函数参数传递的过程中，会发生改变。
        //
        // 在 testUnionConvertion 单元测试中，假如有类型为 {int, double} 的共用体，
        // a. 将共用体存储到 NSValue 中
        // b. 用 double 取出来
        // c. 由于在然后将 double 赋值给参数类型为 double 的函数
        // d. 使用 double 类型通过 objc_msgSend 发送消息
        // 即使函数实际参数是原始的共用体，也无法复原共用体，因为 double 内存布局为 1 符号位，11 指数位，52 小数位
        // 如果存储 int 值，那么实际只填充了前12位，那么这个 double 会因为没有小数位，而被认为实际是 0
        //
        // 所以共用体必须用 NSValue 接收。
        if (_valueArgumentType) {
            switch (_valueArgumentType.type) {
                case XZStdcTypeUnion: {
                    NSString *reason = NSLocalizedString(@"运行时不支持使用 union 类型作为参数，请使用 NSValue 代替。", @"");
                    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
                    break;
                }
                case XZStdcTypeStruct: {
                    if (_valueArgumentType.structType == XZStdcStructTypeUnknown) {
                        NSString *reason = NSLocalizedString(@"运行时不支持使用自定义 struct 类型作为参数，请使用 NSValue 代替。", @"");
                        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
                    }
                    break;
                }
                default:
                    break;
            }
            if (_valueArgumentType.type == XZStdcTypeUnion) {
                
            }
        }
    }
    return self;
}

- (void)sender:(id)sender sendActionForKey:(XZMocoaKey)key value:(id)value {
    switch (_numberOfArguments) {
        case 0: {
            ((void (*)(id, SEL))objc_msgSend)(_target, _action);
            break;
        }
        case 1:
        case 2:
        case 3: {
            switch (_valueArgumentType.type) {
                case XZStdcTypeUnknown: {
                    void *pointerValue = NULL;
                    [(NSValue *)value getValue:&pointerValue size:sizeof(void *)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, void *))objc_msgSend)(_target, _action, pointerValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, void *))objc_msgSend)(_target, _action, key, pointerValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, void *))objc_msgSend)(_target, _action, sender, key, pointerValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeChar: {
                    char charValue = 0;
                    // 使用 getValue:size: 而不是 charValue 取值，是为了避免没有使用 NSNumber 而是直接使用 NSValue 封装的标量值
                    [(NSValue *)value getValue:&charValue size:sizeof(char)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, char))objc_msgSend)(_target, _action, charValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, char))objc_msgSend)(_target, _action, key, charValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, char))objc_msgSend)(_target, _action, sender, key, charValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeUnsignedChar: {
                    unsigned char ucharValue = 0;
                    [(NSValue *)value getValue:&ucharValue size:sizeof(unsigned char)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, unsigned char))objc_msgSend)(_target, _action, ucharValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, unsigned char))objc_msgSend)(_target, _action, key, ucharValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, unsigned char))objc_msgSend)(_target, _action, sender, key, ucharValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeInt: {
                    int intValue = 0;
                    [(NSValue *)value getValue:&intValue size:sizeof(int)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, int))objc_msgSend)(_target, _action, intValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, int))objc_msgSend)(_target, _action, key, intValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, int))objc_msgSend)(_target, _action, sender, key, intValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeUnsignedInt: {
                    unsigned int uintValue = 0;
                    [(NSValue *)value getValue:&uintValue size:sizeof(unsigned int)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, unsigned int))objc_msgSend)(_target, _action, uintValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, unsigned int))objc_msgSend)(_target, _action, key, uintValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, unsigned int))objc_msgSend)(_target, _action, sender, key, uintValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeShort: {
                    short shortValue = 0;
                    [(NSValue *)value getValue:&shortValue size:sizeof(short)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, short))objc_msgSend)(_target, _action, shortValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, short))objc_msgSend)(_target, _action, key, shortValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, short))objc_msgSend)(_target, _action, sender, key, shortValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeUnsignedShort: {
                    unsigned short ushortValue = 0;
                    [(NSValue *)value getValue:&ushortValue size:sizeof(unsigned short)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, unsigned short))objc_msgSend)(_target, _action, ushortValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, unsigned short))objc_msgSend)(_target, _action, key, ushortValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, unsigned short))objc_msgSend)(_target, _action, sender, key, ushortValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeLong: {
                    long longValue = 0;
                    [(NSValue *)value getValue:&longValue size:sizeof(long)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, long))objc_msgSend)(_target, _action, longValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, long))objc_msgSend)(_target, _action, key, longValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, long))objc_msgSend)(_target, _action, sender, key, longValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeUnsignedLong: {
                    unsigned long ulongValue = 0;
                    [(NSValue *)value getValue:&ulongValue size:sizeof(unsigned long)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, unsigned long))objc_msgSend)(_target, _action, ulongValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, unsigned long))objc_msgSend)(_target, _action, key, ulongValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, unsigned long))objc_msgSend)(_target, _action, sender, key, ulongValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeLongLong: {
                    long long longlongValue = 0;
                    [(NSValue *)value getValue:&longlongValue size:sizeof(long long)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, long long))objc_msgSend)(_target, _action, longlongValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, long long))objc_msgSend)(_target, _action, key, longlongValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, long long))objc_msgSend)(_target, _action, sender, key, longlongValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeUnsignedLongLong: {
                    unsigned long long ulonglongValue = 0;
                    [(NSValue *)value getValue:&ulonglongValue size:sizeof(unsigned long long)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, unsigned long long))objc_msgSend)(_target, _action, ulonglongValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, unsigned long long))objc_msgSend)(_target, _action, key, ulonglongValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, unsigned long long))objc_msgSend)(_target, _action, sender, key, ulonglongValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeFloat: {
                    float floatValue = 0;
                    [(NSValue *)value getValue:&floatValue size:sizeof(float)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, float))objc_msgSend)(_target, _action, floatValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, float))objc_msgSend)(_target, _action, key, floatValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, float))objc_msgSend)(_target, _action, sender, key, floatValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeDouble: {
                    double doubleValue = 0;
                    [(NSValue *)value getValue:&doubleValue size:sizeof(double)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, double))objc_msgSend)(_target, _action, doubleValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, double))objc_msgSend)(_target, _action, key, doubleValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, double))objc_msgSend)(_target, _action, sender, key, doubleValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeLongDouble: {
                    long double longDoubleValue = 0;
                    [(NSValue *)value getValue:&longDoubleValue size:sizeof(long double)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, long double))objc_msgSend)(_target, _action, longDoubleValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, long double))objc_msgSend)(_target, _action, key, longDoubleValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, long double))objc_msgSend)(_target, _action, sender, key, longDoubleValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeBool: {
                    BOOL boolValue = 0;
                    [(NSValue *)value getValue:&boolValue size:sizeof(BOOL)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, BOOL))objc_msgSend)(_target, _action, boolValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, BOOL))objc_msgSend)(_target, _action, key, boolValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, BOOL))objc_msgSend)(_target, _action, sender, key, boolValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeVoid: {
                    // 不存在此类型的参数。
                    break;
                }
                case XZStdcTypeString: {
                    char * stringValue = 0;
                    [(NSValue *)value getValue:&stringValue size:sizeof(char *)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, char *))objc_msgSend)(_target, _action, stringValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, char *))objc_msgSend)(_target, _action, key, stringValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, char *))objc_msgSend)(_target, _action, sender, key, stringValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeSelector: {
                    SEL selectorValue = NULL;
                    [(NSValue *)value getValue:&selectorValue size:sizeof(SEL)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, SEL))objc_msgSend)(_target, _action, selectorValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, SEL))objc_msgSend)(_target, _action, key, selectorValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, SEL))objc_msgSend)(_target, _action, sender, key, selectorValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypePointer: {
                    void * pointerValue = 0;
                    [(NSValue *)value getValue:&pointerValue size:sizeof(void *)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, void *))objc_msgSend)(_target, _action, pointerValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, void *))objc_msgSend)(_target, _action, key, pointerValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, void *))objc_msgSend)(_target, _action, sender, key, pointerValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeArray: {
                    void * arrayValue = 0;
                    [(NSValue *)value getValue:&arrayValue size:sizeof(void *)];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, void *))objc_msgSend)(_target, _action, arrayValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, void *))objc_msgSend)(_target, _action, key, arrayValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, void *))objc_msgSend)(_target, _action, sender, key, arrayValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeBitField: {
                    // 此类型不会出现在方法的参数中
                    break;
                }
                case XZStdcTypeUnion: {
                    // 不支持此类型
                    break;
                }
                case XZStdcTypeStruct: {
                    switch (_valueArgumentType.structType) {
                        case XZStdcStructTypeUnknown:
                            break;
                        case XZStdcStructTypeCGRect: {
                            CGRect structValue;
                            [(NSValue *)value getValue:&structValue size:sizeof(CGRect)];
                            switch (_numberOfArguments) {
                                case 1:
                                    ((void (*)(id, SEL, CGRect))objc_msgSend)(_target, _action, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, CGRect))objc_msgSend)(_target, _action, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, CGRect))objc_msgSend)(_target, _action, sender, key, structValue);
                                    break;
                                default:
                                    break;
                            }
                            break;
                        }
                        case XZStdcStructTypeCGSize: {
                            CGSize structValue;
                            [(NSValue *)value getValue:&structValue size:sizeof(CGSize)];
                            switch (_numberOfArguments) {
                                case 1:
                                    ((void (*)(id, SEL, CGSize))objc_msgSend)(_target, _action, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, CGSize))objc_msgSend)(_target, _action, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, CGSize))objc_msgSend)(_target, _action, sender, key, structValue);
                                    break;
                                default:
                                    break;
                            }
                            break;
                        }
                        case XZStdcStructTypeCGPoint: {
                            CGPoint structValue;
                            [(NSValue *)value getValue:&structValue size:sizeof(CGPoint)];
                            switch (_numberOfArguments) {
                                case 1:
                                    ((void (*)(id, SEL, CGPoint))objc_msgSend)(_target, _action, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, CGPoint))objc_msgSend)(_target, _action, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, CGPoint))objc_msgSend)(_target, _action, sender, key, structValue);
                                    break;
                                default:
                                    break;
                            }
                            break;
                        }
                        case XZStdcStructTypeCGVector: {
                            CGVector structValue;
                            [(NSValue *)value getValue:&structValue size:sizeof(CGVector)];
                            switch (_numberOfArguments) {
                                case 1:
                                    ((void (*)(id, SEL, CGVector))objc_msgSend)(_target, _action, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, CGVector))objc_msgSend)(_target, _action, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, CGVector))objc_msgSend)(_target, _action, sender, key, structValue);
                                    break;
                                default:
                                    break;
                            }
                            break;
                        }
                        case XZStdcStructTypeCGAffineTransform: {
                            CGAffineTransform structValue;
                            [(NSValue *)value getValue:&structValue size:sizeof(CGAffineTransform)];
                            switch (_numberOfArguments) {
                                case 1:
                                    ((void (*)(id, SEL, CGAffineTransform))objc_msgSend)(_target, _action, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, CGAffineTransform))objc_msgSend)(_target, _action, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, CGAffineTransform))objc_msgSend)(_target, _action, sender, key, structValue);
                                    break;
                                default:
                                    break;
                            }
                            break;
                        }
                        case XZStdcStructTypeNSDirectionalEdgeInsets: {
                            NSDirectionalEdgeInsets structValue;
                            [(NSValue *)value getValue:&structValue size:sizeof(NSDirectionalEdgeInsets)];
                            switch (_numberOfArguments) {
                                case 1:
                                    ((void (*)(id, SEL, NSDirectionalEdgeInsets))objc_msgSend)(_target, _action, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, NSDirectionalEdgeInsets))objc_msgSend)(_target, _action, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, NSDirectionalEdgeInsets))objc_msgSend)(_target, _action, sender, key, structValue);
                                    break;
                                default:
                                    break;
                            }
                            break;
                        }
                        case XZStdcStructTypeNSRange: {
                            NSRange structValue;
                            [(NSValue *)value getValue:&structValue size:sizeof(NSRange)];
                            switch (_numberOfArguments) {
                                case 1:
                                    ((void (*)(id, SEL, NSRange))objc_msgSend)(_target, _action, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, NSRange))objc_msgSend)(_target, _action, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, NSRange))objc_msgSend)(_target, _action, sender, key, structValue);
                                    break;
                                default:
                                    break;
                            }
                            break;
                        }
                        case XZStdcStructTypeUIEdgeInsets: {
                            UIEdgeInsets structValue;
                            [(NSValue *)value getValue:&structValue size:sizeof(UIEdgeInsets)];
                            switch (_numberOfArguments) {
                                case 1:
                                    ((void (*)(id, SEL, UIEdgeInsets))objc_msgSend)(_target, _action, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, UIEdgeInsets))objc_msgSend)(_target, _action, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, UIEdgeInsets))objc_msgSend)(_target, _action, sender, key, structValue);
                                    break;
                                default:
                                    break;
                            }
                            break;
                        }
                        case XZStdcStructTypeUIOffset: {
                            UIOffset structValue;
                            [(NSValue *)value getValue:&structValue size:sizeof(UIOffset)];
                            switch (_numberOfArguments) {
                                case 1:
                                    ((void (*)(id, SEL, UIOffset))objc_msgSend)(_target, _action, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, UIOffset))objc_msgSend)(_target, _action, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, UIOffset))objc_msgSend)(_target, _action, sender, key, structValue);
                                    break;
                                default:
                                    break;
                            }
                            break;
                        }
                    }
                    break;
                }
                case XZStdcTypeClass:
                case XZStdcTypeObject:
                default: {
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, id))objc_msgSend)(_target, _action, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, id))objc_msgSend)(_target, _action, key, value);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, id))objc_msgSend)(_target, _action, sender, key, value);
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
