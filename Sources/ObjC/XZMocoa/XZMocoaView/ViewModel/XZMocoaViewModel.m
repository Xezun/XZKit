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
#import "XZMocoaTargetAction.h"
#import "XZMocoaKeyObserver.h"
#import "XZMocoaKeyMappingTable.h"
#import "XZObjc.h"

@implementation XZMocoaViewModel {
    @private
    BOOL _isActivelyObservingModelKeys;
    XZMocoaTargetActionTable                * _targetActions;
    NSMutableOrderedSet<XZMocoaViewModel *> * _subViewModels;
    __unsafe_unretained XZMocoaViewModel    * _superViewModel;
}

- (void)dealloc {
    // 移除子视图模型
    for (NSInteger i = _subViewModels.count - 1; i >= 0; i--) {
        XZMocoaViewModel * const subViewModel = _subViewModels[i];
        [subViewModel removeFromSuperViewModel];
    }
    
    // 移除对数据模型的 KVO 观察
    [self _detachModelObserverIfNeeded:_model];
}

- (instancetype)init {
    return [self initWithModel:nil];
}

- (instancetype)initWithModel:(id)model {
    self = [super init];
    if (self) {
        _frame   = CGRectZero;
        _isReady = NO;
        _model   = model;
        _isActivelyObservingModelKeys = NO;
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
    // 注册观察者。仅注册，不触发绑定事件。
    NSArray * const allKeys = [self _attachModelObserverIfNeeded:self.model];
    if (allKeys == nil || allKeys.count == 0) {
        return;
    }
    // 初始化时，手动触发一次所有绑定。
    [self model:self.model didChangeValuesForKeys:[NSSet setWithArray:allKeys]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, isReady = %@; subViewModels = (%lu objects)>", self.class, self, @(self.isReady), (unsigned long)self.subViewModels.count];
}

- (void)setModel:(id)model {
    if (_model != model) {
        [self _detachModelObserverIfNeeded:_model];
        _model = model;
        [self _attachModelObserverIfNeeded:_model];
    }
}

/// 返回所有拥有映射关系的键。
- (nullable NSArray<NSString *> *)_attachModelObserverIfNeeded:(id)model {
    if (model == nil) {
        return nil;
    }
    
    // 使用新 API：activelyObservedModelKeys
    NSArray<NSString *> * const observedKeys = [self.class activelyObservedModelKeys];
    
    // 情况 A: 不需要主动观察 → 不附加 KVO
    if (observedKeys == nil) {
        return nil;
    }
    
    _isActivelyObservingModelKeys = YES;
    
    // 没有映射关系，无法绑定
    XZMocoaKeyMappingTable * const table = [XZMocoaKeyMappingTable tableForClass:self.class];
    if (table == nil || table.keyToMethods.count == 0) {
        return nil;
    }
    
    // 半量绑定：只附加指定的键（ @link 绑定的键会自动排除 ）
    if (observedKeys.count > 0) {
        [[XZMocoaKeyObserver observerForModel:model] attachReceiver:self forKeys:observedKeys];
        return table.keyToMethods.allKeys;
    }
    
    // 全量绑定：附加 mappingObserverMethodsForModelKeys 中的所有键
    NSArray * const allKeys = table.keyToMethods.allKeys;
    [[XZMocoaKeyObserver observerForModel:model] attachReceiver:self forKeys:allKeys];
    return allKeys;
}
         
- (void)_detachModelObserverIfNeeded:(id)model {
    _isActivelyObservingModelKeys = NO;
    if (model == nil) {
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
    
    // 避免 self 从集合中移除就立即被释放了。
    XZMocoaViewModel * const subViewModel = self;
    [superViewModel->_subViewModels removeObject:subViewModel];
    [superViewModel didRemoveSubViewModel:subViewModel];
}

- (void)didRemoveSubViewModel:(__kindof XZMocoaViewModel *)viewModel {
    
}

@end


@implementation XZMocoaEvents

+ (instancetype)eventsWithKey:(NSString *)key value:(id)value source:(XZMocoaViewModel *)source {
    return [[self alloc] initWithKey:key value:value source:source];
}

- (instancetype)initWithKey:(NSString *)key value:(id)value source:(XZMocoaViewModel *)source {
    self = [super init];
    if (self) {
        _key    = key.copy ?: kNilKey;
        _value  = value;
        _source = source;
        _target = source;
    }
    return self;
}

@end


@implementation XZMocoaViewModel (XZMocoaKeyEventsChannel)

- (void)sendEventsWithKey:(XZMocoaKey)key value:(id)value {
    XZMocoaEvents * const events = [XZMocoaEvents eventsWithKey:key value:value source:self];
    [self sendEvents:events];
}

- (void)sendEvents:(XZMocoaEvents *)events {
    events->_target = self;
    id const receiver = self.superViewModel ?: _context;
    [receiver didReceiveEvents:events];
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
    [_targetActions addTarget:target action:action forKey:(key ?: kNilKey)];
}

- (void)sendActionsForKey:(XZMocoaKey)key value:(id)value {
    if (!self.isReady) return;
    if (value == nil) {
        value = (key == kNilKey ? nil : [self valueForKey:key]);
    } else if (value == (id)kCFNull) {
        value = nil;
    }
    [_targetActions sendActionsForKey:(key ?: kNilKey) value:value];
}

- (void)sendActionsForKey:(XZMocoaKey)key {
    [_targetActions sendActionsForKey:key value:nil];
}

- (void)removeTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
    [_targetActions removeTarget:target action:action forKey:key];
}

- (void)linkTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
    if (!self.isReady) return;
    if (target == nil || action == nil) {
        return;
    }
    if (key == nil) {
        key = kNilKey;
    }
    id const value = (key == kNilKey ? nil : [self valueForKey:key]);
    [XZMocoaAction sender:self target:target sendAction:action forKey:key value:value];
}

- (void)bindTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
    [self addTarget:target action:action forKey:key];
    [self linkTarget:target action:action forKey:key];
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

+ (NSArray<NSString *> *)activelyObservedModelKeys {
    return nil;
}

+ (NSDictionary<NSString *,id> *)mappingObserverMethodsForModelKeys {
    return nil;
}

- (BOOL)isActivelyObservingModelKeys {
    return _isActivelyObservingModelKeys;
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
    NSMutableArray                      * const parameters     = [NSMutableArray arrayWithCapacity:table.keyToMethods.count];
    
    for (NSString * const changeKey in changedKeys) {
        for (NSString * const methodName in table.keyToMethods[changeKey]) {
            if ([invokedMethods containsObject:methodName]) {
                continue;
            }
            [invokedMethods addObject:methodName];
            
            NSArray<NSString *> * const keys   = table.methodToKeys[methodName];
            XZObjcMethod        * const method = table.namedMethods[methodName];
            
            if (method == nil || keys.count != method.arguments.count) {
                continue;
            }
            
            for (NSString *key in keys) {
                id value = fetchedValues[key];
                if (value == nil) {
                    value = [model valueForKeyPath:key] ?: (id)kCFNull;
                    fetchedValues[key] = value;
                }
                [parameters addObject:value];
            }
            
            [method call:self parameters:parameters];
            [parameters removeAllObjects];
        }
    }
}

@end
