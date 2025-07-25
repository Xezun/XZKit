//
//  XZMocoaModule.h
//  XZMocoa
//
//  Created by Xezun on 2021/8/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaDefines.h>
#import <XZKit/XZMocoaModuleDomain.h>
#import <XZKit/XZMacros.h>
#else
#import "XZMocoaDefines.h"
#import "XZMocoaModuleDomain.h"
#import "XZMacros.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaModule, NSDictionary, XZMocoaViewModel;

/// 实现视图的形式。
typedef NS_ENUM(NSUInteger, XZMocoaModuleViewForm) {
    /// 未提供视图，或不支持的视图形式
    XZMocoaModuleViewFormUnknown = 0,
    /// 纯代码视图
    XZMocoaModuleViewFormClass,
    /// xib 视图
    XZMocoaModuleViewFormNib,
    /// xib 视图控制器，可通过 mocoa url 加载。
    XZMocoaModuleViewFormStoryboard,
    /// xib 可重用视图，可通过 viewReuseIdentifier 注册。
    XZMocoaModuleViewFormStoryboardReusableView,
} NS_SWIFT_NAME(XZMocoaModule.ViewForm);

/// 为 XZMocoaModule 提供下标式访问的协议。
NS_SWIFT_NAME(XZMocoaModule.SubmoduleCollection)
@interface XZMocoaSubmoduleCollection : NSObject
- (instancetype)init NS_UNAVAILABLE;
@property (nonatomic, readonly) XZMocoaKind kind;
@property (nonatomic, readonly) XZMocoaModule *module;

- (XZMocoaModule *)submoduleForName:(XZMocoaName)name;
- (nullable XZMocoaModule *)submoduleIfLoadForName:(XZMocoaName)name;
- (void)setSubmodule:(nullable XZMocoaModule *)submodule forName:(XZMocoaName)name;

- (XZMocoaModule *)objectForKeyedSubscript:(XZMocoaName)name;
- (void)setObject:(nullable XZMocoaModule *)submodule forKeyedSubscript:(XZMocoaName)name;

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(XZMocoaName name, XZMocoaModule *submodule, BOOL *stop))block;
@end

/// 记录了 Mocoa MVVM 模块信息的对象。
/// @discussion
/// 在 Mocoa 中，由 Model-View-ViewModel 组成的单元被称为 XZMocoaModule 模块。
@interface XZMocoaModule : NSObject

/// 模块地址，每个模块都应该有唯一的地址。
/// @note
/// 在开发中，根据业务的分类和分层，将模块设计成 URL 的管理方式很常见，所以 Mocoa 也采取了这种方式。
/// @discussion
/// @b domain @c 不同类型的业务模块，使用 domain 进行区分。
/// @discussion
/// @b path   @c 相同类型的业务模块，使用 path 表示模块的层级关系。
/// @discussion
/// @b query  @c 模块传值。
/// @discussion
/// 模块在 path 中的名称，由模块的 kind 和 name 组成，格式如下：
/// @discussion
/// @b kind:name @c 表示模块的 Mocoa Kind 和 Mocoa Name 都不为空。
/// @discussion
/// @b kind:     @c 表示模块的 Mocoa Name 为空。
/// @discussion
/// @b name      @c 表示模块的 Mocoa Kind 为空。
@property (nonatomic, copy, readonly) NSURL *url;

/// 请使用 +moduleForURL: 来创建对象。
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)url NS_DESIGNATED_INITIALIZER;

/// 获取指定 url 对应的模块的 XZMocoaModule 对象。
/// @discussion
/// 推荐使用 XZMocoa(stringOrURL) 函数，获取模块对象。
/// @param url 模块地址
+ (nullable XZMocoaModule *)moduleForURL:(nullable NSURL *)url NS_SWIFT_NAME(init(for:));

/// 获取指定 url 字符串对应的模块的 XZMocoaModule 对象。
/// @discussion
/// 推荐使用 XZMocoa(stringOrURL) 函数，获取模块对象。
/// - Parameter urlString: 模块地址
+ (nullable XZMocoaModule *)moduleForURLString:(nullable NSString *)urlString NS_SWIFT_NAME(init(for:));

#pragma mark - 构造实例

- (nullable __kindof XZMocoaViewModel *)instantiateViewModelWithModel:(nullable id)model;

#pragma mark - MVVM 基本结构

