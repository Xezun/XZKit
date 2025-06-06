//
//  XZMocoaTargetActions.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import "XZMocoaTargetActions.h"
@import ObjectiveC;

@implementation XZMocoaTargetActions {
    NSMutableDictionary<XZMocoaKey, NSMutableArray<XZMocoaTargetAction *> *> *_table;
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
            [targetAction sender:sender sendActionForKey:key value:value];
        }
    }];
}

@end
