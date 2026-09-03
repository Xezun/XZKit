//
//  XZMocoaModule.m
//  XZMocoa
//
//  Created by Xezun on 2021/8/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaModule.h"
#import "XZMocoaViewModel.h"

/// 将 MocoaURL 中的单个 path 部分解析成 MVVM 模块的 kind 和 name 值。
/// - Parameters:
///   - path: 单个 path 值
///   - kind: 输出值，MocoaKind 值
///   - name: 输出值，MocoaName 值
/// - Returns: 参数 path 是否包含冒号
FOUNDATION_STATIC_INLINE BOOL XZMocoaPathParser(NSString *path, XZMocoaKind *kind, XZMocoaName *name) {
    NSRange const range = [path rangeOfString:@":"];
    if (range.location == NSNotFound) {
        *kind = XZMocoaKindDefault;
        *name = path;
        return NO;
    }
    *kind = [path substringToIndex:range.location];
    *name = [path substringFromIndex:range.location + 1];
    return YES;
}

/// 将 MVVM 模块的 kind 和 name 合成 MocoaURL 中的 path 部分。
/// - Parameters:
///   - kind: MocoaKind
///   - name: MocoaName
FOUNDATION_STATIC_INLINE NSString *XZMocoaPathCreate(XZMocoaKind kind, XZMocoaName name) {
    return (kind.length ? [NSString stringWithFormat:@"%@:%@", kind, name] : (name.length ? name : @":"));
}

/// 生成子模块字典的标准键，格式恒为 "kind:name"；当 kind 为默认空字符串时即 ":name"。
/// @discussion
/// 与 XZMocoaPathCreate 的区别：后者用于 URL path，默认分类会省略冒号；此函数用于字典键，恒保留冒号，
/// 以便与「简化键 name」区分，支撑默认分类子模块的双注册。
/// - Parameters:
///   - kind: MocoaKind
///   - name: MocoaName
FOUNDATION_STATIC_INLINE NSString *XZMocoaStandardKey(XZMocoaKind kind, XZMocoaName name) {
    return [NSString stringWithFormat:@"%@:%@", kind, name];
}

@interface XZMocoaModule () {
    Class _viewClass;
    NSString *_viewName;
    NSString *_viewIdentifier;
    NSBundle *_viewBundle;
    /// 子模块存储，键为规范化的 "kind:name" 字符串；当 kind 为默认空字符串时，键退化为 name（":name" 与 "name" 等价）。
    NSMutableDictionary<NSString *, XZMocoaModule *> *_submodules;
}
@end


@implementation XZMocoaModule

+ (XZMocoaModule *)moduleForURL:(NSURL *)url {
    NSString *host = url.host;
    if (host == nil) {
        return nil;
    }
    
    XZMocoaDomain * const domain = [XZMocoaDomain domainNamed:host];
    if (!domain.provider) {
        domain.provider = (id)self;
    }
    // 关于 url 的 path
    // mocoa://www.xezun.com        =>
    // mocoa://www.xezun.com/       => /
    // mocoa://www.xezun.com/path   => /path
    // mocoa://www.xezun.com/path/  => /path
    NSString *path = url.path;
    if (path == nil || path.length == 0) {
        path = @"/";
    }
    XZMocoaModule * const module = [domain moduleForPath:path];
    NSAssert(!module || [module isKindOfClass:[XZMocoaModule class]], @"参数 url 对应的不是 MVVM 模块：%@", url);
    return module;
}

+ (XZMocoaModule *)moduleForURLString:(NSString *)urlString {
    if (urlString == nil) {
        return [self moduleForURL:nil];
    }
    return [self moduleForURL:[NSURL URLWithString:urlString]];
}

- (instancetype)init {
    @throw [NSException exceptionWithName:NSGenericException reason:@"非法访问" userInfo:@{
        NSLocalizedRecoverySuggestionErrorKey: @"请使用 -initWithURL: 方法进行初始化"
    }];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self != nil) {
        _url = url.copy;
    }
    return self;
}

// - 实例

- (__kindof XZMocoaViewModel *)instantiateViewModelWithModel:(id)model {
    XZMocoaViewModel * const viewModel = [[self.viewModelClass alloc] initWithModel:model];
    viewModel.module = self;
    return viewModel;
}

