//
//  XZMocoaViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/4/10.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaViewModel.h"
#import "XZMocoaView.h"
#import "XZMocoaTargetActionTable.h"
#import "XZMocoaKeyObserver.h"
#import "XZMocoaKeyMappingTable.h"
#import "XZObjc.h"

@implementation XZMocoaViewModel {
    @private
    XZMocoaTargetActionTable                * _targetActions;
    NSMutableOrderedSet<XZMocoaViewModel *> * _subViewModels;
    __unsafe_unretained XZMocoaViewModel    * _superViewModel;
}

- (void)dealloc {
    // 移除 kvo
    // [_observer removeAllTargets];
    
    // 不能像下面这样使用 for-in 语句。
    // for (XZMocoaViewModel *viewModel in subViewModels) {
    //     [viewModel removeFromSuperViewModel];
    // }
    // 1. 调用 removeFromSuperViewModel 方法会修改 _subViewModels 集合，
    //    虽然实测并没有崩溃，但是也不应该这样做。
    // 2. 在 for-in 中，被遍历的对象没有被强引用，所以被遍历的对象 viewModel
    //    可能会因为在 removeFromSuperViewModel 方法中被移除而释放，从而导
    //    致在将 viewModel 作为参数调用 -didRemoveSubViewModel: 方法时，
    //    因访问已经释放 viewModel 对象而发生崩溃。
    
    XZMocoaViewModel *viewModel = _subViewModels.lastObject;
    while (viewModel != nil) {
        [viewModel removeFromSuperViewModel]; 
        viewModel = _subViewModels.lastObject;
    }
    
    [self _removeModelObserverIfNeeded:_model];
}

- (instancetype)init {
    return [self initWithModel:nil];
}

- (instancetype)initWithModel:(id)model {
    self = [super init];
    if (self) {
        _index   = 0;
        _isReady = NO;
        _model   = model;
    }
    return self;
}

+ (instancetype)viewModelWithURL:(NSURL *)URL model:(nullable id)model {
    XZMocoaModule * const module = [XZMocoaModule moduleForURL:URL];
    return [module instantiateViewModelWithModel:model];
}

+ (__kindof XZMocoaViewModel *)viewModelWithModule:(XZMocoaModule *)module model:(id)model {
    return [module instantiateViewModelWithModel:model];
}

- (UIViewController *)viewController {
    UIViewController *viewController = _context.viewController;
    if (viewController) {
        return viewController;
    }
    return _superViewModel.viewController;
}

- (UINavigationController *)navigationController {
    UINavigationController *viewController = _context.navigationController;
    if (viewController) {
        return viewController;
    }
    return _superViewModel.navigationController;
}

- (UITabBarController *)tabBarController {
    UITabBarController *viewController = _context.tabBarController;
    if (viewController) {
        return viewController;
    }
    return _superViewModel.tabBarController;
}

- (void)ready {
    if (_isReady) {
        return;
    }
    [self prepare];
    _isReady = YES;
    for (XZMocoaViewModel *viewModel in _subViewModels) {
        [viewModel ready];
    }
}

