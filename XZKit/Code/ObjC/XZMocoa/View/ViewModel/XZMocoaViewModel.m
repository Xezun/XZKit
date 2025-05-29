//
//  XZMocoaViewModel.m
//  XZMocoa
//
//  Created by Xezun on 2021/4/10.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaViewModel.h"
#import "XZMocoaView.h"
#import "XZMocoaTargetActions.h"

@implementation XZMocoaViewModel {
    @private
    NSMutableOrderedSet<XZMocoaViewModel *> *_subViewModels;
    XZMocoaViewModel * __unsafe_unretained _superViewModel;
    XZMocoaTargetActions  *_targetActions;
    
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


@implementation XZMocoaUpdates

+ (instancetype)updatesWithKey:(NSString *)key value:(id)value source:(XZMocoaViewModel *)source {
    return [[self alloc] initWithKey:key value:value source:source];
}

- (instancetype)initWithKey:(NSString *)key value:(id)value source:(XZMocoaViewModel *)source {
    self = [super init];
    if (self) {
        _key = key.copy ?: XZMocoaUpdatesKeyNone;
        _value = value;
        _source = source;
        _target = source;
    }
    return self;
}

@end


XZMocoaUpdatesKey const XZMocoaUpdatesKeyNone     = @"";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyReload   = @"XZMocoaUpdatesKeyReload";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyModify   = @"XZMocoaUpdatesKeyModify";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyInsert   = @"XZMocoaUpdatesKeyInsert";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyDelete   = @"XZMocoaUpdatesKeyDelete";
XZMocoaUpdatesKey const XZMocoaUpdatesKeySelect   = @"XZMocoaUpdatesKeySelect";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyDidShow  = @"XZMocoaUpdatesKeyDidShow";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyDidHide  = @"XZMocoaUpdatesKeyDidHide";

@implementation XZMocoaViewModel (XZMocoaViewModelHierarchyEvents)

- (void)didReceiveUpdates:(XZMocoaUpdates *)updates {
    if (!self.isReady) return;
    updates.target = self;
    [self.superViewModel didReceiveUpdates:updates];
}

- (void)emitUpdatesForKey:(NSString *)key value:(id)value {
    if (!self.isReady) return;
    XZMocoaUpdates * const updates = [XZMocoaUpdates updatesWithKey:key value:value source:self];
    [self.superViewModel didReceiveUpdates:updates];
}

@end


XZMocoaKey const XZMocoaKeyNone = @"";

@implementation XZMocoaViewModel (XZMocoaViewModelTargetAction)

- (void)addTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
    if (target == nil || action == nil) {
        XZLog(@"为 target=%@ action=%@ 添加事件失败，参数不能为 nil", target, NSStringFromSelector(action));
        return;
    }
    
    if (_targetActions == nil) {
        _targetActions = [[XZMocoaTargetActions alloc] initWithViewModel:self];
    }
    [_targetActions addTarget:target action:action forKey:(key ?: XZMocoaKeyNone)];
}

- (void)removeTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key {
    [_targetActions removeTarget:target action:action forKey:key];
}

- (void)sendActionsForKey:(XZMocoaKey)key {
    [_targetActions sendActionsForKey:(key ?: XZMocoaKeyNone) value:nil];
}

- (void)addTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key value:(nullable id)initialValue {
    [self addTarget:target action:action forKey:key];
    [self sendActionsForKey:key value:initialValue];
}

- (void)sendActionsForKey:(XZMocoaKey)key value:(id)value {
    if (value == nil) {
        value = (key == XZMocoaKeyNone ? nil : [self valueForKey:key]);
    } else if (value == (id)kCFNull) {
        value = nil;
    }
    [_targetActions sendActionsForKey:(key ?: XZMocoaKeyNone) value:value];
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end

XZMocoaKey const XZMocoaKeyText             = @"text";
XZMocoaKey const XZMocoaKeyAttributedText   = @"attributedText";
XZMocoaKey const XZMocoaKeyValue            = @"value";
XZMocoaKey const XZMocoaKeyImage            = @"image";
XZMocoaKey const XZMocoaKeyName             = @"name";
XZMocoaKey const XZMocoaKeyTitle            = @"title";
XZMocoaKey const XZMocoaKeyAttributedTitle  = @"attributedTitle";
XZMocoaKey const XZMocoaKeySubtitle         = @"subtitle";
XZMocoaKey const XZMocoaKeyTextColor        = @"textColor";
XZMocoaKey const XZMocoaKeyFont             = @"font";
XZMocoaKey const XZMocoaKeyDetail           = @"detail";

@implementation XZMocoaViewModel (XZStoryboardSupporting)

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender {
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)sender) shouldPerformSegueWithIdentifier:identifier sender:nil];
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender {
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)sender) prepareForSegue:segue sender:nil];
    }
}

- (UIViewController *)viewController {
    return [_delegate viewModel:self viewController:NULL];
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    [self.viewController performSegueWithIdentifier:identifier sender:sender];
}

- (UINavigationController *)navigationController {
    return self.viewController.navigationController;
}

- (UITabBarController *)tabBarController {
    return self.viewController.tabBarController;
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