// view class

- (Class)viewClass {
    return _viewForm == XZMocoaModuleViewFormClass ? _viewClass : Nil;
}

- (void)setViewClass:(Class)viewClass {
    _viewForm = XZMocoaModuleViewFormClass;
    _viewClass = viewClass;
    _viewName = nil;
    _viewBundle = nil;
    _viewIdentifier = nil;
}

// view nib

- (Class)viewNibClass {
    return _viewForm == XZMocoaModuleViewFormNib ? _viewClass : Nil;
}

- (NSString *)viewNibName {
    return _viewForm == XZMocoaModuleViewFormNib ? _viewName : nil;
}

- (NSBundle *)viewNibBundle {
    return _viewForm == XZMocoaModuleViewFormNib ? _viewBundle : nil;
}

- (void)setViewNibWithClass:(Class)viewClass name:(NSString *)nibName bundle:(NSBundle *)bundle {
    NSAssert(nibName && bundle, @"必须提供 nibName 和 bundle 参数");
    _viewForm   = XZMocoaModuleViewFormNib;
    _viewClass  = viewClass;
    _viewName   = nibName.copy;
    _viewBundle = bundle ?: NSBundle.mainBundle;
    _viewIdentifier = nil;
}

- (void)setViewNibWithName:(NSString *)nibName bundle:(NSBundle *)bundle {
    [self setViewNibWithClass:Nil name:nibName bundle:bundle ?: NSBundle.mainBundle];
}

- (void)setViewNibWithName:(NSString *)nibName {
    [self setViewNibWithClass:Nil name:nibName bundle:NSBundle.mainBundle];
}

- (void)setViewNibWithClass:(Class)viewClass {
    NSAssert(viewClass, @"必须提供 viewClass 参数");
    [self setViewNibWithClass:viewClass name:NSStringFromClass(viewClass) bundle:[NSBundle bundleForClass:viewClass]];
}

// view storyboard

- (NSString *)viewStoryboardIdentifier {
    return _viewForm == XZMocoaModuleViewFormStoryboard ? _viewIdentifier : nil;
}

- (NSString *)viewStoryboardName {
    return _viewForm == XZMocoaModuleViewFormStoryboard ? _viewName : nil;
}

- (NSBundle *)viewStoryboardBundle {
    return _viewForm == XZMocoaModuleViewFormStoryboard ? _viewBundle : nil;
}

- (void)setViewStoryboardWithIdentifier:(NSString *)identifier {
    [self setViewStoryboardWithIdentifier:identifier name:@"Main" bundle:NSBundle.mainBundle];
}

- (void)setViewStoryboardWithName:(NSString *)storyboardName {
    [self setViewStoryboardWithIdentifier:nil name:storyboardName bundle:NSBundle.mainBundle];
}

- (void)setViewStoryboardWithIdentifier:(NSString *)identifier name:(NSString *)storyboardName {
    [self setViewStoryboardWithIdentifier:identifier name:storyboardName bundle:NSBundle.mainBundle];
}

- (void)setViewStoryboardWithIdentifier:(NSString *)identifier bundle:(NSBundle *)bundle {
    [self setViewStoryboardWithIdentifier:identifier name:@"Main" bundle:bundle];
}

- (void)setViewStoryboardWithName:(NSString *)storyboardName bundle:(NSBundle *)bundle {
    [self setViewStoryboardWithIdentifier:nil name:storyboardName bundle:bundle];
}

- (void)setViewStoryboardWithBundle:(NSBundle *)bundle {
    [self setViewStoryboardWithIdentifier:nil name:@"Main" bundle:bundle];
}

- (void)setViewStoryboardWithIdentifier:(NSString *)identifier name:(NSString *)storyboardName bundle:(NSBundle *)bundle {
    NSAssert(storyboardName && bundle, @"参数 name 和 bundle 必须提供");
    _viewForm       = XZMocoaModuleViewFormStoryboard;
    _viewClass      = Nil;
    _viewIdentifier = identifier.copy;
    _viewName       = storyboardName.copy;
    _viewBundle     = bundle;
}

