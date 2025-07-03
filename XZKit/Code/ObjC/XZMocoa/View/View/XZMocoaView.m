//
//  XZMocoaView.m
//  XZMocoa
//
//  Created by Xezun on 2021/4/12.
//

#import "XZMocoaView.h"
#import "XZMocoaDefines.h"
#if __has_include(<XZDefines/XZRuntime.h>)
#import <XZDefines/XZRuntime.h>
#import <XZExtensions/NSArray+XZKit.h>
#import <XZExtensions/UIView+XZKit.h>
#else
#import "XZRuntime.h"
#import "NSArray+XZKit.h"
#import "UIView+XZKit.h"
#endif
#import "XZLog.h"

static const void * const _viewModel = &_viewModel;

XZMocoaOptionKey const XZMocoaOptionKeyModel = @"model";
XZMocoaOptionKey const XZMocoaOptionKeyName = @"name";

@interface XZMocoaOptions ()
- (instancetype)initWithModule:(XZMocoaModule *)module url:(NSURL *)url options:(NSDictionary *)options;
@end


#pragma mark - XZMocoaView 协议默认实现

@implementation UIResponder (XZMocoaView)

- (__kindof XZMocoaViewModel *)viewModel {
    return objc_getAssociatedObject(self, _viewModel);
}

- (void)setViewModel:(__kindof XZMocoaViewModel * const )newValue {
    XZMocoaViewModel * const oldValue = objc_getAssociatedObject(self, _viewModel);
    if (oldValue == nil && newValue == nil) {
        return;
    }
    if ([oldValue isEqual:newValue]) {
        return;
    }
    [self viewModelWillChange:newValue];
    objc_setAssociatedObject(self, _viewModel, newValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self viewModelDidChange:oldValue];
}

- (UIViewController *)viewModel:(id<XZMocoaViewModel>)viewModel viewController:(void *)null {
    return nil;
}

- (void)viewModelWillChange:(XZMocoaViewModel *)newValue {
    newValue.delegate = self;
}

- (void)viewModelDidChange:(XZMocoaViewModel *)oldValue {
    [oldValue removeTarget:self action:nil forKey:nil];
    oldValue.delegate = nil;
}

@end

@implementation UIView (XZMocoaView)

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)self).viewModel shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)sender) shouldPerformSegueWithIdentifier:identifier sender:nil];
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([self conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)self).viewModel prepareForSegue:segue sender:sender];
    }
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)sender) prepareForSegue:segue sender:nil];
    }
}

- (UIViewController *)viewModel:(id<XZMocoaViewModel>)viewModel viewController:(void *)null {
    return self.xz_viewController;
}

- (void)viewModelWillChange:(XZMocoaViewModel *)newValue {
    // VM 与 V 应该是完全独立的，在 VM 与 V 关联之前，使其进入 ready 状态
    [newValue ready];
    [super viewModelWillChange:newValue];
}

@end


@implementation UIViewController (XZMocoaView)

// MARK: 转发控制器的 IB 事件给视图
// 如果 sender 为 MVVM 的视图，则将事件转发给视图 sender 处理。

+ (void)load {
    if (self == [UIViewController class]) {
        {
            SEL const selT = @selector(shouldPerformSegueWithIdentifier:sender:);
            SEL const selN = @selector(xz_mocoa_new_shouldPerformSegueWithIdentifier:sender:);
            SEL const selE = @selector(xz_mocoa_exchange_shouldPerformSegueWithIdentifier:sender:);
            if (!xz_objc_class_addMethod(self, selT, nil, selN, NULL, selE)) {
                XZLog(XZLogSystem.XZKit, @"为 UIViewController 重载方法 %@ 失败，相关事件请手动处理", NSStringFromSelector(selT));
            }
        } {
            SEL const selT = @selector(prepareForSegue:sender:);
            SEL const selN = @selector(xz_mocoa_new_prepareForSegue:sender:);
            SEL const selE = @selector(xz_mocoa_exchange_prepareForSegue:sender:);
            if (!xz_objc_class_addMethod(self, selT, nil, selN, NULL, selE)) {
                XZLog(XZLogSystem.XZKit, @"为 UIViewController 重载方法 %@ 失败，相关事件请手动处理", NSStringFromSelector(selT));
            }
        } {
            SEL const selT = @selector(viewDidLoad);
            SEL const selN = @selector(xz_mocoa_new_viewDidLoad);
            SEL const selE = @selector(xz_mocoa_exchange_viewDidLoad);
            if (!xz_objc_class_addMethod(self, selT, nil, selN, NULL, selE)) {
                XZLog(XZLogSystem.XZKit, @"为 UIViewController 重载方法 %@ 失败，相关事件请手动处理", NSStringFromSelector(selT));
            }
        }
    }
}

