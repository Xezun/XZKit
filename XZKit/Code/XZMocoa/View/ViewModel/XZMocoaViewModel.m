//
//  XZMocoaViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/4/10.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaViewModel.h"
#import "XZMocoaView.h"
#import "XZMocoaKeyedTargetActions.h"

@implementation XZMocoaViewModel {
    @private
    NSMutableOrderedSet<XZMocoaViewModel *> *_subViewModels;
    XZMocoaViewModel * __unsafe_unretained _superViewModel;
    XZMocoaKeyedTargetActions  *_keyedTargetActions;
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

- (instancetype)initWithModel:(id)model ready:(BOOL)synchronously {
    self = [self initWithModel:model];
    if (self) {
        if (synchronously) {
            [self ready];
        } else {
            [NSRunLoop.mainRunLoop performBlock:^{
                [self ready];
            }];
        }
    }
    return self;
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
    
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, isReady = %@; subViewModels = (%ld objects)>", self.class, self, @(self.isReady), self.subViewModels.count];
}

@end


@implementation XZMocoaViewModel (XZMocoaViewModelHierarchy)

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


@implementation XZMocoaEmition

+ (instancetype)emitionWithName:(NSString *)name value:(id)value source:(XZMocoaViewModel *)source {
    return [[self alloc] initWithName:name value:value source:source];
}

- (instancetype)initWithName:(NSString *)name value:(id)value source:(XZMocoaViewModel *)source {
    self = [super init];
    if (self) {
        _name = name.copy ?: XZMocoaEmitionNameDefault;
        _value = value;
        _source = source;
    }
    return self;
}

@end


NSString * const XZMocoaEmitionNameDefault = @"";
NSString * const XZMocoaEmitionNameUpdate = @"XZMocoaEmitionNameUpdate";

@implementation XZMocoaViewModel (XZMocoaViewModelHierarchyEmition)

- (void)emit:(NSString *)name value:(id)value {
    if (!self.isReady) return;
    XZMocoaEmition * const emition = [XZMocoaEmition emitionWithName:name value:value source:self];
    emition.target = self;
    [self.superViewModel didReceiveEmition:emition];
}

- (void)didReceiveEmition:(XZMocoaEmition *)emition {
    if (!self.isReady) return;
    emition.target = self;
    [self.superViewModel didReceiveEmition:emition];
}

@end



XZMocoaKeyEvents const XZMocoaKeyEventsNone = @"";

@implementation XZMocoaViewModel (XZMocoaViewModelKeyEvents)

- (void)addTarget:(id)target action:(SEL)action forKeyEvents:(NSString *)keyEvents {
    if (target == nil || action == nil) {
        XZLog(@"为 target=%@ action=%@ 添加事件失败，参数不能为 nil", target, NSStringFromSelector(action));
        return;
    }
    if (_keyedTargetActions == nil) {
        _keyedTargetActions = [[XZMocoaKeyedTargetActions alloc] initWithOwner:self];
    }
    [_keyedTargetActions addTarget:target action:action forKeyEvents:keyEvents ?: XZMocoaKeyEventsNone];
}

- (void)removeTarget:(id)target action:(SEL)action forKeyEvents:(nullable NSString *)keyEvents {
    [_keyedTargetActions removeTarget:target action:action forKeyEvents:keyEvents];
}

- (void)sendActionsForKeyEvents:(nullable NSString *)keyEvents {
    [_keyedTargetActions sendActionsForKeyEvents:keyEvents ?: XZMocoaKeyEventsNone];
}

@end



//#import "XZMocoaImageView.h"
//
//@interface XZMocoaObserver : NSObject
//@property (nonatomic, unsafe_unretained) XZMocoaViewModel *owner;
//- (instancetype)initWithOwner:(XZMocoaViewModel *)owner;
//- (void)addTarget:(id)target action:(XZMocoaAction)action forKey:(NSString *)key;
//- (void)removeAllTargets;
//@end
//
//@interface XZMocoaTargetAction : NSObject
//@property (nonatomic, copy) NSString *key;
//- (instancetype)initWithTarget:(id)target action:(XZMocoaAction)action key:(NSString *)key owner:(XZMocoaObserver *)owner;
//- (void)sendActionsForKeyValue:(id)newValue;
//@end
//
//@implementation XZMocoaViewModel (XZMocoaKeyValueBinding)
//
//- (void (^)(NSString *, id, XZMocoaAction))bind {
//    return ^(NSString * key, id target, XZMocoaAction action) {
//        NSParameterAssert(key && target && action);
//        if (self->_observer == nil) {
//            self->_observer = [[XZMocoaObserver alloc] initWithOwner:self];
//        }
//        [self->_observer addTarget:target action:action forKey:key];
//        action([self valueForKey:key], target, self);
//    };
//}
//
//@end
//
//static void *_observerContext = &_observerContext;
//
//@implementation XZMocoaObserver {
//    NSMutableDictionary<NSString *, NSMutableArray<XZMocoaTargetAction *> *> *_table;
//}
//
//- (void)removeAllTargets {
//    for (NSString *key in _table) {
//        [_owner removeObserver:self forKeyPath:key context:_observerContext];
//    }
//}
//
//- (instancetype)initWithOwner:(XZMocoaViewModel *)owner {
//    self = [super init];
//    if (self) {
//        _owner = owner;
//        _table = [NSMutableDictionary dictionary];
//    }
//    return self;
//}
//
//- (void)removeTargetAction:(XZMocoaTargetAction *)targetAction {
//    [_table[targetAction.key] removeObject:targetAction];
//}
//
//- (void)addTarget:(id)target action:(XZMocoaAction)action forKey:(NSString *)key {
//    NSMutableArray<XZMocoaTargetAction *> *targetActions = _table[key];
//    if (targetActions == nil) {
//        targetActions = [NSMutableArray array];
//        _table[key] = targetActions;
//        [_owner addObserver:self forKeyPath:key options:NSKeyValueObservingOptionNew context:_observerContext];
//    }
//
//    id targetAction = [[XZMocoaTargetAction alloc] initWithTarget:target action:action key:key owner:self];
//    [targetActions addObject:targetAction];
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    if (_observerContext != context) {
//        return;
//    }
//    for (XZMocoaTargetAction * const targetAction in _table[keyPath]) {
//        id newValue = change[NSKeyValueChangeNewKey];
//        if (newValue == NSNull.null) {
//            newValue = nil;
//        }
//        [targetAction sendActionsForKeyValue:newValue];
//    }
//}
//
//@end
//
//@interface XZMocoaTargetAction ()
//@property (nonatomic, unsafe_unretained) XZMocoaObserver *owner;
//@property (nonatomic, weak) id target;
//@property (nonatomic, copy) XZMocoaAction action;
//@end
//
//@implementation XZMocoaTargetAction
//
//- (instancetype)initWithTarget:(id)target action:(XZMocoaAction)action key:(NSString *)key owner:(XZMocoaObserver *)owner {
//    self = [super init];
//    if (self) {
//        _owner  = owner;
//        _key    = key.copy;
//        _target = target;
//        _action = action;
//    }
//    return self;
//}
//
//- (void)sendActionsForKeyValue:(id)newValue {
//    id const target = self.target;
//    if (target == nil) {
//        [self.owner removeTargetAction:self];
//    } else {
//        self.action(newValue, target, self.owner.owner);
//    }
//}
//
//@end
//
//void __mocoa_bind_3(XZMocoaViewModel *vm, SEL keySel, UILabel *target) XZ_ATTR_OVERLOAD {
//    NSString *key = NSStringFromSelector(keySel);
//    vm.bind(key, target, ^(id value, UILabel *self, id vm) {
//        self.text = value;
//    });
//}
//
//void __mocoa_bind_3(XZMocoaViewModel *vm, SEL keySel, UIImageView *target) XZ_ATTR_OVERLOAD {
//    NSString *key = NSStringFromSelector(keySel);
//    vm.bind(key, target, ^(id value, UIImageView *self, id vm) {
//        self.image = value;
//    });
//}
//
//void __mocoa_bind_4(XZMocoaViewModel *vm, SEL keySel, UILabel *target, id no) XZ_ATTR_OVERLOAD {
//    NSString *key = NSStringFromSelector(keySel);
//    vm.bind(key, target, ^(id value, UILabel *self, id vm) {
//        self.attributedText = value;
//    });
//}
//
//void __mocoa_bind_4(XZMocoaViewModel *vm, SEL keySel, UIImageView *target, id completion) XZ_ATTR_OVERLOAD {
//    NSString *key = NSStringFromSelector(keySel);
//    vm.bind(key, target, ^(id value, UIImageView<XZMocoaImageView> *self, id vm) {
//        [self xz_mocoa_setImageWithURL:value completion:completion];
//    });
//
//    [NSObject automaticallyNotifiesObserversForKey:nil];
//}
//
//void __mocoa_bind_5(XZMocoaViewModel *vm, SEL keySel, id target, SEL setter, id no) XZ_ATTR_OVERLOAD {
//    NSString *key = NSStringFromSelector(keySel);
//    vm.bind(key, target, ^(id value, NSObject *self, id vm) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//        [self performSelector:setter withObject:value];
//#pragma clang diagnostic pop
//    });
//}
//
//void __mocoa_bind_5(XZMocoaViewModel *vm, SEL keySel, id target, XZMocoaAction action, id no) XZ_ATTR_OVERLOAD {
//    vm.bind(NSStringFromSelector(keySel), target, action);
//}