- (void)setViewReuseIdentifier:(NSString *)viewReuseIdentifier {
    _viewForm       = XZMocoaModuleViewFormStoryboardReusableView;
    _viewClass      = Nil;
    _viewIdentifier = viewReuseIdentifier.copy;
    _viewName       = nil;
    _viewBundle     = nil;
}

- (NSString *)viewReuseIdentifier {
    return _viewForm == XZMocoaModuleViewFormStoryboardReusableView ? _viewIdentifier : nil;
}

- (void)enumerateSubmodulesUsingBlock:(void (^NS_NOESCAPE)(XZMocoaModule *submodule, XZMocoaKind kind, XZMocoaName name, BOOL *stop))block {
    [_submodules enumerateKeysAndObjectsUsingBlock:^(NSString *key, XZMocoaModule *submodule, BOOL *stop) {
        XZMocoaKind kind = nil;
        XZMocoaName name = nil;
        if (XZMocoaPathParser(key, &kind, &name)) {
            block(submodule, kind, name, stop);
        }
    }];
}


#pragma mark - 访问下级的基础方法

- (XZMocoaModule *)submoduleForKind:(XZMocoaKind)kind forName:(XZMocoaName)name {
    if (kind == nil) kind = XZMocoaKindDefault;
    if (name == nil) name = XZMocoaNameDefault;
    return [self objectForKeyedSubscript:XZMocoaPathCreate(kind, name)];
}

- (void)setSubmodule:(XZMocoaModule *)newSubmodule forKind:(XZMocoaKind)kind forName:(XZMocoaName)name {
    if (kind == nil) kind = XZMocoaKindDefault;
    if (name == nil) name = XZMocoaNameDefault;
    NSString * const key = XZMocoaStandardKey(kind, name);
    if (newSubmodule == nil) {
        // 双移除
        if ([kind isEqualToString:XZMocoaKindDefault]) {
            [_submodules removeObjectForKey:name];
        }
        [_submodules removeObjectForKey:key];
        return;
    }
    if (_submodules == nil) {
        _submodules = [NSMutableDictionary dictionary];
    }
    // 双注册
    if ([kind isEqualToString:XZMocoaKindDefault]) {
        _submodules[name] = newSubmodule;
    }
    _submodules[key] = newSubmodule;
}

- (XZMocoaModule *)submoduleIfLoadedForKind:(XZMocoaKind)kind forName:(XZMocoaName)name {
    if (kind == nil) kind = XZMocoaKindDefault;
    if (name == nil) name = XZMocoaNameDefault;
    return _submodules[XZMocoaPathCreate(kind, name)];
}

#pragma mark - 下标存储方法

/// 获取指定键的子模块，键不存在时懒加载创建并注册到 Domain。
/// @discussion
/// 键支持 "name"、":name"、"kind:name" 形式；当 kind 为默认空字符串时，"name" 与 ":name" 等价。
/// 为此默认分类的子模块以「简化键 name」与「标准键 :name」双注册，保证两种写法命中同一对象。
/// @param key 子模块的键
- (XZMocoaModule *)objectForKeyedSubscript:(XZMocoaKey)key {
    if (key == nil) key = XZMocoaNameDefault;
    if (_submodules == nil) {
        _submodules = [NSMutableDictionary dictionary];
    }
    XZMocoaModule *submodule = _submodules[key];
    if (submodule == nil) {
        XZMocoaName name = nil;
        XZMocoaKind kind = nil;
        
        // 没有冒号，不是标准 key
        if (!XZMocoaPathParser(key, &kind, &name)) {
            key = XZMocoaStandardKey(kind, name);
        }
        
        // 构造合法的 path
        NSString *path = XZMocoaPathCreate(kind, name);
        NSURL * const submoduleURL = [self.url URLByAppendingPathComponent:path];
        
        // 创建新的模块
        submodule = [[XZMocoaModule alloc] initWithURL:submoduleURL];
        
        // 双注册：同时为 kind:name 标准键和不带 kind 的简化键
        if ([kind isEqualToString:XZMocoaKindDefault]) {
            _submodules[name] = submodule;
        }
        _submodules[key] = submodule;
        
        // 在 domain 中注册新创建的 module
        XZMocoaDomain *domain = [XZMocoaDomain domainNamed:submoduleURL.host];
        [domain setModule:submodule forPath:submoduleURL.path];
    }
    return submodule;
}

