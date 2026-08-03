//
//  XZMocoaView.m
//  XZMocoa
//
//  Created by Xezun on 2021/4/12.
//

#import "XZMocoaView.h"
#import "XZMocoaDefines.h"
#import "XZRuntime.h"
#import "NSArray+XZKit.h"
#import "UIView+XZKit.h"
@import ObjectiveC;

XZMocoaKey const XZMocoaKeyModel      = @"model";
XZMocoaKey const XZMocoaKeyName       = @"name";
XZMocoaKey const XZMocoaKeyValue      = @"value";
XZMocoaKey const XZMocoaKeyIdentifier = @"identifier";
XZMocoaKey const XZMocoaKeyDelegate   = @"delegate";

static const void * const _viewModel = &_viewModel;
static const void * const _context = &_context;

@interface XZMocoaOptions ()
- (instancetype)initWithModule:(XZMocoaModule *)module url:(NSURL *)url options:(NSDictionary *)options;
@end

@interface XZMocoaContext : NSObject <XZMocoaContext>
@property (nonatomic, strong, nullable) XZMocoaViewModel *viewModel;
+ (XZMocoaContext *)contextForView:(nonnull UIResponder *)view;
- (void)detach:(nonnull XZMocoaViewModel *)viewModel;
- (void)attach:(nonnull XZMocoaViewModel *)viewModel;
@end

#pragma mark - XZMocoaView

@implementation UIResponder (XZMocoaView)

- (__kindof XZMocoaViewModel *)viewModel {
    return [XZMocoaContext contextForView:self].viewModel;
}

- (void)setViewModel:(__kindof XZMocoaViewModel * const )newValue {
    [XZMocoaContext contextForView:self].viewModel = newValue;
}

- (void)viewModelWillChange:(XZMocoaViewModel *)newValue {
    
}

- (void)viewModelDidChange:(XZMocoaViewModel *)oldValue {
    
}

- (void)prepareForViewModel {
    
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

- (void)sendEventsWithKey:(XZMocoaKey)name value:(id)value {
    XZMocoaEvents * const events = [XZMocoaEvents eventsWithName:name value:value source:self];
    [self.viewModel didReceiveEvents:events];
}

@end

@implementation UIView (XZMocoaView)

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    return [self.viewModel shouldPerformSegueWithIdentifier:identifier sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self.viewModel prepareForSegue:segue sender:sender];
}

- (void)viewModelDidChange:(XZMocoaViewModel *)oldValue {
    [super viewModelDidChange:oldValue];
    [self prepareForViewModel];
}

- (void)prepareForViewModel {
    [super prepareForViewModel];
    [self.viewModel ready];
}

@end

@implementation UIViewController (XZMocoaView)

// MARK: 转发控制器的 IB 事件给视图
// 如果 sender 为 MVVM 的视图，则将事件转发给视图 sender 处理。

+ (void)load {
    if (self == [UIViewController class]) {
        {
            SEL const selT = @selector(shouldPerformSegueWithIdentifier:sender:);
            SEL const selN = @selector(xz_mocoa_override_shouldPerformSegueWithIdentifier:sender:);
            SEL const selE = @selector(xz_mocoa_exchange_shouldPerformSegueWithIdentifier:sender:);
            if (!xz_objc_class_addMethod(self, selT, nil, selN, NULL, selE)) {
                NSLog(@"为 UIViewController 重载方法 %@ 失败，相关事件请手动处理", NSStringFromSelector(selT));
            }
        } {
            SEL const selT = @selector(prepareForSegue:sender:);
            SEL const selN = @selector(xz_mocoa_override_prepareForSegue:sender:);
            SEL const selE = @selector(xz_mocoa_exchange_prepareForSegue:sender:);
            if (!xz_objc_class_addMethod(self, selT, nil, selN, NULL, selE)) {
                NSLog(@"为 UIViewController 重载方法 %@ 失败，相关事件请手动处理", NSStringFromSelector(selT));
            }
        } {
            SEL const selT = @selector(viewDidLoad);
            SEL const selN = @selector(xz_mocoa_override_viewDidLoad);
            SEL const selE = @selector(xz_mocoa_exchange_viewDidLoad);
            if (!xz_objc_class_addMethod(self, selT, nil, selN, NULL, selE)) {
                NSLog(@"为 UIViewController 重载方法 %@ 失败，相关事件请手动处理", NSStringFromSelector(selT));
            }
        }
    }
}

- (void)viewModelDidChange:(XZMocoaViewModel *)oldValue {
    [super viewModelDidChange:oldValue];
    if (self.isViewLoaded) {
        [self prepareForViewModel];
    }
}

- (void)prepareForViewModel {
    [super prepareForViewModel];
    [self.viewModel ready];
}

