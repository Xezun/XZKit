//
//  XZMocoa.m
//  XZMocoa
//
//  Created by Xezun on 2021/8/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaModule.h"
#import "XZMocoaViewModel.h"
#import "XZLog.h"

/// 将 MocoaURL 中的单个 path 部分解析成 MVVM 模块的 kind 和 name 值。
/// - Parameters:
///   - path: 单个 path 值
///   - kind: 输出值，MocoaKind 值
///   - name: 输出值，MocoaName 值
FOUNDATION_STATIC_INLINE void XZMocoaPathParser(NSString *path, XZMocoaKind *kind, XZMocoaName *name) {
    NSRange const range = [path rangeOfString:@":"];
    if (range.location == NSNotFound) {
        *kind = XZMocoaKindDefault;
        *name = path;
    } else {
        *kind = [path substringToIndex:range.location];
        *name = [path substringFromIndex:range.location + 1];
    }
}

/// 将 MVVM 模块的 kind 和 name 合成 MocoaURL 中的 path 部分。
/// - Parameters:
///   - kind: MocoaKind
///   - name: MocoaName
FOUNDATION_STATIC_INLINE NSString *XZMocoaPathCreate(XZMocoaKind kind, XZMocoaName name) {
    return (kind.length ? [NSString stringWithFormat:@"%@:%@", kind, name] : (name.length ? name : @":"));
}

@interface XZMocoaSubmoduleCollection ()
- (instancetype)initWithKind:(XZMocoaKind)kind module:(XZMocoaModule *)module NS_DESIGNATED_INITIALIZER;
@end

@interface XZMocoaModule () {
    Class _viewClass;
    NSString *_viewName;
    NSString *_viewIdentifier;
    NSBundle *_viewBundle;
    NSMutableDictionary<XZMocoaKind, XZMocoaSubmoduleCollection *> *_submodules;
}
@end


@implementation XZMocoaModule

+ (XZMocoaModule *)moduleForURL:(NSURL *)url {
    NSString *host = url.host;
    if (host == nil) {
        XZLog(@"参数 url 不合法：%@", url);
        return nil;
    }
    
    XZMocoaModuleDomain * const domain = [XZMocoaModuleDomain doaminNamed:host];
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
    [_submodules enumerateKeysAndObjectsUsingBlock:^(XZMocoaKind kind, XZMocoaSubmoduleCollection *namedModules, BOOL *stop1) {
        [namedModules enumerateKeysAndObjectsUsingBlock:^(XZMocoaName name, XZMocoaModule *module, BOOL *stop2) {
            block(module, kind, name, stop2);
            *stop1 = *stop2;
        }];
    }];
}


#pragma mark - 访问下级的基础方法

- (XZMocoaModule *)submoduleForKind:(XZMocoaKind)kind forName:(XZMocoaName)name {
    if (kind == nil) kind = XZMocoaKindDefault;
    if (_submodules == nil) {
        _submodules = [NSMutableDictionary dictionary];
    }
    
    XZMocoaSubmoduleCollection *namedModules = _submodules[kind];
    if (namedModules == nil) {
        namedModules = [[XZMocoaSubmoduleCollection alloc] initWithKind:kind module:self];
        _submodules[kind] = namedModules;
    }
    return [namedModules submoduleForName:name];
}

- (void)setSubmodule:(XZMocoaModule *)newSubmodule forKind:(XZMocoaKind)kind forName:(XZMocoaName)name {
    if (kind == nil) kind = XZMocoaKindDefault;
    if (newSubmodule == nil) {
        if (_submodules == nil) {
            return;
        }
        [_submodules[kind] setSubmodule:newSubmodule forName:name];
    } else if (_submodules == nil) {
        _submodules = [NSMutableDictionary dictionary];
        XZMocoaSubmoduleCollection *namedModules = [[XZMocoaSubmoduleCollection alloc] initWithKind:kind module:self];
        _submodules[kind] = namedModules;
        [namedModules setSubmodule:newSubmodule forName:name];
    } else {
        XZMocoaSubmoduleCollection *namedModules = _submodules[kind];
        if (namedModules == nil) {
            namedModules = [[XZMocoaSubmoduleCollection alloc] initWithKind:kind module:self];
            _submodules[kind] = namedModules;
        }
        [namedModules setSubmodule:newSubmodule forName:name];
    }
}

