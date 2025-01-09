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

- (instancetype)initWithSender:(XZMocoaViewModel *)sender {
    self = [super init];
    if (self) {
        _sender = sender;
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
    // 绑定时，立即发送事件
    [targetAction sendActionForSender:self.sender forKey:key];
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

- (void)sendActionsForKey:(NSString *)key {
    NSMutableArray<XZMocoaTargetAction *> *targetActions = _table[key];
    id const sender = self.sender;
    [targetActions enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *targetAction, NSUInteger idx, BOOL *stop) {
        id  const target = targetAction.target;
        if (target == nil) {
            [targetActions removeObjectAtIndex:idx]; // 删除 target 已销毁的监听
        } else {
            [targetAction sendActionForSender:sender forKey:key];
        }
    }];
}

@end