/// MVVM 中 Model 的 class 对象。
@property (nonatomic, strong, nullable) Class modelClass;


@property (nonatomic, readonly) XZMocoaModuleViewForm viewForm;
// View by Class MVVM 中 View 的 class 对象。
@property (nonatomic, strong, nullable) Class viewClass;
// View by Nib
@property (nonatomic, setter=setViewNibWithClass:, nullable) Class viewNibClass;
@property (nonatomic, copy, setter=setViewNibWithName:) NSString *viewNibName;
@property (nonatomic, strong, readonly) NSBundle *viewNibBundle;
/// 仅可用来注册普通视图。
- (void)setViewNibWithName:(NSString *)nibName bundle:(NSBundle *)bundle;
/// 仅可用来注册普通视图。
- (void)setViewNibWithName:(NSString *)nibName;
/// 注册视图控制器。类名与 nib 文件名相同时可使用此方法。
- (void)setViewNibWithClass:(Class)viewClass;
/// 注册视图控制器需提供 viewClass 参数。
- (void)setViewNibWithClass:(nullable Class)viewClass name:(NSString *)nibName bundle:(NSBundle *)bundle;
// View by Storyboard
/// 控制器标记符，值 nil 表示入口控制器。
@property (nonatomic, copy, setter=setViewStoryboardWithIdentifier:, nullable) NSString *viewStoryboardIdentifier;
/// Storyboard 文件名。
@property (nonatomic, copy, setter=setViewStoryboardWithName:) NSString *viewStoryboardName;
/// Storyboard 文件所在包名。
@property (nonatomic, strong, setter=setViewStoryboardWithBundle:) NSBundle *viewStoryboardBundle;
/// 在 mainBundle 的 Main.storyboard 中定义的指定控制器，可通过此方法注册。
- (void)setViewStoryboardWithIdentifier:(NSString *)identifier;
/// 在 mainBundle 的 Name.storyboard 中定义的入口控制器，可通过此方法注册。
- (void)setViewStoryboardWithName:(NSString *)storyboardName;
/// 在 mainBundle 的 Name.storyboard 中定义的指定控制器，可通过此方法注册。
- (void)setViewStoryboardWithIdentifier:(NSString *)identifier name:(NSString *)storyboardName;
/// 在 bundle 的 Main.storyboard 中定义的指定控制器，可通过此方法注册。
- (void)setViewStoryboardWithIdentifier:(NSString *)identifier bundle:(NSBundle *)bundle;
/// 在 bundle 的 Name.storyboard 中定义的入口控制器，可通过此方法注册。
- (void)setViewStoryboardWithName:(NSString *)storyboardName bundle:(NSBundle *)bundle;
/// 在 bundle 的 Main.storyboard 中定义的入口控制器，可通过此方法注册。
- (void)setViewStoryboardWithBundle:(NSBundle *)bundle;
/// 在 bundle 的 Name.storyboard 中定义的指定控制器，可通过此方法注册。
- (void)setViewStoryboardWithIdentifier:(nullable NSString *)identifier name:(NSString *)storyboardName bundle:(NSBundle *)bundle;
/// 通过重用标识符，注册模块的视图。
///
/// 在 storyboard 中，可以将 UITableViewCell、UICollectionViewCell 已经注册到了 UITableView、UICollectionView 中，可以通过此属性将视图与模块关联起来。
@property (nonatomic, copy, nullable) NSString *viewReuseIdentifier;

/// MVVM 中 ViewModel 的 class 对象。
@property (nonatomic, strong, nullable) Class viewModelClass;

/// 遍历所有子模块的 XZMocoaModule 对象。
/// - Parameter block: 块函数
- (void)enumerateSubmodulesUsingBlock:(void (^NS_NOESCAPE)(XZMocoaModule *submodule, XZMocoaKind kind, XZMocoaName name, BOOL *stop))block;

#pragma mark - 访问下级的基础方法

/// 获取指定分类下的子模块的 XZMocoaModule 对象。
/// @note 该方法为懒加载。
/// @param kind 分类
/// @param name 名称
- (XZMocoaModule *)submoduleForKind:(XZMocoaKind)kind forName:(XZMocoaName)name;

/// 设置或删除指定分类下指定名称的子模块的 XZMocoaModule 对象。
/// @note 该方法一般用于删除下级，添加下级请用懒加载方法。
/// @param newSubmodule 子模块的 XZMocoaModule 对象
/// @param kind 分类
/// @param name 名称
- (void)setSubmodule:(XZMocoaModule *)newSubmodule forKind:(XZMocoaKind)kind forName:(XZMocoaName)name;