- (XZMocoaModule *)submoduleIfLoadedForKind:(XZMocoaKind)kind forName:(XZMocoaName)name {
    if (kind == nil) kind = XZMocoaKindDefault;
    return [_submodules[kind] submoduleIfLoadForName:name];
}

- (XZMocoaModule *)submoduleForName:(XZMocoaName)name {
    return [self submoduleForKind:XZMocoaKindDefault forName:name];
}

- (void)setSubmodule:(XZMocoaModule *)newSubmodule forName:(XZMocoaName)name {
    [self setSubmodule:newSubmodule forKind:XZMocoaKindDefault forName:name];
}


#pragma mark - 下标存储方法

- (XZMocoaSubmoduleCollection *)objectForKeyedSubscript:(XZMocoaKind)kind {
    if (kind == nil) kind = XZMocoaKindDefault;
    if (_submodules == nil) {
        _submodules = [NSMutableDictionary dictionary];
    }
    XZMocoaSubmoduleCollection *namedModules = _submodules[kind];
    if (namedModules == nil) {
        namedModules = [[XZMocoaSubmoduleCollection alloc] initWithKind:kind module:self];
        _submodules[kind] = namedModules;
    }
    return namedModules;
}

- (XZMocoaModule *)submoduleForPath:(NSString *)path {
    XZMocoaModule *submodule = self;
    for (NSString * const subpath in [path componentsSeparatedByString:@"/"]) {
        if (subpath.length == 0) {
            continue; // 忽略空白的
        }
        XZMocoaKind kind = nil;
        XZMocoaName name = nil;
        XZMocoaPathParser(subpath, &kind, &name);
        submodule = [submodule submoduleForKind:kind forName:name];
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
        [self enumerateSubmodulesUsingBlock:^(XZMocoaModule *submodule, XZMocoaName kind, XZMocoaKind name, BOOL *stop) {
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

- (XZMocoaModule *)list {
    return [self submoduleForKind:XZMocoaKindDefault forName:XZMocoaNameList];
}

- (void)setList:(XZMocoaModule *)list {
    [self setSubmodule:list forKind:XZMocoaKindDefault forName:XZMocoaNameList];
}

#pragma mark - 为 tableView、collectionView 提供的便利方法

- (XZMocoaModule *)section {
    return [self submoduleForKind:XZMocoaKindSection forName:XZMocoaNameDefault];
}

- (void)setSection:(XZMocoaModule *)section {
    [self setSubmodule:section forKind:XZMocoaKindSection forName:XZMocoaNameDefault];
}

- (XZMocoaModule *)sectionForName:(XZMocoaName)name {
    return [self submoduleForKind:XZMocoaKindSection forName:name];
}

- (void)setSection:(XZMocoaModule *)section forName:(XZMocoaName)name {
    [self setSubmodule:section forKind:XZMocoaKindSection forName:name];
}

- (XZMocoaModule *)header {
    return [self submoduleForKind:XZMocoaKindHeader forName:XZMocoaNameDefault];
}

- (void)setHeader:(XZMocoaModule *)header {
    [self setSubmodule:header forKind:XZMocoaKindHeader forName:XZMocoaNameDefault];
}

- (XZMocoaModule *)headerForName:(XZMocoaName)name {
    return [self submoduleForKind:XZMocoaKindHeader forName:name];
}

- (void)setHeader:(XZMocoaModule *)header forName:(XZMocoaName)name {
    [self setSubmodule:header forKind:XZMocoaKindHeader forName:name];
}

- (XZMocoaModule *)cell {
    return [self submoduleForKind:XZMocoaKindCell forName:XZMocoaNameDefault];
}

- (void)setCell:(XZMocoaModule *)cell {
    [self setSubmodule:cell forKind:XZMocoaKindCell forName:XZMocoaNameDefault];
}

- (XZMocoaModule *)cellForName:(XZMocoaName)name {
    return [self submoduleForKind:XZMocoaKindCell forName:name];
}

- (void)setCell:(XZMocoaModule *)cell forName:(XZMocoaName)name {
    [self setSubmodule:cell forKind:XZMocoaKindCell forName:name];
}

- (XZMocoaModule *)footer {
    return [self submoduleForKind:XZMocoaKindFooter forName:XZMocoaNameDefault];
}

- (void)setFooter:(XZMocoaModule *)footer {
    [self setSubmodule:footer forKind:XZMocoaKindFooter forName:XZMocoaNameDefault];
}

- (XZMocoaModule *)footerForName:(XZMocoaName)name {
    return [self submoduleForKind:XZMocoaKindFooter forName:name];
}

- (void)setFooter:(XZMocoaModule *)footer forName:(XZMocoaName)name {
    [self setSubmodule:footer forKind:XZMocoaKindFooter forName:name];
}

@end


@implementation NSURL (XZMocoaModule)

+ (NSURL *)mocoaURLWithDomain:(XZMocoaModuleDomain *)domain path:(NSString *)path {
    NSString * const name   = domain.name;
    NSString * const string = [NSString stringWithFormat:@"mocoa://%@%@", name, path];
    NSURL    * const url    = [NSURL URLWithString:string];
    NSAssert(url, @"参数 name=%@ 和 path=%@ 不是合法的 URL 部分", name, path);
    return url;
}

@end

@implementation XZMocoaModule (XZMocoaModuleProvider)

+ (id)domain:(XZMocoaModuleDomain *)domain moduleForPath:(nonnull NSString *)path {
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

- (id)domain:(XZMocoaModuleDomain *)domain moduleForPath:(nonnull NSString *)path {
    return [XZMocoaModule domain:domain moduleForPath:path];
}

@end



@implementation XZMocoaSubmoduleCollection {
    NSMutableDictionary *_namedModules;
    XZMocoaModule *_module;
    XZMocoaKind _kind;
}

- (instancetype)initWithKind:(XZMocoaKind)kind module:(XZMocoaModule *)module {
    self = [super init];
    if (self) {
        _kind = kind.copy;
        _module = module;
        _namedModules = [NSMutableDictionary dictionary];
    }
    return self;
}

- (XZMocoaModule *)submoduleForName:(XZMocoaName)name {
    if (name == nil) {
        name = XZMocoaNameDefault;
    }
    XZMocoaModule *submodule = _namedModules[name];
    if (submodule == nil) {
        NSURL * const submoduleURL = [_module.url URLByAppendingPathComponent:XZMocoaPathCreate(_kind, name)];
        // 创建新的模块
        submodule = [[XZMocoaModule alloc] initWithURL:submoduleURL];
        _namedModules[name] = submodule;
        // 在 domain 中注册新创建的 module
        XZMocoaModuleDomain *domain = [XZMocoaModuleDomain doaminNamed:submoduleURL.host];
        [domain setModule:submodule forPath:submoduleURL.path];
    }
    return submodule;
}

- (XZMocoaModule *)submoduleIfLoadForName:(XZMocoaName)name {
    if (name == nil) {
        name = XZMocoaNameDefault;
    }
    return _namedModules[name];
}

- (void)setSubmodule:(XZMocoaModule *)submodule forName:(XZMocoaName)name {
    if (name == nil) {
        name = XZMocoaNameDefault;
    }
    _namedModules[name] = submodule;
}

- (XZMocoaModule *)objectForKeyedSubscript:(XZMocoaName)name {
    return [self submoduleForName:name];
}

- (void)setObject:(XZMocoaModule *)submodule forKeyedSubscript:(XZMocoaName)name {
    [self setSubmodule:submodule forName:name];
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (^NS_NOESCAPE)(XZMocoaName, XZMocoaModule *, BOOL *))block {
    [_namedModules enumerateKeysAndObjectsUsingBlock:block];
}

@end
