//
//  XZMocoaModelObserver.m
//  XZMocoa
//
//  Created by Xezun on 2025/6/16.
//

#import "XZMocoaModelObserver.h"
#import "XZMocoaViewModel.h"
@import ObjectiveC;

static void * _context = &_context;

@implementation XZMocoaModelObserver {
    /// 被观察的对象。
    NSObject * __unsafe_unretained _model;
    /// 记录一个 runloop 中发生变更的所有键。
    NSMutableSet *_changedKeys;
    /// 视图模型 => 被观察的键。
    NSMapTable<XZMocoaViewModel *, NSMutableSet<NSString *> *> *_viewModels;
    /// 所有被观察的键 => 被观察的次数
    NSMutableDictionary<NSString *, NSNumber *>                *_observingKeys;
    /// 当前是否已经标记发生通知。
    BOOL _needsPostNotification;
}

+ (XZMocoaModelObserver *)observerForModel:(NSObject *)model {
    if (model == nil || model == (id)kCFNull) {
        return nil;
    }
    
    static void * _observer = NULL;
    XZMocoaModelObserver *observer = objc_getAssociatedObject(model, &_observer);
    if (observer) {
        return observer;
    }
    observer = [[XZMocoaModelObserver alloc] initWithModel:model];
    objc_setAssociatedObject(model, &_observer, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return observer;
}

- (instancetype)initWithModel:(NSObject *)model {
    self = [super init];
    if (self) {
        _model          = model;
        _viewModels     = [NSMapTable weakToStrongObjectsMapTable];
        _changedKeys    = [NSMutableSet set];
        _observingKeys  = [NSMutableDictionary dictionary];
        _needsPostNotification = NO;
    }
    return self;
}

- (void)attachReceiver:(XZMocoaViewModel *)viewModel forKeys:(NSArray<NSString *> * const)keys {
    if (keys.count == 0) {
        return;
    }
    
    NSMutableSet *observedKeys = (id)[_viewModels objectForKey:viewModel];
    
    if (observedKeys) {
        NSSet * const newKeys = [NSMutableSet setWithArray:keys];
        [(NSMutableSet *)newKeys minusSet:observedKeys];
        
        // 没有新增 key
        if (newKeys.count == 0) {
            return;
        }
        
        [self addObservingKeys:newKeys];
        [observedKeys unionSet:newKeys];
        
        [viewModel model:_model didChangeValuesForKeys:newKeys];
    } else {
        observedKeys = [NSMutableSet setWithArray:keys];
        
        [self addObservingKeys:observedKeys];
        [_viewModels setObject:observedKeys forKey:viewModel];
        
        [viewModel model:_model didChangeValuesForKeys:[NSSet setWithSet:observedKeys]];
    }
}

- (void)addObservingKeys:(NSSet<NSString *> * const)keys {
    for (NSString * const key in keys) {
        NSInteger const count = _observingKeys[key].integerValue;
        if (count == 0) {
            _observingKeys[key] = @(1);
            [_model addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:&_context];
        } else {
            _observingKeys[key] = @(count + 1);
        }
    }
}

- (void)detachReceiver:(XZMocoaViewModel *)viewModel {
    NSSet * const keys = [_viewModels objectForKey:viewModel];
    for (NSString * const key in keys) {
        NSInteger const count = _observingKeys[key].integerValue;
        if (count > 1) {
            _observingKeys[key] = @(count - 1);
        } else {
            _observingKeys[key] = nil;
            [_model removeObserver:self forKeyPath:key context:&_context];
        }
    }
    [_viewModels removeObjectForKey:viewModel];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context != &_context) {
        return;
    }
    [_changedKeys addObject:keyPath];
    [self setNeedsPostNotification];
}

- (void)setNeedsPostNotification {
    if (_needsPostNotification) {
        return;
    }
    _needsPostNotification = YES;
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [self postNotificationIfNeeded];
    }];
}

- (void)postNotificationIfNeeded {
    if (!_needsPostNotification) {
        return;
    }
    _needsPostNotification = NO;
    
    NSSet * const changedKeys = _changedKeys.copy;
    [_changedKeys removeAllObjects];
    
    for (XZMocoaViewModel * const viewModel in _viewModels) {
        NSSet *observedKeys = [_viewModels objectForKey:viewModel];
        
        if ([observedKeys intersectsSet:changedKeys]) {
            NSMutableSet *set = [NSMutableSet setWithSet:changedKeys];
            [set intersectSet:observedKeys];
            [viewModel model:_model didChangeValuesForKeys:set];
        }
    }
}

@end