- (void)prepare {
    if ([self _attachModelObserverIfNeeded:self.model]) {
        NSArray * const allKeys = [[XZMocoaKeyMappingTable tableForClass:self.class].keyToMethods allKeys];
        [self model:_model didChangeValuesForKeys:[NSSet setWithArray:allKeys]];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, isReady = %@; subViewModels = (%ld objects)>", self.class, self, @(self.isReady), self.subViewModels.count];
}

- (void)setModel:(id)model {
    if (_model != model) {
        [self _removeModelObserverIfNeeded:_model];
        _model = model;
        [self _attachModelObserverIfNeeded:_model];
    }
}

- (BOOL)_attachModelObserverIfNeeded:(id)model {
    if ([self shouldObserveModelKeysActively]) {
        if (model == nil) {
            return NO;
        }
        NSArray * const allKeys = [[XZMocoaKeyMappingTable tableForClass:self.class].keyToMethods allKeys];
        if (allKeys == nil) {
            return NO;
        }
        [[XZMocoaKeyObserver observerForModel:model] attachReceiver:self forKeys:allKeys];
        return NO;
    }
    return YES;
}
         
- (void)_removeModelObserverIfNeeded:(id)model {
    if (model == nil || ![self shouldObserveModelKeysActively]) {
        return;
    }
    [[XZMocoaKeyObserver observerForModel:model] detachReceiver:self];
}

@end


@implementation XZMocoaViewModel (XZMocoaHierarchy)

- (NSArray<XZMocoaViewModel *> *)subViewModels {
    return _subViewModels.array;
}

- (XZMocoaViewModel *)superViewModel {
    return _superViewModel;
}

/// 当前视图模型能否添加指定的下级视图模型。
- (BOOL)canAddSubViewModel:(XZMocoaViewModel *)subViewModel {
    if (subViewModel == nil || self == subViewModel) {
        NSAssert(NO, @"不能添加自己为下级");
        return NO;
    }
    
    if (![subViewModel isKindOfClass:[XZMocoaViewModel class]]) {
        NSAssert(NO, @"仅可添加 %@ 及子类对象为下级", [XZMocoaViewModel class]);
        return NO;
    }
    
    if (_subViewModels == nil) {
        _subViewModels = [NSMutableOrderedSet orderedSet];
    }
    
    // 去重，避免重复事件
    if ([_subViewModels containsObject:subViewModel]) {
        NSAssert(NO, @"不能重复添加同一个元素为下级");
        return NO;
    }
    
    // 从已有的上级中移除。
    if (subViewModel->_superViewModel != nil) {
        [subViewModel removeFromSuperViewModel];
    }
    
    return YES;
}

- (void)addSubViewModel:(XZMocoaViewModel *)subViewModel {
    if ([self canAddSubViewModel:subViewModel]) {
        subViewModel->_superViewModel = self;
        [_subViewModels addObject:subViewModel];
        
        if (self.isReady) {
            [subViewModel ready];
        }
    }
}

- (void)insertSubViewModel:(XZMocoaViewModel *)subViewModel atIndex:(NSInteger)index {
    if ([self canAddSubViewModel:subViewModel]) {
        subViewModel->_superViewModel = self;
        [_subViewModels insertObject:subViewModel atIndex:index];
        
        if (self.isReady) {
            [subViewModel ready];
        }
    }
}

- (void)moveSubViewModelAtIndex:(NSInteger)index toIndex:(NSInteger)newIndex {
    if (index == newIndex) {
        return;
    }
    XZMocoaViewModel * const viewModel = [_subViewModels objectAtIndex:index];
    [_subViewModels removeObjectAtIndex:index];
    [_subViewModels insertObject:viewModel atIndex:newIndex];
}

- (void)removeFromSuperViewModel {
    XZMocoaViewModel * const superViewModel = _superViewModel;
    if (superViewModel == nil) {
        return;
    }
    _superViewModel = nil;
    
    [superViewModel->_subViewModels removeObject:self];
    [superViewModel didRemoveSubViewModel:self];
}

- (void)didRemoveSubViewModel:(__kindof XZMocoaViewModel *)viewModel {
    
}

@end


@implementation XZMocoaEvents {
    @package
    __kindof XZMocoaViewModel * __unsafe_unretained _target;
}

+ (instancetype)eventsWithName:(NSString *)name value:(id)value source:(XZMocoaViewModel *)source {
    return [[self alloc] initWithKey:name value:value source:source];
}

- (instancetype)initWithKey:(NSString *)name value:(id)value source:(XZMocoaViewModel *)source {
    self = [super init];
    if (self) {
        _key   = name.copy ?: XZMocoaKeyNone;
        _value  = value;
        _source = source;
        _target = source;
    }
    return self;
}

@end


@implementation XZMocoaViewModel (XZMocoaKeyEventsChannel)

- (void)sendEventsWithKey:(XZMocoaKey)name value:(id)value {
    XZMocoaEvents * const events = [XZMocoaEvents eventsWithName:name value:value source:self];
    [self sendEvents:events];
}

- (void)sendEvents:(XZMocoaEvents *)events {
    events->_target = self;
    [self.superViewModel didReceiveEvents:events];
}

- (void)didReceiveEvents:(XZMocoaEvents *)events {
    [self sendEvents:events];
}

@end

@implementation XZMocoaViewModel (XZMocoaKeyTargetAction)

- (void)addTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
    if (target == nil || action == nil) {
        NSLog(@"为 target=%@ action=%@ 添加事件失败，参数不能为 nil", target, NSStringFromSelector(action));
        return;
    }
    
    if (_targetActions == nil) {
        _targetActions = [[XZMocoaTargetActionTable alloc] initWithViewModel:self];
    }
    [_targetActions addTarget:target action:action forKey:(key ?: XZMocoaKeyNone)];
}