- (XZMocoaModule *)submoduleForPath:(NSString *)path {
    XZMocoaModule *submodule = self;
    for (NSString * const subpath in [path componentsSeparatedByString:@"/"]) {
        if (subpath.length == 0) {
            continue; // 忽略空白的
        }
        submodule = [submodule objectForKeyedSubscript:subpath];
    }
    return submodule;
}

#pragma mark - DEBUG

- (NSString *)description {
    return [self descriptionWithPadding:0 kind:nil name:nil];
}

- (NSString *)descriptionWithPadding:(NSInteger)padding kind:(nullable XZMocoaKind)kind name:(nullable XZMocoaName)name {
    NSString * const TAB = [@"" stringByPaddingToLength:padding * 4 withString:@" " startingAtIndex:0];
    NSMutableArray *stringsM = [NSMutableArray arrayWithCapacity:_submodules.count + 2];
    
    [stringsM addObject:@"{"];
    
    [stringsM addObject:[NSString stringWithFormat:@"%@    self: %@", TAB, super.description]];
    [stringsM addObject:[NSString stringWithFormat:@"%@    url: %@", TAB, self.url]];
    [stringsM addObject:[NSString stringWithFormat:@"%@    kind: %@", TAB, kind]];
    [stringsM addObject:[NSString stringWithFormat:@"%@    name: %@", TAB, name]];
    
    [stringsM addObject:[NSString stringWithFormat:@"%@    model: %@", TAB, self.modelClass]];
    [stringsM addObject:[NSString stringWithFormat:@"%@    view: %@", TAB, (id)self.viewNibName ?: (id)self.viewClass]];
    [stringsM addObject:[NSString stringWithFormat:@"%@    viewModel: %@", TAB, self.viewModelClass]];
    
    if (_submodules.count > 0) {
        [stringsM addObject:[NSString stringWithFormat:@"%@    submodules: [", TAB]];
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:_submodules.count];
        [self enumerateSubmodulesUsingBlock:^(XZMocoaModule *submodule, XZMocoaKind kind, XZMocoaName name, BOOL *stop) {
            NSString *string = [submodule descriptionWithPadding:padding + 2 kind:kind name:name];
            [items addObject:string];
        }];
        [stringsM addObject:[NSString stringWithFormat:@"%@        %@", TAB, [items componentsJoinedByString:@", "]]];
        
        [stringsM addObject:[NSString stringWithFormat:@"%@    ]", TAB]];
    }
    
    [stringsM addObject:[NSString stringWithFormat:@"%@}", TAB]];
    
    return [stringsM componentsJoinedByString:@"\n"];
}

@end



@implementation XZMocoaModule (XZMocoaExtendedModule)

- (XZMocoaModule *)main {
    return [self objectForKeyedSubscript:XZMocoaNameMain];
}

- (void)setMain:(XZMocoaModule *)main {
    [self setSubmodule:main forKind:XZMocoaKindDefault forName:XZMocoaNameMain];
}

- (XZMocoaModule *)home {
    return [self objectForKeyedSubscript:XZMocoaNameHome];
}

- (void)setHome:(XZMocoaModule *)home {
    [self setSubmodule:home forKind:XZMocoaKindDefault forName:XZMocoaNameHome];
}

- (XZMocoaModule *)user {
    return [self objectForKeyedSubscript:XZMocoaNameUser];
}

- (void)setUser:(XZMocoaModule *)user {
    [self setSubmodule:user forKind:XZMocoaKindDefault forName:XZMocoaNameUser];
}

- (XZMocoaModule *)list {
    return [self objectForKeyedSubscript:XZMocoaNameList];
}

- (void)setList:(XZMocoaModule *)list {
    [self setSubmodule:list forKind:XZMocoaKindDefault forName:XZMocoaNameList];
}

#pragma mark - 为 tableView、collectionView 提供的便利方法

