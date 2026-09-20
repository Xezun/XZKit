//
//  XZMocoaTargetAction.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import "XZMocoaTargetAction.h"
#import "XZObjc.h"
#import "XZMocoaViewModel.h"
@import ObjectiveC;

@implementation XZMocoaTarget

+ (XZMocoaTarget *)targetActionWithTarget:(id)target selector:(SEL)selector {
    Class const TargetClass = object_getClass(target);
    if (TargetClass == Nil) {
        return nil;
    }
    XZMocoaAction *action = [XZMocoaAction actionForClass:TargetClass selector:selector];
    if (action == nil) {
        return nil;
    }
    return [[self alloc] initWithTarget:target action:action];
}

- (XZMocoaTarget *)initWithTarget:(id)target action:(XZMocoaAction *)action {
    self = [super init];
    if (self) {
        _target = target;
        _action = action;
    }
    return self;
}

@end

/// 按 class 分类存储的 selector 与 XZMocoaAction 映射表。
/// 存储的是视图的方法，在主线程调用，不用考虑并发问题。
static NSMapTable<Class, NSMapTable<id, XZMocoaAction *> *> *_classActionTable = nil;

@implementation XZMocoaAction  {
    /// action 的参数数量，不包括 self 和 SEL
    NSInteger _numberOfArguments;
    /// value 参数的值类型。
    XZObjcType *_valueArgumentType;
}

+ (XZMocoaAction *)actionForClass:(Class)class selector:(SEL)selector {
    if (class == Nil || selector == nil) {
        return nil;
    }
    
    if (_classActionTable == nil) {
        _classActionTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsOpaquePersonality valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    
    NSMapTable *actionTable = [_classActionTable objectForKey:class];
    if (actionTable == nil) {
        actionTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsOpaquePersonality valueOptions:NSPointerFunctionsStrongMemory capacity:0];
        [_classActionTable setObject:actionTable forKey:class];
    }
    
    XZMocoaAction *action = (__bridge id)NSMapGet(actionTable, selector);
    if (action) {
        return action;
    }
    
    NSParameterAssert(object_isClass(class));
    
    Method const method = class_getInstanceMethod(class, selector);
    if (method == nil) {
        return nil;
    }
    
    NSInteger const numberOfArguments = (NSInteger)(method_getNumberOfArguments(method)) - 2;
    XZObjcType *valueArgumentType = nil;
    
    switch (numberOfArguments) {
        case 0: { // keyDidChangeValue()
            valueArgumentType = nil;
            break;
        }
        case 1: { // keyDidChangeValue(_ newValue:)
            const char *encoding = method_copyArgumentType(method, 2);
            valueArgumentType = [XZObjcType typeForEncoding:encoding];
            free((void *)encoding);
            break;
        }
        case 2: { // key(_ key: XZMocoaKey, didChangeValue newValue:)
            const char *encoding = method_copyArgumentType(method, 3);
            valueArgumentType = [XZObjcType typeForEncoding:encoding];
            free((void *)encoding);
            break;
        }
        case 3: { // viewModel(_ viewModel: XZMocoaViewModel, key: XZMocoaKey, didChangeValue newValue:)
            const char *encoding = method_copyArgumentType(method, 4);
            valueArgumentType = [XZObjcType typeForEncoding:encoding];
            free((void *)encoding);
            break;
        }
        default: {
            NSAssert(NO, @"用于执行 KTA 事件的方法的参数数量错误，具体请参考 -[XZMocoaViewModel addTarget:action:forKey:] 方法");
            return nil;
        }
    }
    
    // 共用体的情况比较复杂，暂不支持：
    // 1. 方法参数为自定义共用体时，用同等宽度的类型代替并不安全，也无法使用 NSInvocation 调用方法（不支持）。
    // 2. 不能简单地直接使用共用体的最大数据类型，因为数据在函数参数传递的过程中，会发生改变。
    //
    // 在 testUnionConvertion 单元测试中，假如有类型为 {int, double} 的共用体，
    // a. 将共用体存储到 NSValue 中
    // b. 用 double 取出来
    // c. 由于在然后将 double 赋值给参数类型为 double 的函数
    // d. 使用 double 类型通过 objc_msgSend 发送消息
    // 即使函数实际参数是原始的共用体，也无法复原共用体，因为 double 内存布局为 1 符号位，11 指数位，52 小数位
    // 如果存储 int 值，那么实际只填充了前12位，那么这个 double 会因为只有指数位，没有小数位，而被认为实际是 0
    //
    // 所以共用体必须用 NSValue 接收。
    if (valueArgumentType) {
        switch (valueArgumentType.type) {
            case XZStdcTypeUnion: {
                NSAssert(NO, @"检测到 KTA 事件值为共用体类型，运行时不支持共用体作为参数，请改用 NSValue 类型接收事件值");
                return nil;
            }
            case XZStdcTypeStruct: {
                if (valueArgumentType.structType == XZStdcStructTypeUnknown) {
                    NSAssert(NO, @"检测到 KTA 事件值为目前不支持的结构体类型，请改用 NSValue 类型接收事件值");
                    return nil;
                }
                break;
            }
            default:
                break;
        }
    }
    
    action = [[XZMocoaAction alloc] initWithSelector:selector numberOfArguments:numberOfArguments valueArgumentType:valueArgumentType];
    NSMapInsert(actionTable, selector, (__bridge void *)action);
    
    return action;
}