/// 获取指定分类下的子模块的的 XZMocoaModule 对象，非懒加载。
/// @param kind 分类
/// @param name 名称
- (nullable XZMocoaModule *)submoduleIfLoadedForKind:(XZMocoaKind)kind forName:(XZMocoaName)name;

/// 获取默认分类的子模块的 XZMocoaModule 对象。
/// @param name 子模块名称
- (XZMocoaModule *)submoduleForName:(XZMocoaName)name;

/// 设置或删除默认分类下的子模块的 XZMocoaModule 对象。
/// @param newSubmodule 子模块的 XZMocoaModule 对象
/// @param name 名称
- (void)setSubmodule:(XZMocoaModule *)newSubmodule forName:(XZMocoaName)name;

/// 为 XZMocoaModule 提供下标式访问的协议。
/// @code
/// // 常规方式获取下级
/// XZMocoaModule *submodule = [module submoduleForKind:@"header" forName:@"black"];
/// // 下标方式来获取下级
/// XZMocoaModule *submodule = module[@"header"][@"black"];
/// @endcode
- (XZMocoaSubmoduleCollection *)objectForKeyedSubscript:(XZMocoaKind)kind;

/// 获取指定路径的子模块，这是一个懒加载方法。
/// @param path 子模块的路径
- (XZMocoaModule *)submoduleForPath:(NSString *)path;

@end

@interface XZMocoaModule (XZMocoaExtendedModule)

/// 列表
@property (nonatomic, strong, null_resettable) XZMocoaModule *list;

#pragma mark - 为 tableView、collectionView 提供的便利方法

/// UITableView 或 UICollectionView 模块的默认的 section 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此属性仅用于表示 UITableView 或 UICollectionView 模块的 XZMocoaModule 对象。
/// @discussion
/// 此属性等同于`[table submoduleForName:XZMocoaNameDefault forKind:XZMocoaKindDefault]`。
@property (nonatomic, strong, null_resettable) XZMocoaModule *section;

/// 获取 UITableView 或 UICollectionView 模块的指定名称 section 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此方法仅用于表示 UITableView 或 UICollectionView 模块的 XZMocoaModule 对象。
/// @discussion
/// 此方法等同于`[table submoduleForName:name forKind:XZMocoaKindDefault]`。
/// @param name 模块名称
- (XZMocoaModule *)sectionForName:(XZMocoaName)name;

/// 设置 section 模块为 UITableView 或 UICollectionView 模块的下级模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此方法仅用于表示 UITableView 或 UICollectionView 模块的 XZMocoaModule 对象。
/// @discussion
/// 此方法等同于`[table setSubmodule:section forKind:XZMocoaKindDefault forName:name]`。
/// @param section 模块对象
/// @param name 模块名称
- (void)setSection:(nullable XZMocoaModule *)section forName:(XZMocoaName)name;

/// UITableView 或 UICollectionView 的 Section 模块的默认的 Header 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此属性仅用于表示 UITableView 或 UICollectionView 的 Section 模块的 XZMocoaModule 对象。
/// @discussion
/// 此属性等同于`[section submoduleForKind:XZMocoaKindHeader forName:XZMocoaNameDefault]`。
@property (nonatomic, strong, null_resettable) XZMocoaModule *header;

/// 获取 UITableView 或 UICollectionView 的 Section 模块的指定名称的 Header 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此方法仅用于表示 UITableView 或 UICollectionView 的 Section 模块的 XZMocoaModule 对象。
/// @discussion
/// 此方法等同于`[section submoduleForKind:XZMocoaKindHeader forName:name]`。
/// @param name 下级的名称
- (XZMocoaModule *)headerForName:(XZMocoaName)name;

/// 设置 UITableView 或 UICollectionView 的 Section 模块的指定名称的 Header 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此方法仅用于表示 UITableView 或 UICollectionView 的 Section 模块的 XZMocoaModule 对象。
/// @discussion
/// 此方法等同于`[section setSubmodule:header forKind:XZMocoaKindHeader forName:name]`。
/// @param header 模块对象
/// @param name 模块名称
- (void)setHeader:(nullable XZMocoaModule *)header forName:(XZMocoaName)name;