- (UIViewController *)viewModel:(id<XZMocoaViewModel>)viewModel viewController:(void *)null {
    return self;
}

- (void)xz_mocoa_override_viewDidLoad {
    [self prepareForViewModel];
}

- (void)xz_mocoa_exchange_viewDidLoad {
    [self xz_mocoa_exchange_viewDidLoad];
    [self prepareForViewModel];
}

// 不太可能
- (BOOL)xz_mocoa_override_shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (sender && (id)sender != self && [sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [sender shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    if ([self conformsToProtocol:@protocol(XZMocoaView)]) {
        return [self.viewModel shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    return xz_objc_msgSendSuper_bool(self, UIViewController.class, @selector(shouldPerformSegueWithIdentifier:sender:), identifier, sender);
}

- (BOOL)xz_mocoa_exchange_shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    // 优先转发给 sender
    if (sender && (id)sender != self && [sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [sender shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    // 转发给控制器的 viewModel
    if ([self conformsToProtocol:@protocol(XZMocoaView)]) {
        return [self.viewModel shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
    // 默认
    return [self xz_mocoa_exchange_shouldPerformSegueWithIdentifier:identifier sender:sender];;
}

// 不太可能
- (void)xz_mocoa_override_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender && (id)sender != self && [sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [sender prepareForSegue:segue sender:sender];
    }
    if ([self conformsToProtocol:@protocol(XZMocoaView)]) {
        return [self.viewModel prepareForSegue:segue sender:sender];
    }
    return xz_objc_msgSendSuper_void(self, UIViewController.class, @selector(prepareForSegue:sender:), segue, sender);
}

- (void)xz_mocoa_exchange_prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender && (id)sender != self && [sender conformsToProtocol:@protocol(XZMocoaView)]) {
        return [sender prepareForSegue:segue sender:sender];
    }
    if ([self conformsToProtocol:@protocol(XZMocoaView)]) {
        return [self.viewModel prepareForSegue:segue sender:sender];
    }
    return [self xz_mocoa_exchange_prepareForSegue:segue sender:sender];
}

@end

@implementation UINavigationController (XZMocoaView)
@end

@implementation UITabBarController (XZMocoaView)
@end


#pragma mark - XZMocoaModuleSupporting

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
                NSLog(@"模块 %@ 不是 UIViewController 模块，无法构造视图控制器", module);
                return nil;
            }
            XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithModule:module url:url options:options];
            return [[ViewController alloc] initWithMocoaOptions:mocoaOptions nibName:nil bundle:nil];
        }
        case XZMocoaModuleViewFormNib: {
            Class const ViewController = module.viewNibClass;
            if (![ViewController isSubclassOfClass:UIViewController.class]) {
                NSLog(@"模块 %@ 不是 UIViewController 模块，无法构造视图控制器", module);
                return nil;
            }
            NSString *nibName = module.viewNibName;
            NSBundle *bundle  = module.viewNibBundle;
            XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithModule:module url:url options:options];
            return [[ViewController alloc] initWithMocoaOptions:mocoaOptions nibName:nibName bundle:bundle];
        }
        case XZMocoaModuleViewFormStoryboard: {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:module.viewStoryboardName bundle:module.viewStoryboardBundle];
            UIViewController *viewController = nil;
            if (module.viewStoryboardIdentifier) {
                viewController = [storyboard instantiateViewControllerWithIdentifier:module.viewStoryboardIdentifier];
            } else {
                viewController = [storyboard instantiateInitialViewController];
            }
            if (![viewController isKindOfClass:self]) {
                return nil;
            }
            XZMocoaOptions * const mocoaOptions = [[XZMocoaOptions alloc] initWithModule:module url:url options:options];
            [viewController didInitWithMocoaOptions:mocoaOptions];
            return viewController;
        }
        default:
            NSLog(@"模块 %@ 不是 UIViewController 模块，无法构造视图控制器", module);
            return nil;
    }
}

+ (__kindof UIViewController *)viewControllerWithMocoaURL:(NSURL *)url {
    return [self viewControllerWithMocoaURL:url options:nil];
}

- (instancetype)initWithMocoaOptions:(XZMocoaOptions *)options nibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    UIViewController * const viewController = [self initWithNibName:nibName bundle:bundle];
    [viewController didInitWithMocoaOptions:options];
    return viewController;
}

