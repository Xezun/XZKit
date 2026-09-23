//
//  XZMocoaTargetActionTable.m
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import "XZMocoaTargetActionTable.h"
#import "XZMocoaTargetAction.h"
#import "XZObjc.h"
@import ObjectiveC;

@implementation XZMocoaTargetActionTable {
    NSMutableDictionary<XZMocoaKey, NSMutableArray<XZMocoaTargetAction *> *> *_keyedTargetTable;
}

- (instancetype)initWithViewModel:(XZMocoaViewModel *)viewModel {
    self = [super init];
    if (self) {
        _viewModel = viewModel;
        _keyedTargetTable = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
    NSMutableArray<XZMocoaTargetAction *> *targetTable = _keyedTargetTable[key];
    if (targetTable == nil) {
        targetTable = [NSMutableArray array];
        _keyedTargetTable[key] = targetTable;
    }
    XZMocoaTargetAction *targetObject = [XZMocoaTargetAction targetActionWithTarget:target selector:action];
    [targetTable addObject:targetObject];
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
    [_keyedTargetTable[key] removeAllObjects];
}

/// 移除所有事件和行为
- (void)_removeAll {
    [_keyedTargetTable removeAllObjects];
}

/// 移除 key 事件的 action 行为
- (void)_removeAction:(SEL)action forKey:(XZMocoaKey)key {
    NSMutableArray<XZMocoaTargetAction *> * const targetTable = _keyedTargetTable[key];
    [targetTable enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *targetObject, NSUInteger idx, BOOL *stop) {
        id const target = targetObject.target;
        if (target == nil || targetObject.action.selector == action) {
            [targetTable removeObjectAtIndex:idx];
        }
    }];
}

/// 移除所有事件的 action 行为
- (void)_removeAction:(SEL)action {
    for (XZMocoaKey key in _keyedTargetTable) {
        [self _removeAction:action forKey:key];
    }
}

/// 移除 key 事件的 target 目标
- (void)_removeTarget:(id)target forKey:(XZMocoaKey)key {
    NSMutableArray<XZMocoaTargetAction *> * const targetTable = _keyedTargetTable[key];
    [targetTable enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *targetObject, NSUInteger idx, BOOL *stop) {
        id const _target = targetObject.target;
        if (_target == nil || _target == target) {
            [targetTable removeObjectAtIndex:idx];
        }
    }];
}

/// 移除所有事件的 target 目标
- (void)_removeTarget:(id)target {
    for (XZMocoaKey key in _keyedTargetTable) {
        [self _removeTarget:target forKey:key];
    }
}

/// 移除 key 事件的 target 目标的 action 行为
- (void)_removeTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
    NSMutableArray<XZMocoaTargetAction *> * const targetTable = _keyedTargetTable[key];
    [targetTable enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction *targetObject, NSUInteger idx, BOOL *stop) {
        id const _target = targetObject.target;
        if (_target == nil || (_target == target && targetObject.action.selector == action)) {
            [targetTable removeObjectAtIndex:idx];
        }
    }];
}

/// 移除所有事件的 target 目标的 action 行为
- (void)_removeTarget:(id)target action:(SEL)action {
    for (XZMocoaKey key in _keyedTargetTable) {
        [self _removeTarget:target action:action forKey:key];
    }
}

- (void)sendActionsForKey:(XZMocoaKey)key value:(nullable)value {
    NSMutableArray<XZMocoaTargetAction *> * const targetTable = _keyedTargetTable[key];
    id const viewModel = self.viewModel;
    [targetTable enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(XZMocoaTargetAction * const targetAction, NSUInteger idx, BOOL *stop) {
        id const target = targetAction.target;
        if (target == nil) {
            [targetTable removeObjectAtIndex:idx]; // 删除 target 已销毁的监听
            return;
        }
        [targetAction viewModel:viewModel target:target sendActionForKey:key value:value];
    }];
}

@end
