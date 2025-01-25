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
#else
#import "XZRuntime.h"
#import "NSArray+XZKit.h"
#endif

@implementation XZMocoaView
@dynamic viewModel;
@end

static const void * const _viewModel = &_viewModel;

static void xz_mocoa_copyMethod(Class const cls, SEL const target, SEL const source) {
    if (xz_objc_class_copyMethod(cls, source, nil, target)) return;
    XZLog(@"为协议 XZMocoaView 的方法 %@ 提供默认实现失败", NSStringFromSelector(target));
}

@interface XZMocoaOptions ()
- (instancetype)initWithURL:(nonnull NSURL *)url options:(nullable NSDictionary *)options;
@end


#pragma mark - XZMocoaView 协议默认实现

@interface UIResponder (XZMocoaView)
@end

@implementation UIResponder (XZMocoaView)

+ (void)load {
    if (self == [UIResponder class]) {
        xz_mocoa_copyMethod(self, @selector(viewModel), @selector(xz_mocoa_viewModel));
        xz_mocoa_copyMethod(self, @selector(setViewModel:), @selector(xz_mocoa_setViewModel:));
        xz_mocoa_copyMethod(self, @selector(viewModelWillChange), @selector(xz_mocoa_viewModelWillChange));
        xz_mocoa_copyMethod(self, @selector(viewModelDidChange), @selector(xz_mocoa_viewModelDidChange));
        
        xz_mocoa_copyMethod(self, @selector(viewController), @selector(xz_mocoa_viewController));
        xz_mocoa_copyMethod(self, @selector(navigationController), @selector(xz_mocoa_navigationController));
        xz_mocoa_copyMethod(self, @selector(tabBarController), @selector(xz_mocoa_tabBarController));
        
        xz_mocoa_copyMethod(self, @selector(shouldPerformSegueWithIdentifier:), @selector(xz_mocoa_shouldPerformSegueWithIdentifier:));
        xz_mocoa_copyMethod(self, @selector(prepareForSegue:), @selector(xz_mocoa_prepareForSegue:));
    }
}

- (UIViewController *)xz_mocoa_viewControllerImplementation {
    UIViewController *viewController = (id)self.nextResponder;
    while (viewController != nil) {
        if ([viewController isKindOfClass:UIViewController.class]) {
            return viewController;
        }
        viewController = (id)viewController.nextResponder;
    }
    return nil;
}

- (UIViewController *)xz_mocoa_viewController {
    return [self xz_mocoa_viewControllerImplementation];
}

- (UINavigationController *)xz_mocoa_navigationController {
    return [self xz_mocoa_viewControllerImplementation].navigationController;
}

- (UITabBarController *)xz_mocoa_tabBarController {
    return [self xz_mocoa_viewControllerImplementation].tabBarController;
}

- (XZMocoaViewModel *)xz_mocoa_viewModel {
    return objc_getAssociatedObject(self, _viewModel);
}

- (void)xz_mocoa_setViewModel:(XZMocoaViewModel *)viewModel {
    XZMocoaViewModel *oldValue = objc_getAssociatedObject(self, _viewModel);
    if (oldValue == nil && viewModel == nil) {
        return;
    }
    if ([oldValue isEqual:viewModel]) {
        return;
    }
    [(id<XZMocoaView>)self viewModelWillChange];
    // 在 viewModel 使用前（与 view 关联前），使其进入 isReady 状态
    [viewModel ready];
    objc_setAssociatedObject(self, _viewModel, viewModel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [(id<XZMocoaView>)self viewModelDidChange];
}

- (void)xz_mocoa_viewModelDidChange {
    
}

- (void)xz_mocoa_viewModelWillChange {
    
}

- (BOOL)xz_mocoa_shouldPerformSegueWithIdentifier:(NSString *)identifier {
    XZMocoaViewModel * const viewModel =  objc_getAssociatedObject(self, _viewModel);
    return [viewModel shouldPerformSegueWithIdentifier:identifier];
}

- (void)xz_mocoa_prepareForSegue:(UIStoryboardSegue *)segue {
    XZMocoaViewModel * const viewModel =  objc_getAssociatedObject(self, _viewModel);
    [viewModel prepareForSegue:segue];
}

@end



@interface UIViewController (XZMocoaView)
@end
@implementation UIViewController (XZMocoaView)

- (UIViewController *)xz_mocoa_viewControllerImplementation {
    return self;
}

// MARK: 转发控制器的 IB 事件给视图
// 如果 sender 为 MVVM 的视图，则将事件转发给视图 sender 处理。

+ (void)load {
    if (self == [UIViewController class]) {
        {
            SEL const selT = @selector(shouldPerformSegueWithIdentifier:sender:);
            SEL const selN = @selector(xz_mocoa_new_shouldPerformSegueWithIdentifier:sender:);
            SEL const selE = @selector(xz_mocoa_exchange_shouldPerformSegueWithIdentifier:sender:);
            if (xz_objc_class_addMethod(self, selT, nil, selN, NULL, selE)) {
                XZLog(@"为 UIViewController 重载方法 %@ 失败，相关事件请手动处理", NSStringFromSelector(selT));
            }
        } {
            SEL const selT = @selector(prepareForSegue:sender:);
            SEL const selN = @selector(xz_mocoa_new_prepareForSegue:sender:);
            SEL const selE = @selector(xz_mocoa_exchange_prepareForSegue:sender:);
            if (xz_objc_class_addMethod(self, selT, nil, selN, NULL, selE)) {
                XZLog(@"为 UIViewController 重载方法 %@ 失败，相关事件请手动处理", NSStringFromSelector(selT));
            }
        }
    }
}

- (BOOL)xz_mocoa_new_shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [sender shouldPerformSegueWithIdentifier:identifier];
    }
    return YES;
}

