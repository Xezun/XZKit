//
//  XZMocoaKeyedTargetActions.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import "XZMocoaKeyedTargetActions.h"
#import "XZMocoaTargetAction.h"

/// stop 可能为 NULL
typedef void (^const XZMocoaRemoveBlock)(NSString *key, NSMutableArray<XZMocoaTargetAction *> *targetActions, BOOL *stop);

@implementation XZMocoaKeyedTargetActions {
    NSMutableDictionary<NSString *, NSMutableArray<XZMocoaTargetAction *> *> *_table;
}

- (instancetype)initWithOwner:(XZMocoaViewModel *)owner {
    self = [super init];
    if (self) {
        _owner = owner;
        _table = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forKeyEvents:(NSString *)keyEvents {
    NSMutableArray<XZMocoaTargetAction *> *targetActions = _table[keyEvents];
    if (targetActions == nil) {
        targetActions = [NSMutableArray array];
        _table[keyEvents] = targetActions;
    }
    XZMocoaTargetAction *targetAction = [[XZMocoaTargetAction alloc] initWithTarget:target action:action];
    [targetActions addObject:targetAction];
    // 绑定时，立即发送事件
    [targetAction sendActionWithObject:self.owner forKeyEvents:keyEvents];
}

- (void)removeTarget:(nullable id)target action:(nullable SEL)action forKeyEvents:(nullable NSString *)keyEvents {
    if (target == nil) {
        if (action == nil) {
            if (keyEvents == nil) {
                [self _removeAll];
            } else {
                [self _removeForKeyEvents:keyEvents];
            }
        } else {
            if (keyEvents == nil) {
                [self _removeAction:action];
            } else {
                [self _removeAction:action forKeyEvents:keyEvents];
            }
        }
    } else {
        if (action == NULL) {
            if (keyEvents == nil) {
                [self _removeTarget:target];
            } else {
                [self _removeTarget:target forKeyEvents:keyEvents];
            }
        } else {
            if (keyEvents == nil) {
                [self _removeTarget:target action:action];
            } else {
                [self _removeTarget:target action:action forKeyEvents:keyEvents];
            }
        }
    }
}

/// 移除 keyEvents 事件的所有行为
- (void)_removeForKeyEvents:(NSString *)keyEvents {
    [_table[keyEvents] removeAllObjects];
}

/// 移除所有事件和行为
- (void)_removeAll {
    [_table removeAllObjects];
}

/// 移除 keyEvents 事件的 action 行为
- (void)_removeAction:(SEL)action forKeyEvents:(NSString *)keyEvents {
    NSMutableArray<XZMocoaTargetAction *> * const targetActions = _table[keyEvents];
    [targetActions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *obj, NSUInteger idx, BOOL *stop) {
        id const target1 = obj.target;
        if (target1 == nil || obj.action == action) {
            [targetActions removeObjectAtIndex:idx];
        }
    }];
}

/// 移除所有事件的 action 行为
- (void)_removeAction:(SEL)action {
    for (NSString *keyEvents in _table) {
        [self _removeAction:action forKeyEvents:keyEvents];
    }
}

/// 移除 keyEvents 事件的 target 目标
- (void)_removeTarget:(id)target forKeyEvents:(NSString *)keyEvents {
    NSMutableArray<XZMocoaTargetAction *> * const targetActions = _table[keyEvents];
    [targetActions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *obj, NSUInteger idx, BOOL *stop) {
        id const target1 = obj.target;
        if (target1 == nil || target1 == target) {
            [targetActions removeObjectAtIndex:idx];
        }
    }];
}

/// 移除所有事件的 target 目标
- (void)_removeTarget:(id)target {
    for (NSString *keyEvents in _table) {
        [self _removeTarget:target forKeyEvents:keyEvents];
    }
}

/// 移除 keyEvents 事件的 target 目标的 action 行为
- (void)_removeTarget:(id)target action:(SEL)action forKeyEvents:(NSString *)keyEvents {
    NSMutableArray<XZMocoaTargetAction *> * const targetActions = _table[keyEvents];
    [targetActions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *obj, NSUInteger idx, BOOL *stop) {
        id const target1 = obj.target;
        if (target1 == nil || (target1 == target && obj.action == action)) {
            [targetActions removeObjectAtIndex:idx];
        }
    }];
}

/// 移除所有事件的 target 目标的 action 行为
- (void)_removeTarget:(id)target action:(SEL)action {
    for (NSString *keyEvents in _table) {
        [self _removeTarget:target action:action forKeyEvents:keyEvents];
    }
}

- (void)sendActionsForKeyEvents:(NSString *)keyEvents {
    NSMutableArray<XZMocoaTargetAction *> *targetActions = _table[keyEvents];
    [targetActions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *targetAction, NSUInteger idx, BOOL *stop) {
        id  const target = targetAction.target;
        if (target == nil) {
            [targetActions removeObjectAtIndex:idx]; // 删除 target 已销毁的监听
        } else {
            [targetAction sendActionWithObject:self.owner forKeyEvents:keyEvents];
        }
    }];
}

@end