- (void)viewModelWillChange:(XZMocoaViewModel *)newValue {
    if (newValue && self.isViewLoaded) {
        [newValue ready];
    }
    [super viewModelWillChange:newValue];
}

- (UIViewController *)viewModel:(id<XZMocoaViewModel>)viewModel viewController:(void *)null {
    return self;
}

- (void)xz_mocoa_new_viewDidLoad {
    [self.viewModel ready];
}

- (void)xz_mocoa_exchange_viewDidLoad {
    [self xz_mocoa_exchange_viewDidLoad];
    [self.viewModel ready];
}

- (BOOL)xz_mocoa_new_shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)self).viewModel shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)sender) shouldPerformSegueWithIdentifier:identifier sender:nil];
    }
    return YES;
}

- (BOOL)xz_mocoa_exchange_shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([self conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)self).viewModel shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)sender) shouldPerformSegueWithIdentifier:identifier sender:nil];
    }
    return [self xz_mocoa_exchange_shouldPerformSegueWithIdentifier:identifier sender:sender];;
}

- (void)xz_mocoa_new_prepareForSegue:(UIStoryboardSegue *)segue sender:(id<XZMocoaView>)sender {
    if ([self conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)self).viewModel prepareForSegue:segue sender:sender];
    }
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)sender) prepareForSegue:segue sender:nil];
    }
}

- (void)xz_mocoa_exchange_prepareForSegue:(UIStoryboardSegue *)segue sender:(id<XZMocoaView>)sender {
    if ([self conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)self).viewModel prepareForSegue:segue sender:sender];
    }
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [((id<XZMocoaView>)sender) prepareForSegue:segue sender:nil];
    }
    return [self xz_mocoa_exchange_prepareForSegue:segue sender:sender];
}

@end



@implementation UIView (XZMocoaModuleSupporting)

+ (__kindof UIView *)viewWithMocoaURL:(NSURL *)url options:(NSDictionary *)options frame:(CGRect)frame {
    XZMocoaModule * const module = [XZMocoaModule moduleForURL:url];
    if (module == nil) {
        return nil;
    }
    switch (module.viewForm) {
        case XZMocoaModuleViewFormClass: {
            XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithModule:module url:url options:options];
            return [[module.viewClass alloc] initWithMocoaOptions:mocoaOptions frame:frame];
        }
        case XZMocoaModuleViewFormNib: {
            UINib *nib = [UINib nibWithNibName:module.viewNibName bundle:module.viewNibBundle];
            Class const ViewClass = module.viewNibClass ?: self.class;
            for (UIView *object in [nib instantiateWithOwner:nil options:nil]) {
                if ([object isKindOfClass:ViewClass]) {
                    XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithModule:module url:url options:options];
                    [object awakeFromNibWithMocoaOptions:mocoaOptions frame:frame];
                    return object;
                }
            }
            return nil;
        }
        default:
            return nil;
    }
}

+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options {
    return [self viewWithMocoaURL:url options:options frame:CGRectZero];
}

+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url frame:(CGRect)frame {
    return [self viewWithMocoaURL:url options:nil frame:frame];
}

+ (nullable __kindof UIView *)viewWithMocoaURL:(NSURL *)url {
    return [self viewWithMocoaURL:url options:nil frame:CGRectZero];
}

- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options frame:(CGRect)frame {
    return [self initWithFrame:frame];
}

- (void)awakeFromNibWithMocoaOptions:(XZMocoaOptions *)options frame:(CGRect)frame {
    self.frame = frame;
}

@end

@implementation UIViewController (XZMocoaModuleSupporting)