- (BOOL)xz_mocoa_exchange_shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [sender shouldPerformSegueWithIdentifier:identifier];
    }
    return [self xz_mocoa_exchange_shouldPerformSegueWithIdentifier:identifier sender:sender];;
}

- (void)xz_mocoa_new_prepareForSegue:(UIStoryboardSegue *)segue sender:(id<XZMocoaView>)sender {
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        [sender prepareForSegue:segue];
    }
}

- (void)xz_mocoa_exchange_prepareForSegue:(UIStoryboardSegue *)segue sender:(id<XZMocoaView>)sender {
    if ([sender conformsToProtocol:@protocol(XZMocoaView)]) {
        [sender prepareForSegue:segue];
    } else {
        [self xz_mocoa_exchange_prepareForSegue:segue sender:sender];
    }
}

@end



@implementation UIView (XZMocoaModuleSupporting)

+ (__kindof UIView *)viewWithMocoaURL:(NSURL *)url options:(NSDictionary *)options frame:(CGRect)frame {
    XZMocoaModule * const module = [XZMocoaModule moduleForURL:url];
    if (module == nil) {
        return nil;
    }
    switch (module.viewCategory) {
        case XZMocoaModuleViewCategoryClass: {
            XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithURL:url options:options];
            return [[module.viewClass alloc] initWithMocoaOptions:mocoaOptions frame:frame];
        }
        case XZMocoaModuleViewCategoryNib: {
            UINib *nib = [UINib nibWithNibName:module.viewNibName bundle:module.viewNibBundle];
            Class const ViewClass = module.viewNibClass ?: self.class;
            for (UIView *object in [nib instantiateWithOwner:nil options:nil]) {
                if ([object isKindOfClass:ViewClass]) {
                    XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithURL:url options:options];
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
    
    switch (module.viewCategory) {
        case XZMocoaModuleViewCategoryClass: {
            Class const ViewController = module.viewClass;
            if (![ViewController isSubclassOfClass:UIViewController.class]) {
                XZLog(@"模块 %@ 不是 UIViewController 模块，无法构造视图控制器", module);
                return nil;
            }
            XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithURL:url options:options];
            UIViewController * const viewController = [[ViewController alloc] initWithMocoaOptions:mocoaOptions nibName:nil bundle:nil];
            return viewController;
        }
        case XZMocoaModuleViewCategoryNib: {
            Class const ViewController = module.viewNibClass;
            if (![ViewController isSubclassOfClass:UIViewController.class]) {
                XZLog(@"模块 %@ 不是 UIViewController 模块，无法构造视图控制器", module);
                return nil;
            }
            NSString *nibName = module.viewNibName;
            NSBundle *bundle  = module.viewNibBundle;
            XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithURL:url options:options];
            UIViewController * const viewController = [[ViewController alloc] initWithMocoaOptions:mocoaOptions nibName:nibName bundle:bundle];
            return viewController;
        }
        case XZMocoaModuleViewCategoryStoryboard: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:module.viewStoryboardName bundle:module.viewStoryboardBundle];
            UIViewController *vc = nil;
            if (module.viewStoryboardIdentifier) {
                vc = [storyboard instantiateViewControllerWithIdentifier:module.viewStoryboardIdentifier];
            } else {
                vc = [storyboard instantiateInitialViewController];
            }
            return [vc isKindOfClass:self.class] ? vc : nil;
        }
        default:
            XZLog(@"模块 %@ 不是 UIViewController 模块，无法构造视图控制器", module);
            return nil;
    }
}

+ (__kindof UIViewController *)viewControllerWithMocoaURL:(NSURL *)url {
    return [self viewControllerWithMocoaURL:url options:nil];
}

- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options nibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    return [self initWithNibName:nibName bundle:bundle];
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

- (instancetype)initWithURL:(NSURL *)url options:(NSDictionary *)options {
    self = [super init];
    if (self) {
        _url = url;
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
