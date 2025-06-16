//
//  XZMocoaObserver.m
//  XZMocoa
//
//  Created by 徐臻 on 2025/6/16.
//

#import "XZMocoaObserver.h"
#import "XZMocoaViewModel.h"
@import ObjectiveC;

static void * _context = &_context;

@implementation XZMocoaObserver {
    NSObject     * __unsafe_unretained _model;
    NSMapTable<XZMocoaViewModel *, NSArray *>   *_viewModels;
    NSMutableSet                                *_changedKeys;
    NSMutableDictionary<NSString *, NSNumber *> *_observedKeys;
    BOOL _needsNotification;
}

+ (XZMocoaObserver *)observerForModel:(NSObject *)model {
    id observer = objc_getAssociatedObject(model, &_context);
    if (observer) {
        return observer;
    }
    observer = [[self alloc] initWithModel:model];
    objc_setAssociatedObject(model, &_context, observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return observer;
}

- (instancetype)initWithModel:(NSObject *)model {
    self = [super init];
    if (self) {
        _model       = model;
        _viewModels  = [NSMapTable weakToStrongObjectsMapTable];
        _changedKeys = [NSMutableSet set];
        _needsNotification = NO;
    }
    return self;
}

- (void)addViewModel:(XZMocoaViewModel * const)viewModel forKeys:(NSArray<NSString *> * const)keys {
    [_viewModels setObject:keys.copy forKey:viewModel];
    for (NSString * const key in keys) {
        NSInteger const count = _observedKeys[key].integerValue;
        if (count == 0) {
            [_model addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:&_context];
            _observedKeys[key] = @(1);
        } else {
            _observedKeys[key] = @(count + 1);
        }
    }
}

- (void)removeViewModel:(XZMocoaViewModel * const)viewModel {
    NSArray * const keys = [_viewModels objectForKey:viewModel];
    for (NSString * const key in keys) {
        NSInteger const count = _observedKeys[key].integerValue;
        if (count > 1) {
            _observedKeys[key] = @(count - 1);
        } else {
            _observedKeys[key] = nil;
            [_model removeObserver:self forKeyPath:key context:&_context];
        }
    }
    [_viewModels removeObjectForKey:viewModel];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    [_changedKeys addObject:keyPath];
    [self setNeedsNotification];
}

- (void)setNeedsNotification {
    if (_needsNotification) {
        return;
    }
    _needsNotification = YES;
    [NSRunLoop.mainRunLoop performInModes:@[NSRunLoopCommonModes] block:^{
        [self notificationIfNeeded];
    }];
}

- (void)notificationIfNeeded {
    if (!_needsNotification) {
        return;
    }
    _needsNotification = NO;
    
    NSSet * const changedKeys = _changedKeys.copy;
    [_changedKeys removeAllObjects];
    
    for (XZMocoaViewModel * const viewModel in _viewModels) {
        [viewModel model:_model didUpdateValuesForKeys:changedKeys];
    }
}

@end

