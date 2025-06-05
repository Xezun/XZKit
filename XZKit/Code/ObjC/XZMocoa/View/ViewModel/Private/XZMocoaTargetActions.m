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
    NSMutableDictionary<XZMocoaKey, NSMutableArray<XZMocoaTargetAction *> *> *_table;
    NSMutableDictionary<NSString *, XZMocoaTargetAction *> *_observers;
}

- (void)dealloc {
    
}

- (instancetype)initWithViewModel:(XZMocoaViewModel *)viewModel {
    self = [super init];
    if (self) {
        _viewModel = viewModel;
        _table = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
    NSMutableArray<XZMocoaTargetAction *> *targetActions = _table[key];
    if (targetActions == nil) {
        targetActions = [NSMutableArray array];
        _table[key] = targetActions;
    }
    XZMocoaTargetAction *targetAction = [[XZMocoaTargetAction alloc] initWithTarget:target action:action];
    [targetActions addObject:targetAction];
}

- (void)addTarget:(id)target handler:(XZMocoaTargetHandler)handler forKey:(XZMocoaKey)key {
    NSMutableArray<XZMocoaTargetAction *> *targetActions = _table[key];
    if (targetActions == nil) {
        targetActions = [NSMutableArray array];
        _table[key] = targetActions;
    }
    XZMocoaTargetAction *targetAction = [[XZMocoaTargetAction alloc] initWithTarget:target handler:handler];
    [targetActions addObject:targetAction];
    [targetAction sendActionWithValue:nil forKey:key sender:_viewModel];
}

- (void)removeTarget:(nullable id)target action:(nullable SEL)action forKey:(nullable XZMocoaKey)key {
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
- (void)_removeForKeyEvents:(XZMocoaKey)key {
    [_table[key] removeAllObjects];
}

/// 移除所有事件和行为
- (void)_removeAll {
    [_table removeAllObjects];
}

/// 移除 key 事件的 action 行为
- (void)_removeAction:(SEL)action forKey:(XZMocoaKey)key {
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
    for (XZMocoaKey key in _table) {
        [self _removeAction:action forKey:key];
    }
}

/// 移除 key 事件的 target 目标
- (void)_removeTarget:(id)target forKey:(XZMocoaKey)key {
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
    for (XZMocoaKey key in _table) {
        [self _removeTarget:target forKey:key];
    }
}

/// 移除 key 事件的 target 目标的 action 行为
- (void)_removeTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
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
    for (XZMocoaKey key in _table) {
        [self _removeTarget:target action:action forKey:key];
    }
}

- (void)sendActionsForKey:(XZMocoaKey)key value:(nullable)value {
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

#pragma mark - 模型监听方法关联

- (void)setAction:(SEL)action forModel:(id)model forKey:(NSString *)key {
    if (key == nil) {
        return;
    }
    if (action == nil) {
        if (_observers) {
            [_observers removeObjectForKey:key];
        }
        return;
    }
    if (_observers == nil) {
        _observers = [NSMutableDictionary dictionary];
    }
    XZMocoaTargetAction *observer = [[XZMocoaTargetAction alloc] initWithTarget:model action:action];
    _observers[key] = observer;
}

- (void)sendActionForModel:(id)model forKey:(NSString *)key value:(id)value {
    if (key == nil) {
        return;
    }
    XZMocoaTargetAction * const observer = _observers[key];
    
    id const target = observer.target;
    if (target == nil || target == model) {
        [observer sendActionForTarget:_viewModel forKey:key sender:model value:value];
    }
}

@end