- (void)didInitWithMocoaOptions:(XZMocoaOptions *)options {
    if (self.viewModel) {
        return;
    }
    
    XZMocoaModule * const module = options.module;
    
    Class const ViewModelClass = module.viewModelClass;
    if (!ViewModelClass) {
        return;
    }
    
    id model = options[XZMocoaKeyModel];
    
    Class const ModelClass = module.modelClass;
    if (ModelClass) {
        if (![model isKindOfClass:ModelClass]) {
            model = [[ModelClass alloc] init];
        }
    }
    
    XZMocoaViewModel *viewModel = [[ViewModelClass alloc] initWithModel:model];
    viewModel.module = module;
    self.viewModel = viewModel;
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

- (__kindof UIViewController *)addChildViewControllerWithMocoaURL:(NSURL *)url options:(nullable NSDictionary *)options {
    UIViewController *nextVC = [UIViewController viewControllerWithMocoaURL:url options:options];
    if (nextVC != nil) {
        [self addChildViewController:nextVC];
    }
    return nextVC;
}

- (__kindof UIViewController *)addChildViewControllerWithMocoaURL:(NSURL *)url {
    return [self addChildViewControllerWithMocoaURL:url options:nil];
}

@end

@implementation UINavigationController (XZMocoaModuleSupporting)

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

- (NSArray<__kindof UIViewController *> *)setViewControllersWithMocoaURLs:(NSArray<NSURL *> *)urls animated:(BOOL)animated {
    NSArray *viewControllers = [urls xz_compactMap:^id(NSURL *url, NSInteger idx, BOOL *stop) {
        return [UIViewController viewControllerWithMocoaURL:url];
    }];
    [self setViewControllers:viewControllers animated:animated];
    return viewControllers;
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
        return value == (id)kCFNull ? nil : value;
    }
    
    // 合并参数
    if ([self mergesURLQuery]) {
        return nil;
    }
    
    // 重新读值
    value = _options[key];
    return value == (id)kCFNull ? nil : value;
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
        id               const newValue = obj.value ?: (id)kCFNull;
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

@implementation XZMocoaContext {
    UIResponder    * __unsafe_unretained _view;
    XZMocoaContext * __unsafe_unretained _next;
}

- (void)dealloc {
    [self detach:_viewModel];
    [_viewModel removeTarget:_view action:nil forKey:nil];
}

+ (XZMocoaContext *)contextForView:(UIResponder *)view {
    XZMocoaContext *context = objc_getAssociatedObject(view, _context);
    if (context) {
        return context;
    }
    context = [[XZMocoaContext alloc] initWithView:view];
    objc_setAssociatedObject(view, _context, context, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return context;
}

- (instancetype)initWithView:(UIResponder *)view {
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

- (void)setViewModel:(XZMocoaViewModel *)newValue {
    XZMocoaViewModel * const oldValue = _viewModel;
    
    if (newValue == oldValue) {
        return;
    }
    
    [_view viewModelWillChange:newValue];
    
    // 解除 oldValue 与当前视图的绑定关系
    [self detach:oldValue];
    [oldValue removeTarget:_view action:nil forKey:nil];
    
    // 保存 newValue
    _viewModel = newValue;
    
    // view 与 viewModel 一对一关系
    [self attach:newValue];
    
    [_view viewModelDidChange:oldValue];
}

- (void)attach:(XZMocoaViewModel *)viewModel {
    if (viewModel == nil) {
        return;
    }
    
    XZMocoaContext *lastContext = viewModel->_context;
    self->_next = lastContext;
    viewModel->_context = self;
}

- (void)detach:(XZMocoaViewModel *)viewModel {
    if (viewModel == nil) {
        return;
    }
    
    XZMocoaContext *lastContext = viewModel->_context;
    
    // 当前时链上最后一个，修改 viewModel 上的指向
    if (self == lastContext) {
        viewModel->_context = self->_next;
        return;
    }
    
    // 在链表上找到当前对象
    XZMocoaContext *nextContext = lastContext->_next;
    while (nextContext) {
        if (self == nextContext) {
            break;
        }
        lastContext = nextContext;
        nextContext = lastContext->_next;
    }
    
    // 将当前对象从链表移除
    if (nextContext) {
        lastContext->_next = nextContext->_next;
    } else {
        lastContext->_next = nil;
    }
}

- (UIViewController *)viewController {
    UIViewController *viewController = (id)_view;
    while (viewController) {
        if ([viewController isKindOfClass:UIViewController.class]) {
            return viewController;
        }
        viewController = (id)(viewController.nextResponder);
    }
    return _next.viewController;
}

- (UINavigationController *)navigationController {
    UINavigationController *viewController = (id)self.viewController;
    if ([viewController isKindOfClass:UINavigationController.class]) {
        return viewController;
    }
    return viewController.navigationController;
}

- (UITabBarController *)tabBarController {
    UITabBarController *viewController = (id)self.viewController;
    if ([viewController isKindOfClass:UITabBarController.class]) {
        return viewController;
    }
    return viewController.tabBarController;
}

@end