- (XZMocoaModule *)header {
    // 键等价于 XZMocoaStandardKey(XZMocoaKindHeader, XZMocoaNameDefault)
    return [self objectForKeyedSubscript:@"header:"];
}

- (void)setHeader:(XZMocoaModule *)header {
    [self setSubmodule:header forKind:XZMocoaKindHeader forName:XZMocoaNameDefault];
}

- (XZMocoaModule *)headerForName:(XZMocoaName)name {
    return [self objectForKeyedSubscript:XZMocoaStandardKey(XZMocoaKindHeader, name ?: XZMocoaNameDefault)];
}

- (void)setHeader:(XZMocoaModule *)header forName:(XZMocoaName)name {
    [self setSubmodule:header forKind:XZMocoaKindHeader forName:name];
}

- (XZMocoaModule *)cell {
    // 键等价于 XZMocoaStandardKey(XZMocoaKindDefault, XZMocoaNameDefault)
    return [self objectForKeyedSubscript:@":"];
}

- (void)setCell:(XZMocoaModule *)cell {
    [self setSubmodule:cell forKind:XZMocoaKindDefault forName:XZMocoaNameDefault];
}

- (XZMocoaModule *)cellForName:(XZMocoaName)name {
    // 默认分类的键即 name 本身；name 为 nil 时由 objectForKeyedSubscript: 内部回落为默认键
    return [self objectForKeyedSubscript:name];
}

- (void)setCell:(XZMocoaModule *)cell forName:(XZMocoaName)name {
    [self setSubmodule:cell forKind:XZMocoaKindDefault forName:name];
}

- (XZMocoaModule *)footer {
    // 键等价于 XZMocoaStandardKey(XZMocoaKindFooter, XZMocoaNameDefault)
    return [self objectForKeyedSubscript:@"footer:"];
}

- (void)setFooter:(XZMocoaModule *)footer {
    [self setSubmodule:footer forKind:XZMocoaKindFooter forName:XZMocoaNameDefault];
}

- (XZMocoaModule *)footerForName:(XZMocoaName)name {
    return [self objectForKeyedSubscript:XZMocoaStandardKey(XZMocoaKindFooter, name ?: XZMocoaNameDefault)];
}

- (void)setFooter:(XZMocoaModule *)footer forName:(XZMocoaName)name {
    [self setSubmodule:footer forKind:XZMocoaKindFooter forName:name];
}

@end


@implementation NSURL (XZMocoaModule)

+ (NSURL *)mocoaURLWithDomain:(XZMocoaDomain *)domain path:(NSString *)path {
    NSString * const name   = domain.name;
    NSString * const string = [NSString stringWithFormat:@"mocoa://%@%@", name, path];
    NSURL    * const url    = [NSURL URLWithString:string];
    NSAssert(url, @"参数 name=%@ 和 path=%@ 不是合法的 URL 部分", name, path);
    return url;
}

@end

@implementation XZMocoaModule (XZMocoaProvider)

+ (id)domain:(XZMocoaDomain *)domain moduleForPath:(nonnull NSString *)path {
    // 创建模块
    NSURL * const url = [NSURL mocoaURLWithDomain:domain path:path];
    
    // 根模块
    if ([path isEqualToString:@"/"]) {
        return [[XZMocoaModule alloc] initWithURL:url];
    }
    
    // 先查找上级模块
    NSString      * const superPath   = path.stringByDeletingLastPathComponent;
    XZMocoaModule * const superModule = [domain moduleForPath:superPath];
    
    // 解析 name kind
    XZMocoaKind subKind = nil;
    XZMocoaName subName = nil;
    XZMocoaPathParser(path.lastPathComponent, &subKind, &subName);
    
    // 查找子模块，否则创建并关联
    XZMocoaModule *module = [superModule submoduleIfLoadedForKind:subKind forName:subName];
    if (module == nil) {
        module = [[XZMocoaModule alloc] initWithURL:url];
        [superModule setSubmodule:module forKind:subKind forName:subName];
    }
    
    return module;
}

- (id)domain:(XZMocoaDomain *)domain moduleForPath:(nonnull NSString *)path {
    return [XZMocoaModule domain:domain moduleForPath:path];
}

@end