+ (__kindof UIViewController *)viewControllerWithMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options {
    XZMocoaModule *module = [XZMocoaModule moduleForURL:url];
    if (module == nil) {
        return nil;
    }
    
    switch (module.viewForm) {
        case XZMocoaModuleViewFormClass: {
            Class const ViewController = module.viewClass;
            if (![ViewController isSubclassOfClass:UIViewController.class]) {
                XZLog(XZLogSystem.XZKit, @"模块 %@ 不是 UIViewController 模块，无法构造视图控制器", module);
                return nil;
            }
            XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithModule:module url:url options:options];
            return [[ViewController alloc] initWithMocoaOptions:mocoaOptions nibName:nil bundle:nil];
        }
        case XZMocoaModuleViewFormNib: {
            Class const ViewController = module.viewNibClass;
            if (![ViewController isSubclassOfClass:UIViewController.class]) {
                XZLog(XZLogSystem.XZKit, @"模块 %@ 不是 UIViewController 模块，无法构造视图控制器", module);
                return nil;
            }
            NSString *nibName = module.viewNibName;
            NSBundle *bundle  = module.viewNibBundle;
            XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithModule:module url:url options:options];
            return [[ViewController alloc] initWithMocoaOptions:mocoaOptions nibName:nibName bundle:bundle];
        }
        case XZMocoaModuleViewFormStoryboard: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:module.viewStoryboardName bundle:module.viewStoryboardBundle];
            UIViewController *vc = nil;
            if (module.viewStoryboardIdentifier) {
                vc = [storyboard instantiateViewControllerWithIdentifier:module.viewStoryboardIdentifier];
            } else {
                vc = [storyboard instantiateInitialViewController];
            }
            if (![vc isKindOfClass:self]) {
                return nil;
            }
            XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithModule:module url:url options:options];
            return [vc didInitWithMocoaOptions:mocoaOptions];
        }
        default:
            XZLog(XZLogSystem.XZKit, @"模块 %@ 不是 UIViewController 模块，无法构造视图控制器", module);
            return nil;
    }
}

+ (__kindof UIViewController *)viewControllerWithMocoaURL:(NSURL *)url {
    return [self viewControllerWithMocoaURL:url options:nil];
}

- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options nibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    return [[self initWithNibName:nibName bundle:bundle] didInitWithMocoaOptions:options];
}

- (instancetype)didInitWithMocoaOptions:(XZMocoaOptions *)options {
    return self;
}

- (__kindof UIViewController *)presentMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options animated:(BOOL)flag completion:(void (^ _Nullable)(void))completion {
    UIViewController *nextVC = [UIViewController viewControllerWithMocoaURL:url options:options];
    if (nextVC != nil) {
        [self presentViewController:nextVC animated:flag completion:completion];
    }
    return nextVC;
}

- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary *)options completion:(void (^_Nullable)(void))completion {
    return [self presentMocoaURL:url options:options animated:YES completion:completion];
}

- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url options:(nullable NSDictionary *)options animated:(BOOL)animated {
    return [self presentMocoaURL:url options:options animated:animated completion:nil];
}

- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url animated:(BOOL)animated completion:(void (^_Nullable)(void))completion {
    return [self presentMocoaURL:url options:nil animated:animated completion:completion];
}

- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url animated:(BOOL)animated {
    return [self presentMocoaURL:url options:nil animated:animated completion:nil];
}

- (nullable __kindof UIViewController *)presentMocoaURL:(nullable NSURL *)url completion:(void (^_Nullable)(void))completion {
    return [self presentMocoaURL:url options:nil animated:nil completion:completion];
}

- (__kindof UIViewController *)presentViewControllerWithMocoaURL:(NSURL *)url animated:(BOOL)animated completion:(void (^)(void))completion {
    return [self presentMocoaURL:url animated:animated completion:completion];
}

- (__kindof UIViewController *)addChildMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options {
    UIViewController *nextVC = [UIViewController viewControllerWithMocoaURL:url options:options];
    if (nextVC != nil) {
        [self addChildViewController:nextVC];
    }
    return nextVC;
}

- (__kindof UIViewController *)addChildMocoaURL:(NSURL *)url {
    return [self addChildMocoaURL:url options:nil];
}

- (__kindof UIViewController *)addChildViewControllerWithMocoaURL:(NSURL *)url {
    return [self addChildMocoaURL:url];
}

@end



@implementation UINavigationController (XZMocoaModuleSupporting)