- (void)removeTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
    [_targetActions removeTarget:target action:action forKey:key];
}

- (void)sendActionsForKey:(XZMocoaKey)key {
    if (!self.isReady) return;
    [_targetActions sendActionsForKey:(key ?: XZMocoaKeyNone) value:nil];
}

- (void)addTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key value:(nullable id)initialValue {
    [self addTarget:target action:action forKey:key];
    [self sendActionsForKey:key value:initialValue];
}

- (void)sendActionsForKey:(XZMocoaKey)key value:(id)value {
    if (!self.isReady) return;
    if (value == nil) {
        value = (key == XZMocoaKeyNone ? nil : [self valueForKey:key]);
    } else if (value == (id)kCFNull) {
        value = nil;
    }
    [_targetActions sendActionsForKey:(key ?: XZMocoaKeyNone) value:value];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end


@implementation XZMocoaViewModel (XZStoryboardSupporting)

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender {
    
}

@end

@import CoreData;

@implementation XZMocoaViewModel (XZMocoaKeyObserver)

- (BOOL)shouldObserveModelKeysActively {
    return NO;
}

+ (NSDictionary<NSString *,id> *)mappingModelKeys {
    return nil;
}

- (void)model:(id)model didChangeValuesForKeys:(NSSet<XZMocoaKey> * const)changedKeys {
    if (model != self.model || changedKeys.count == 0) {
        return;
    }
    
    XZMocoaKeyMappingTable * const table = [XZMocoaKeyMappingTable tableForClass:self.class];
    if (table == nil) {
        return;
    }
    
    NSMutableSet                        * const invokedMethods = [NSMutableSet setWithCapacity:table.methodToKeys.count];
    NSMutableDictionary<NSString *, id> * const fetchedValues  = [NSMutableDictionary dictionaryWithCapacity:table.keyToMethods.count];
    
    for (NSString * const changeKey in changedKeys) {
        for (NSString * const methodName in table.keyToMethods[changeKey]) {
            if ([invokedMethods containsObject:methodName]) {
                continue;
            }
            [invokedMethods addObject:methodName];
            
            NSArray<NSString *> * const keys = table.methodToKeys[methodName];
            XZObjcMethod * const method = table.namedMethods[methodName];
            
            if (method == nil || keys.count != method.arguments.count) {
                continue;
            }
            
            NSMethodSignature * const signature  = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method.raw)];
            NSInvocation      * const invocation = [NSInvocation invocationWithMethodSignature:signature];
            
            invocation.target   = self;
            invocation.selector = method.selector;
            
            for (NSInteger i = 0; i < method.arguments.count; i++) {
                NSString * const key = keys[i];
                
                id value = fetchedValues[key];
                if (value == nil) {
                    value = [model valueForKeyPath:key] ?: (id)kCFNull;
                    fetchedValues[key] = value;
                }
                if (value == (id)kCFNull) {
                    value = nil;
                }
                
                XZObjcType * const type = method.arguments[i];
                switch (type.type) {
                    case XZStdcTypeUnknown: {
                        void *argumentValue = NULL;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(void *)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeChar: {
                        char argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(char)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeUnsignedChar: {
                        unsigned char argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(unsigned char)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeInt: {
                        int argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(int)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeUnsignedInt: {
                        unsigned int argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(unsigned int)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeShort: {
                        short argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(short)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeUnsignedShort: {
                        unsigned short argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(unsigned short)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeLong: {
                        long argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(long)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeUnsignedLong: {
                        unsigned long argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(unsigned long)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeInt128: {
                        SInt64 argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(SInt64)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeUnsignedInt128: {
                        UInt64 argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(UInt64)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeLongLong: {
                        long long argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(long long)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeUnsignedLongLong: {
                        unsigned long long argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(unsigned long long)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeFloat: {
                        float argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(float)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeDouble: {
                        double argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(double)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeLongDouble: {
                        long double argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(long double)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeBool: {
                        BOOL argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(BOOL)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeVoid: {
                        // 不会出现此类型
                        break;
                    }
                    case XZStdcTypeString: {
                        char *argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(char *)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeSelector: {
                        SEL argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(SEL)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypePointer: {
                        void *argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(void *)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeArray: {
                        void *argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(void *)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeVector: {
                        void *argumentValue;
                        [(NSValue *)value getValue:&argumentValue size:sizeof(void *)];
                        [invocation setArgument:&argumentValue atIndex:(i + 2)];
                        break;
                    }
                    case XZStdcTypeBitField: {
                        // 不会出现此类型
                        break;
                    }
                    case XZStdcTypeUnion: {
                        NSString *reason = [NSString stringWithFormat:@"运行时不支持 union 类型，请使用 NSValue 类型：%@", type.name];
                        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
                        break;
                    }
                    case XZStdcTypeStruct: {
                        switch (type.structType) {
                            case XZStdcStructTypeUnknown: {
                                NSString *reason = [NSString stringWithFormat:@"运行时不支持 struct 类型，请使用 NSValue 类型：%@", type.name];
                                @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
                                break;
                            }
                            case XZStdcStructTypeCGRect: {
                                CGRect argumentValue;
                                [(NSValue *)value getValue:&argumentValue size:sizeof(CGRect)];
                                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                                break;
                            }
                            case XZStdcStructTypeCGSize: {
                                CGSize argumentValue;
                                [(NSValue *)value getValue:&argumentValue size:sizeof(CGSize)];
                                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                                break;
                            }
                            case XZStdcStructTypeCGPoint: {
                                CGPoint argumentValue;
                                [(NSValue *)value getValue:&argumentValue size:sizeof(CGPoint)];
                                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                                break;
                            }
                            case XZStdcStructTypeCGVector: {
                                CGVector argumentValue;
                                [(NSValue *)value getValue:&argumentValue size:sizeof(CGVector)];
                                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                                break;
                            }
                            case XZStdcStructTypeCGAffineTransform: {
                                CGAffineTransform argumentValue;
                                [(NSValue *)value getValue:&argumentValue size:sizeof(CGAffineTransform)];
                                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                                break;
                            }
                            case XZStdcStructTypeNSDirectionalEdgeInsets: {
                                NSDirectionalEdgeInsets argumentValue;
                                [(NSValue *)value getValue:&argumentValue size:sizeof(NSDirectionalEdgeInsets)];
                                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                                break;
                            }
                            case XZStdcStructTypeNSRange: {
                                NSRange argumentValue;
                                [(NSValue *)value getValue:&argumentValue size:sizeof(NSRange)];
                                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                                break;
                            }
                            case XZStdcStructTypeUIEdgeInsets: {
                                UIEdgeInsets argumentValue;
                                [(NSValue *)value getValue:&argumentValue size:sizeof(UIEdgeInsets)];
                                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                                break;
                            }
                            case XZStdcStructTypeUIOffset: {
                                UIOffset argumentValue;
                                [(NSValue *)value getValue:&argumentValue size:sizeof(UIOffset)];
                                [invocation setArgument:&argumentValue atIndex:(i + 2)];
                                break;
                            }
                        }
                        break;
                    }
                    case XZStdcTypeClass:
                    case XZStdcTypeObject: {
                        [invocation setArgument:&value atIndex:(i + 2)];
                        break;
                    }
                }
            }
            
            [invocation invoke];
        }
    }
}

@end