- (instancetype)initWithSelector:(SEL)selector numberOfArguments:(NSInteger)numberOfArguments valueArgumentType:(XZObjcType *)valueArgumentType {
    self = [super init];
    if (self) {
        _selector = selector;
        _numberOfArguments = numberOfArguments;
        _valueArgumentType = valueArgumentType;
    }
    return self;
}

+ (void)sender:(const id)sender target:(const id)target sendAction:(SEL)selector forKey:(const XZMocoaKey)key value:(const id)value {
    Class const class = object_getClass(target);
    if (class == Nil || selector == nil) {
        return;
    }
    XZMocoaAction *action = [XZMocoaAction actionForClass:class selector:selector];
    [action sender:sender target:target sendActionForKey:key value:value];
}

- (void)sender:(const id)sender target:(const id)target sendActionForKey:(const XZMocoaKey)key value:(const id)value {
    switch (_numberOfArguments) {
        case 0: {
            ((void (*)(id, SEL))objc_msgSend)(target, _selector);
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
                            ((void (*)(id, SEL, void *))objc_msgSend)(target, _selector, pointerValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, void *))objc_msgSend)(target, _selector, key, pointerValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, void *))objc_msgSend)(target, _selector, sender, key, pointerValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeChar: {
                    // 使用 NSNumber 来处理标量值。
                    // 不再兼容 NSValue 对象，因为在 Swift 中 4 字节 UInt32 类型的属性，通过 KVC 取值，是按 8 字节存储的。
                    char const charValue = [(NSNumber *)value charValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, char))objc_msgSend)(target, _selector, charValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, char))objc_msgSend)(target, _selector, key, charValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, char))objc_msgSend)(target, _selector, sender, key, charValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeUnsignedChar: {
                    unsigned char const ucharValue = [(NSNumber *)value unsignedCharValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, unsigned char))objc_msgSend)(target, _selector, ucharValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, unsigned char))objc_msgSend)(target, _selector, key, ucharValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, unsigned char))objc_msgSend)(target, _selector, sender, key, ucharValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeInt: {
                    int const intValue = [(NSNumber *)value intValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, int))objc_msgSend)(target, _selector, intValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, int))objc_msgSend)(target, _selector, key, intValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, int))objc_msgSend)(target, _selector, sender, key, intValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeUnsignedInt: {
                    unsigned int const uintValue = [(NSNumber *)value unsignedIntValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, unsigned int))objc_msgSend)(target, _selector, uintValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, unsigned int))objc_msgSend)(target, _selector, key, uintValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, unsigned int))objc_msgSend)(target, _selector, sender, key, uintValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeShort: {
                    short const shortValue = [(NSNumber *)value shortValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, short))objc_msgSend)(target, _selector, shortValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, short))objc_msgSend)(target, _selector, key, shortValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, short))objc_msgSend)(target, _selector, sender, key, shortValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeUnsignedShort: {
                    unsigned short const ushortValue = [(NSNumber *)value unsignedShortValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, unsigned short))objc_msgSend)(target, _selector, ushortValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, unsigned short))objc_msgSend)(target, _selector, key, ushortValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, unsigned short))objc_msgSend)(target, _selector, sender, key, ushortValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeLong: {
                    long const longValue = [(NSNumber *)value longValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, long))objc_msgSend)(target, _selector, longValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, long))objc_msgSend)(target, _selector, key, longValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, long))objc_msgSend)(target, _selector, sender, key, longValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeUnsignedLong: {
                    unsigned long const ulongValue = [(NSNumber *)value unsignedLongValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, unsigned long))objc_msgSend)(target, _selector, ulongValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, unsigned long))objc_msgSend)(target, _selector, key, ulongValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, unsigned long))objc_msgSend)(target, _selector, sender, key, ulongValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeLongLong: {
                    long long const longlongValue = [(NSNumber *)value longLongValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, long long))objc_msgSend)(target, _selector, longlongValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, long long))objc_msgSend)(target, _selector, key, longlongValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, long long))objc_msgSend)(target, _selector, sender, key, longlongValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeUnsignedLongLong: {
                    unsigned long long const ulonglongValue = [(NSNumber *)value unsignedLongLongValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, unsigned long long))objc_msgSend)(target, _selector, ulonglongValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, unsigned long long))objc_msgSend)(target, _selector, key, ulonglongValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, unsigned long long))objc_msgSend)(target, _selector, sender, key, ulonglongValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeFloat: {
                    float const floatValue = [(NSNumber *)value floatValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, float))objc_msgSend)(target, _selector, floatValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, float))objc_msgSend)(target, _selector, key, floatValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, float))objc_msgSend)(target, _selector, sender, key, floatValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeDouble: {
                    double const doubleValue = [(NSNumber *)value doubleValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, double))objc_msgSend)(target, _selector, doubleValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, double))objc_msgSend)(target, _selector, key, doubleValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, double))objc_msgSend)(target, _selector, sender, key, doubleValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeLongDouble: {
                    long double const longDoubleValue = [(NSNumber *)value doubleValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, long double))objc_msgSend)(target, _selector, longDoubleValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, long double))objc_msgSend)(target, _selector, key, longDoubleValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, long double))objc_msgSend)(target, _selector, sender, key, longDoubleValue);
                            break;
                        default:
                            break;
                    }
                    break;
                }
                case XZStdcTypeBool: {
                    BOOL const boolValue = [(NSNumber *)value boolValue];
                    switch (_numberOfArguments) {
                        case 1:
                            ((void (*)(id, SEL, BOOL))objc_msgSend)(target, _selector, boolValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, BOOL))objc_msgSend)(target, _selector, key, boolValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, BOOL))objc_msgSend)(target, _selector, sender, key, boolValue);
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
                            ((void (*)(id, SEL, char *))objc_msgSend)(target, _selector, stringValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, char *))objc_msgSend)(target, _selector, key, stringValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, char *))objc_msgSend)(target, _selector, sender, key, stringValue);
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
                            ((void (*)(id, SEL, SEL))objc_msgSend)(target, _selector, selectorValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, SEL))objc_msgSend)(target, _selector, key, selectorValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, SEL))objc_msgSend)(target, _selector, sender, key, selectorValue);
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
                            ((void (*)(id, SEL, void *))objc_msgSend)(target, _selector, pointerValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, void *))objc_msgSend)(target, _selector, key, pointerValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, void *))objc_msgSend)(target, _selector, sender, key, pointerValue);
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
                            ((void (*)(id, SEL, void *))objc_msgSend)(target, _selector, arrayValue);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, void *))objc_msgSend)(target, _selector, key, arrayValue);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, void *))objc_msgSend)(target, _selector, sender, key, arrayValue);
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
                                    ((void (*)(id, SEL, CGRect))objc_msgSend)(target, _selector, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, CGRect))objc_msgSend)(target, _selector, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, CGRect))objc_msgSend)(target, _selector, sender, key, structValue);
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
                                    ((void (*)(id, SEL, CGSize))objc_msgSend)(target, _selector, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, CGSize))objc_msgSend)(target, _selector, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, CGSize))objc_msgSend)(target, _selector, sender, key, structValue);
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
                                    ((void (*)(id, SEL, CGPoint))objc_msgSend)(target, _selector, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, CGPoint))objc_msgSend)(target, _selector, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, CGPoint))objc_msgSend)(target, _selector, sender, key, structValue);
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
                                    ((void (*)(id, SEL, CGVector))objc_msgSend)(target, _selector, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, CGVector))objc_msgSend)(target, _selector, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, CGVector))objc_msgSend)(target, _selector, sender, key, structValue);
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
                                    ((void (*)(id, SEL, CGAffineTransform))objc_msgSend)(target, _selector, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, CGAffineTransform))objc_msgSend)(target, _selector, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, CGAffineTransform))objc_msgSend)(target, _selector, sender, key, structValue);
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
                                    ((void (*)(id, SEL, NSDirectionalEdgeInsets))objc_msgSend)(target, _selector, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, NSDirectionalEdgeInsets))objc_msgSend)(target, _selector, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, NSDirectionalEdgeInsets))objc_msgSend)(target, _selector, sender, key, structValue);
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
                                    ((void (*)(id, SEL, NSRange))objc_msgSend)(target, _selector, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, NSRange))objc_msgSend)(target, _selector, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, NSRange))objc_msgSend)(target, _selector, sender, key, structValue);
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
                                    ((void (*)(id, SEL, UIEdgeInsets))objc_msgSend)(target, _selector, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, UIEdgeInsets))objc_msgSend)(target, _selector, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, UIEdgeInsets))objc_msgSend)(target, _selector, sender, key, structValue);
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
                                    ((void (*)(id, SEL, UIOffset))objc_msgSend)(target, _selector, structValue);
                                    break;
                                case 2:
                                    ((void (*)(id, SEL, XZMocoaKey, UIOffset))objc_msgSend)(target, _selector, key, structValue);
                                    break;
                                case 3:
                                    ((void (*)(id, SEL, id, XZMocoaKey, UIOffset))objc_msgSend)(target, _selector, sender, key, structValue);
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
                            ((void (*)(id, SEL, id))objc_msgSend)(target, _selector, value);
                            break;
                        case 2:
                            ((void (*)(id, SEL, XZMocoaKey, id))objc_msgSend)(target, _selector, key, value);
                            break;
                        case 3:
                            ((void (*)(id, SEL, id, XZMocoaKey, id))objc_msgSend)(target, _selector, sender, key, value);
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
