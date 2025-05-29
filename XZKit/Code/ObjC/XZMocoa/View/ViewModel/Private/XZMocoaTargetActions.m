//
//  XZMocoaTargetActions.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import "XZMocoaTargetActions.h"
@import ObjectiveC;

static void * _context = &_context;

/// stop 可能为 NULL
typedef void (^const XZMocoaRemoveBlock)(NSString *key, NSMutableArray<XZMocoaTargetAction *> *targetActions, BOOL *stop);

@implementation XZMocoaTargetActions {
    NSMutableDictionary<NSString *, NSMutableArray<XZMocoaTargetAction *> *> *_table;
    NSMutableDictionary<XZMocoaKey, NSNumber *> *_observers;
}

- (void)dealloc {
    for (XZMocoaKey const key in _observers) {
        [_viewModel removeObserver:self forKeyPath:key context:&_context];
    }
}

- (instancetype)initWithViewModel:(XZMocoaViewModel *)viewModel {
    self = [super init];
    if (self) {
        _viewModel = viewModel;
        _table = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forKey:(NSString *)key {
    NSMutableArray<XZMocoaTargetAction *> *targetActions = _table[key];
    if (targetActions == nil) {
        targetActions = [NSMutableArray array];
        _table[key] = targetActions;
    }
    XZMocoaTargetAction *targetAction = [[XZMocoaTargetAction alloc] initWithTarget:target action:action];
    [targetActions addObject:targetAction];
}

- (void)addTarget:(id)target handler:(XZMocoaTargetHandler)handler forKey:(NSString *)key {
    NSMutableArray<XZMocoaTargetAction *> *targetActions = _table[key];
    if (targetActions == nil) {
        targetActions = [NSMutableArray array];
        _table[key] = targetActions;
    }
    XZMocoaTargetAction *targetAction = [[XZMocoaTargetAction alloc] initWithTarget:target handler:handler];
    [targetActions addObject:targetAction];
    [targetAction sendActionWithValue:nil forKey:key sender:_viewModel];
}

- (void)removeTarget:(nullable id)target action:(nullable SEL)action forKey:(nullable NSString *)key {
    if (target == nil) {
        if (action == nil) {
            if (key == nil) {
                [self _removeAll];
            } else {
                [self _removeForKeyEvents:key];
            }
        } else {
            if (key == nil) {
                [self _removeAction:action];
            } else {
                [self _removeAction:action forKey:key];
            }
        }
    } else {
        if (action == NULL) {
            if (key == nil) {
                [self _removeTarget:target];
            } else {
                [self _removeTarget:target forKey:key];
            }
        } else {
            if (key == nil) {
                [self _removeTarget:target action:action];
            } else {
                [self _removeTarget:target action:action forKey:key];
            }
        }
    }
}

/// 移除 key 事件的所有行为
- (void)_removeForKeyEvents:(NSString *)key {
    [_table[key] removeAllObjects];
}

/// 移除所有事件和行为
- (void)_removeAll {
    [_table removeAllObjects];
}

/// 移除 key 事件的 action 行为
- (void)_removeAction:(SEL)action forKey:(NSString *)key {
    NSMutableArray<XZMocoaTargetAction *> * const targetActions = _table[key];
    [targetActions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *obj, NSUInteger idx, BOOL *stop) {
        id const target1 = obj.target;
        if (target1 == nil || obj.action == action) {
            [targetActions removeObjectAtIndex:idx];
        }
    }];
}

/// 移除所有事件的 action 行为
- (void)_removeAction:(SEL)action {
    for (NSString *key in _table) {
        [self _removeAction:action forKey:key];
    }
}

/// 移除 key 事件的 target 目标
- (void)_removeTarget:(id)target forKey:(NSString *)key {
    NSMutableArray<XZMocoaTargetAction *> * const targetActions = _table[key];
    [targetActions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *obj, NSUInteger idx, BOOL *stop) {
        id const target1 = obj.target;
        if (target1 == nil || target1 == target) {
            [targetActions removeObjectAtIndex:idx];
        }
    }];
}

/// 移除所有事件的 target 目标
- (void)_removeTarget:(id)target {
    for (NSString *key in _table) {
        [self _removeTarget:target forKey:key];
    }
}

/// 移除 key 事件的 target 目标的 action 行为
- (void)_removeTarget:(id)target action:(SEL)action forKey:(NSString *)key {
    NSMutableArray<XZMocoaTargetAction *> * const targetActions = _table[key];
    [targetActions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *obj, NSUInteger idx, BOOL *stop) {
        id const target1 = obj.target;
        if (target1 == nil || (target1 == target && obj.action == action)) {
            [targetActions removeObjectAtIndex:idx];
        }
    }];
}

/// 移除所有事件的 target 目标的 action 行为
- (void)_removeTarget:(id)target action:(SEL)action {
    for (NSString *key in _table) {
        [self _removeTarget:target action:action forKey:key];
    }
}

- (void)sendActionsForKey:(NSString *)key value:(nullable)value {
    NSMutableArray<XZMocoaTargetAction *> *targetActions = _table[key];
    id const sender = self.viewModel;
    [targetActions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *targetAction, NSUInteger idx, BOOL *stop) {
        id  const target = targetAction.target;
        if (target == nil) {
            [targetActions removeObjectAtIndex:idx]; // 删除 target 已销毁的监听
        } else {
            [targetAction sendActionWithValue:value forKey:key sender:sender];
        }
    }];
}

#if DEBUG

// 自动监听值并发送事件

- (void)addObserver:(NSObject *)observer forKey:(XZMocoaKey)key {
    if (_observers == nil) {
        _observers = [NSMutableDictionary dictionary];
    }
    NSNumber *number = _observers[key];
    if (number) {
        _observers[key] = @(number.integerValue + 1);
    } else {
        _observers[key] = @(1);
        [_viewModel addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:&_context];
    }
}

- (void)removeObserver:(NSObject *)observer forKey:(XZMocoaKey)key {
    if (_observers == nil) {
        return;
    }
    NSInteger const number = _observers[key].integerValue;
    if (number <= 1) {
        _observers[key] = nil;
        [_viewModel removeObserver:self forKeyPath:key context:&_context];
    } else {
        _observers[key] = @(number - 1);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (_context != context) {
        return;
    }
    id const newValue = change[NSKeyValueChangeNewKey];
    [self sendActionsForKey:keyPath value:newValue];
}

#endif

@end
