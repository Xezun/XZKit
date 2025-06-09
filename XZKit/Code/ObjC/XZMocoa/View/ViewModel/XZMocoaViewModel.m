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
@import XZObjcDescriptor;

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

+ (instancetype)viewModelWithURL:(NSURL *)URL model:(nullable id)model {
    XZMocoaModule * const module = [XZMocoaModule moduleForURL:URL];
    return [module instantiateViewModelWithModel:model];
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


XZMocoaUpdatesKey const XZMocoaUpdatesKeyNone     = @"none";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyReload   = @"reload";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyModify   = @"modify";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyInsert   = @"insert";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyDelete   = @"delete";
XZMocoaUpdatesKey const XZMocoaUpdatesKeySelect   = @"select";
XZMocoaUpdatesKey const XZMocoaUpdatesKeyDeselect = @"deselect";

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


XZMocoaKey const XZMocoaKeyNone             = @"XZMocoaKeyNone";
XZMocoaKey const XZMocoaKeyContentStatus    = @"contentStatus";
XZMocoaKey const XZMocoaKeyIsChecked        = @"isChecked";
XZMocoaKey const XZMocoaKeyText             = @"text";
XZMocoaKey const XZMocoaKeyAttributedText   = @"attributedText";
XZMocoaKey const XZMocoaKeyValue            = @"value";
XZMocoaKey const XZMocoaKeyImage            = @"image";
XZMocoaKey const XZMocoaKeyImageURL         = @"imageURL";
XZMocoaKey const XZMocoaKeyName             = @"name";
XZMocoaKey const XZMocoaKeyTitle            = @"title";
XZMocoaKey const XZMocoaKeyAttributedTitle  = @"attributedTitle";
XZMocoaKey const XZMocoaKeySubtitle         = @"subtitle";
XZMocoaKey const XZMocoaKeyTextColor        = @"textColor";
XZMocoaKey const XZMocoaKeyFont             = @"font";
XZMocoaKey const XZMocoaKeyDetailText       = @"detailText";
XZMocoaKey const XZMocoaKeyStartAnimating   = @"startAnimating";
XZMocoaKey const XZMocoaKeyStopAnimating    = @"stopAnimating";
XZMocoaKey const XZMocoaKeyIsRefreshing     = @"isRefreshing";
XZMocoaKey const XZMocoaKeyIsRequesting     = @"isRequesting";
XZMocoaKey const XZMocoaKeyIsLoading        = @"isLoading";

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
    if (!self.isReady) return;
    [_targetActions sendActionsForKey:(key ?: XZMocoaKeyNone) value:nil];
}

- (void)addTarget:(id)target action:(SEL)action forKey:(XZMocoaKey)key value:(nullable id)initialValue {
    [self addTarget:target action:action forKey:key];
    [self sendActionsForKey:key value:initialValue];
}

- (void)sendActionsForKey:(XZMocoaKey)key value:(id)value {
    if (!self.isReady) return;
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

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end


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

static NSArray<NSDictionary *> *XZMocoaGetMappingModelKeys(Class const VMClass);

@implementation XZMocoaViewModel (XZMocoaModelObserving)

+ (NSDictionary<NSString *,id> *)mappingModelKeys {
    return nil;
}

- (void)model:(id)model didUpdateValuesForKeys:(NSArray<NSString *> * const)changeKeys {
    NSArray * const mappingModelKeys = XZMocoaGetMappingModelKeys(self.class);
    if (mappingModelKeys == nil) {
        return;
    }
    
    NSDictionary * const _methodToKeys = mappingModelKeys[0];
    NSDictionary * const _keyToMethods = mappingModelKeys[1];
    NSDictionary * const _namedMethods = mappingModelKeys[2];
    
    NSMutableSet                        * const invokedMethods = [NSMutableSet setWithCapacity:_methodToKeys.count];
    NSMutableDictionary<NSString *, id> * const fetchedValues  = [NSMutableDictionary dictionaryWithCapacity:_keyToMethods.count];
    
    for (NSString * const changeKey in (changeKeys.count > 0 ? changeKeys : _keyToMethods.allKeys)) {
        for (NSString * const methodName in _keyToMethods[changeKey]) {
            if ([invokedMethods containsObject:methodName]) {
                continue;
            }
            [invokedMethods addObject:methodName];
            
            NSArray<NSString *>    * const keys   = _methodToKeys[methodName];
            XZObjcMethodDescriptor * const method = _namedMethods[methodName];
            
            if (method == nil || keys.count != method.argumentsTypes.count - 2) {
                continue;
            }
            
            NSMethodSignature * const signature  = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method.raw)];
            NSInvocation      * const invocation = [NSInvocation invocationWithMethodSignature:signature];
            
            invocation.target   = self;
            invocation.selector = method.selector;
            
            for (NSInteger i = 2; i < method.argumentsTypes.count; i++) {
                NSString * const key = keys[i - 2];
                
                id value = fetchedValues[key];
                if (value == nil) {
                    value = [model valueForKey:key];
                    fetchedValues[key] = value ?: (id)kCFNull;
                }
                if (value == (id)kCFNull) {
                    value = nil;
                }
                
                XZObjcTypeDescriptor *type = method.argumentsTypes[i];
                switch (type.type) {
                    case XZObjcTypeClass:
                    case XZObjcTypeObject: {
                        [invocation setArgument:&value atIndex:i];
                        break;
                    }
                    default: {
                        void *buffer = calloc(type.size, 1);
                        [(NSValue *)value getValue:buffer size:type.size];
                        [invocation setArgument:buffer atIndex:i];
                        free(buffer);
                        break;
                    }
                }
            }
            
            [invocation invoke];
        }
    }
}