/// UITableView 或 UICollectionView 的 Section 模块的默认的 Cell 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此属性仅用于表示 UITableView 或 UICollectionView 的 Section 模块的 XZMocoaModule 对象。
/// @discussion
/// 此属性等同于`[section submoduleForKind:XZMocoaKindCell forName:XZMocoaNameDefault]`。
@property (nonatomic, strong, null_resettable) XZMocoaModule *cell;

/// 获取 UITableView 或 UICollectionView 的 Section 模块的指定名称的 Cell 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此属性仅用于表示 UITableView 或 UICollectionView 的 Section 模块的 XZMocoaModule 对象。
/// @discussion
/// 此属性等同于`[section submoduleForKind:XZMocoaKindCell forName:name]`。
/// @param name 模块名称
- (XZMocoaModule *)cellForName:(XZMocoaName)name;

/// 设置 UITableView 或 UICollectionView 的 Section 模块的指定名称的 Cell 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此属性仅用于表示 UITableView 或 UICollectionView 的 Section 模块的 XZMocoaModule 对象。
/// @discussion
/// 此属性等同于`[section setSubmodule:cell forKind:XZMocoaKindCell forName:name]`。
/// @param name 模块名称
- (void)setCell:(nullable XZMocoaModule *)cell forName:(XZMocoaName)name;

/// UITableView 或 UICollectionView 的 Section 模块的默认的 Footer 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此属性仅用于表示 UITableView 或 UICollectionView 的 Section 模块的 XZMocoaModule 对象。
/// @discussion 此方法等同于`[section submoduleForKind:XZMocoaKindFooter forName:XZMocoaNameDefault]`。
@property (nonatomic, strong, null_resettable) XZMocoaModule *footer;

/// 获取 UITableView 或 UICollectionView 的 Section 模块的指定名称的 Footer 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此属性仅用于表示 UITableView 或 UICollectionView 的 Section 模块的 XZMocoaModule 对象。
/// @discussion
/// 此方法等同于`[section submoduleForKind:XZMocoaKindFooter forName:name]`。
/// @param name 模块名称
- (XZMocoaModule *)footerForName:(XZMocoaName)name;

/// 设置 UITableView 或 UICollectionView 的 Section 模块的指定名称的 Footer 模块。
/// @discussion
/// Section 是 UITableView 或 UICollectionView 的直接下级，Header/Cell/Footer 是 Section 的直接下级。
/// @attention
/// 此属性仅用于表示 UITableView 或 UICollectionView 的 Section 模块的 XZMocoaModule 对象。
/// @discussion
/// 此方法等同于`[section setSubmodule:footer forKind:XZMocoaKindFooter forName:name]`。
/// @param footer 模块对象
/// @param name 模块名称
- (void)setFooter:(nullable XZMocoaModule *)footer forName:(XZMocoaName)name;

@end

@interface NSURL (XZMocoaModule)
/// 子类可以通过此方法构造统一格式的 URL 对象。
/// - Parameters:
///   - domain: 域
///   - path: 路径，格式如 /path1/path2
+ (NSURL *)mocoaURLWithDomain:(XZMocoaModuleDomain *)domain path:(NSString *)path NS_SWIFT_NAME(init(_:path:));
@end


@interface XZMocoaModule (XZMocoaModuleProvider) <XZMocoaModuleProvider>

@end

/// 通过 URL 获取模块。
///
/// 推荐的 URL 格式：
/// - mocoa://xzkit.xezun.com/
/// - mocoa://xzkit.xezun.com/example
///
/// @param moduleURLString 模块地址
FOUNDATION_STATIC_INLINE XZMocoaModule * _Nullable XZMocoa(NSString *moduleURLString) XZ_ATTR_OVERLOAD NS_REFINED_FOR_SWIFT {
    return [XZMocoaModule moduleForURLString:moduleURLString];
}

/// 通过 URL 获取模块。
///
/// 推荐的 URL 格式：
/// - mocoa://xzkit.xezun.com/
/// - mocoa://xzkit.xezun.com/example
///
/// @param moduleURL 模块地址
FOUNDATION_STATIC_INLINE XZMocoaModule * _Nullable XZMocoa(NSURL *moduleURL) XZ_ATTR_OVERLOAD NS_REFINED_FOR_SWIFT {
    return [XZMocoaModule moduleForURL:moduleURL];
}

NS_ASSUME_NONNULL_END