- (instancetype)initWithRootMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options {
    UIViewController *rootVC = [UIViewController viewControllerWithMocoaURL:url options:options];
    if (rootVC == nil) {
        return [self init];
    }
    return [self initWithRootViewController:rootVC];
}

- (instancetype)initWithRootMocoaURL:(NSURL *)url {
    return [self initWithRootMocoaURL:url options:nil];
}

- (instancetype)initWithRootViewControllerWithMocoaURL:(NSURL *)url {
    return [self initWithRootMocoaURL:url];
}

- (__kindof UIViewController *)pushMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options animated:(BOOL)animated {
    UIViewController *nextVC = [UIViewController viewControllerWithMocoaURL:url options:options];
    if (nextVC != nil) {
        [self pushViewController:nextVC animated:animated];
    }
    return nextVC;
}

- (__kindof UIViewController *)pushMocoaURL:(NSURL *)url options:(NSDictionary *)options {
    return [self pushMocoaURL:url options:options animated:YES];
}

- (__kindof UIViewController *)pushMocoaURL:(NSURL *)url animated:(BOOL)animated {
    return [self pushMocoaURL:url options:nil animated:animated];
}

- (__kindof UIViewController *)pushViewControllerWithMocoaURL:(NSURL *)url animated:(BOOL)animated {
    return [self pushMocoaURL:url animated:animated];
}

@end



@implementation UITabBarController (XZMocoaModuleSupporting)

- (NSArray<__kindof UIViewController *> *)setMocoaURLs:(NSArray<NSURL *> *)urls animated:(BOOL)animated {
    NSArray *viewControllers = [urls xz_compactMap:^id(NSURL *url, NSInteger idx, BOOL *stop) {
        return [UIViewController viewControllerWithMocoaURL:url];
    }];
    [self setViewControllers:viewControllers animated:animated];
    return viewControllers;
}

- (NSArray<__kindof UIViewController *> *)setViewControllersWithMocoaURLs:(NSArray<NSURL *> *)urls animated:(BOOL)animated {
    return [self setMocoaURLs:urls animated:animated];
}

@end


@implementation XZMocoaOptions {
    NSURL *_url;
    NSMutableDictionary *_options;
    NSURLComponents *_components;
}

- (instancetype)initWithModule:(XZMocoaModule *)module url:(NSURL *)url options:(NSDictionary *)options {
    self = [super init];
    if (self) {
        _url = url;
        _module = module;
        _options = options.mutableCopy;
    }
    return self;
}

- (NSURL *)url {
    return _url;
}

- (NSDictionary *)options {
    [self mergesURLQuery];
    return _options;
}

- (BOOL)containsKey:(NSString *)aKey {
    return self[aKey] || _options[aKey];
}

- (id)valueForKey:(NSString *)key {
    return [self objectForKeyedSubscript:key];
}

- (id)objectForKeyedSubscript:(NSString *)key {
    // 直接读值
    id value = _options[key];
    if (value != nil) {
        return value == NSNull.null ? nil : value;
    }
    
    // 合并参数
    if ([self mergesURLQuery]) {
        return nil;
    }
    
    // 重新读值
    value = _options[key];
    return value == NSNull.null ? nil : value;
}

- (BOOL)mergesURLQuery {
    if (_components) {
        return YES;
    }
    _components = [NSURLComponents componentsWithURL:_url resolvingAgainstBaseURL:NO];
    NSArray<NSURLQueryItem *> * const queryItems = _components.queryItems;
    NSMutableDictionary *keyedValues = [NSMutableDictionary dictionaryWithCapacity:queryItems.count];
    [queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *       const name     = obj.name;
        id               const newValue = obj.value ?: NSNull.null;
        NSMutableArray * const oldValue = keyedValues[name];
        if (oldValue == nil) {
            keyedValues[name] = newValue;
        } else if ([oldValue isKindOfClass:NSMutableArray.class]) {
            [oldValue addObject:newValue];
        } else {
            keyedValues[name] = [NSMutableArray arrayWithObjects:oldValue, newValue, nil];
        }
    }];
    if (_options == nil) {
        _options = keyedValues;
    } else {
        [keyedValues enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            if (!_options[key]) {
                _options[key] = obj;
            }
        }];
    }
    return NO;
}

@end