@end

static inline void XZMocoaMappingKeyToMethod(NSMutableDictionary * const keyToMethods, NSString * const key, NSString * const methodName) {
    NSMutableSet *selectors = keyToMethods[key];
    if (selectors == nil) {
        selectors = [NSMutableSet set];
        keyToMethods[key] = selectors;
    }
    [selectors addObject:methodName];
}

static inline void XZMocoaMappingModelKeys(Class const VMClass, NSMutableDictionary * const methodToKeys, NSMutableDictionary * const keyToMethods, NSMutableDictionary * const namedMethods) {
    NSDictionary<NSString *, id> * const mappingModelKeys = [VMClass mappingModelKeys];
    if (mappingModelKeys.count == 0) {
        return;
    }
    
    [mappingModelKeys enumerateKeysAndObjectsUsingBlock:^(NSString * const methodName, id keyOrKeys, BOOL * _Nonnull stop) {
        SEL const selector = NSSelectorFromString(methodName);
        if (selector == NULL) {
            return;
        }
        // 方法是否已实现
        if (!class_respondsToSelector(VMClass, selector)) {
            return;
        }
        
        // 方法已存在映射
        if (methodToKeys[methodName]) {
            return;
        }
        
        XZObjcClassDescriptor * const descriptor = [XZObjcClassDescriptor descriptorWithClass:VMClass];
        namedMethods[methodName] = descriptor.methods[methodName];
        
        if ([keyOrKeys isKindOfClass:NSString.class]) {
            methodToKeys[methodName] = @[keyOrKeys];
            XZMocoaMappingKeyToMethod(keyToMethods, keyOrKeys, methodName);
        } else {
            methodToKeys[methodName] = keyOrKeys;
            for (NSString *key in keyOrKeys) {
                XZMocoaMappingKeyToMethod(keyToMethods, key, methodName);
            }
        }
    }];
}

static NSArray<NSDictionary *> *XZMocoaGetMappingModelKeys(Class const VMClass) {
    if (VMClass == [XZMocoaViewModel class]) {
        return nil;
    }
    
    static const void * const _key = &_key;
    
    NSArray *_modelMapping = objc_getAssociatedObject(VMClass, _key);
    if (_modelMapping) {
        return _modelMapping == (id)kCFNull ? nil : _modelMapping;
    }
    
    // 方法名 => 绑定的属性 method -> [key1, key2] 或 method -> [[key1,key2], [key3, key4]]
    NSMutableDictionary<NSString *, NSArray<NSString *> *> * const methodToKeys = [NSMutableDictionary dictionary];
    // 属性名 => 包含的方法 key -> [method1, method2]
    NSMutableDictionary<NSString *, NSSet<NSString *> *>   * const keyToMethods = [NSMutableDictionary dictionary];
    // 方法名 => 方法的描述 method -> XZObjcMethodDescriptor
    NSMutableDictionary<NSString *, NSSet<NSString *> *>   * const namedMethods = [NSMutableDictionary dictionary];
    
    NSArray *superMapping = XZMocoaGetMappingModelKeys(class_getSuperclass(VMClass));
    if ( superMapping ) {
        [methodToKeys addEntriesFromDictionary:superMapping[0]];
        [keyToMethods addEntriesFromDictionary:superMapping[1]];
        [namedMethods addEntriesFromDictionary:superMapping[2]];
    }
    XZMocoaMappingModelKeys(VMClass, methodToKeys, keyToMethods, namedMethods);
    
    _modelMapping = @[methodToKeys, keyToMethods, namedMethods];
    objc_setAssociatedObject(VMClass, _key, _modelMapping, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return _modelMapping;
}
