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

/// 按 class 分类存储的 selector 与 XZObjcMethod 映射表。
/// 存储的是视图的方法，在主线程调用，不用考虑并发问题。
static NSMapTable<Class, NSMapTable<id, XZObjcMethod *> *> *_classActionTable = nil;

@implementation XZMocoaTargetAction

+ (XZMocoaTargetAction *)targetActionWithTarget:(id)target selector:(SEL)selector {
    Class const TargetClass = object_getClass(target);
    if (TargetClass == Nil) {
        return nil;
    }
    XZObjcMethod *action = [self actionForClass:TargetClass selector:selector];
    if (action == nil) {
        return nil;
    }
    return [[self alloc] initWithTarget:target action:action];
}

- (XZMocoaTargetAction *)initWithTarget:(id)target action:(XZObjcMethod *)action {
    self = [super init];
    if (self) {
        _target = target;
        _action = action;
    }
    return self;
}

+ (XZObjcMethod *)actionForClass:(Class)class selector:(SEL)selector {
    if (class == Nil || selector == nil) {
        return nil;
    }
    NSParameterAssert(object_isClass(class));
    
    if (_classActionTable == nil) {
        _classActionTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsOpaquePersonality valueOptions:NSPointerFunctionsStrongMemory capacity:0];
    }
    
    NSMapTable *actionTable = [_classActionTable objectForKey:class];
    if (actionTable == nil) {
        actionTable = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsOpaquePersonality valueOptions:NSPointerFunctionsStrongMemory capacity:0];
        [_classActionTable setObject:actionTable forKey:class];
    }
    
    XZObjcMethod *method = (__bridge id)NSMapGet(actionTable, selector);
    if (method) {
        return method;
    }
    
    method = [XZObjcMethod methodWithMethod:class_getInstanceMethod(class, selector)];
    if (method == nil) {
        return nil;
    }
    NSAssert(method.arguments.count <= 3, @"用于执行 KTA 事件的方法的参数数量错误，具体请参考 -[XZMocoaViewModel addTarget:action:forKey:] 方法");
    
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
    XZObjcType * const valueArgumentType = method.arguments.lastObject;
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
    NSMapInsert(actionTable, selector, (__bridge void *)method);
    
    return method;
}


+ (void)viewModel:(const id)viewModel target:(const id)target sendAction:(SEL)selector forKey:(const XZMocoaKey)key value:(const id)value {
    Class const class = object_getClass(target);
    if (class == Nil || selector == nil) {
        return;
    }
    XZObjcMethod * const action = [self actionForClass:class selector:selector];
    [self target:target sendAction:action viewModel:viewModel key:key value:value];
}

+ (void)target:(id const)target sendAction:(XZObjcMethod * const)action viewModel:(id const)viewModel key:(const XZMocoaKey)key value:(const id)value {
    if (target == nil || viewModel == nil || action == nil) {
        return;
    }
    switch (action.arguments.count) {
        case 0: {
            [action call:target parameters:nil];
            break;
        }
        case 1: {
            [action call:target parameters:@[(value ?: (id)kCFNull)]];
            break;
        }
        case 2: {
            [action call:target parameters:@[(key ?: kMocoaNilKey), (value ?: (id)kCFNull)]];
            break;
        }
        case 3: {
            [action call:target parameters:@[(viewModel), (key ?: kMocoaNilKey), (value ?: (id)kCFNull)]];
            break;
        }
        default: {
            // Never happens
            break;
        }
    }
}

- (void)viewModel:(const id)viewModel target:(const id)target sendActionForKey:(const XZMocoaKey)key value:(const id)value {
    [XZMocoaTargetAction target:target sendAction:_action viewModel:viewModel key:key value:value];
}

@end
