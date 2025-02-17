//
//  XZMocoaModuleDomain.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaModuleDomain;

/// 提供模块的对象，需要实现的协议。
NS_SWIFT_NAME(XZMocoaModule.Provider) @protocol XZMocoaModuleProvider <NSObject>
/// 获取指定路径的模块。
/// - Parameters:
///   - domain: 调用此方法的模块管理对象，即模块所在的域
///   - path: 模块的路径，一定是合法的。
- (nullable id)domain:(XZMocoaModuleDomain *)domain moduleForPath:(NSString *)path;
@end

/// 模块所在的域，一种基于 URL 的模块管理方式。
NS_SWIFT_NAME(XZMocoaModule.Domain) @interface XZMocoaModuleDomain : NSObject

/// 获取指定域名下的模块管理对象。
/// @note 该方法返回的是单例对象。
/// - Parameter name: 域名
+ (XZMocoaModuleDomain *)doaminNamed:(NSString *)name NS_SWIFT_NAME(init(named:));

/// 域名。
@property (nonatomic, copy, readonly) NSString *name;

- (instancetype)init NS_UNAVAILABLE;

/// 获取指定 url 对应的模块。
/// - Parameter url: 模块的 URL
+ (nullable id)moduleForURL:(NSURL *)url NS_SWIFT_NAME(init(for:));

/// 获取模块。
/// - Parameter path: 模块在域中的路径
- (nullable id)moduleForPath:(NSString *)path;

/// 注册或删除模块。
/// - Parameters:
///   - newModule: 模块对象
///   - path: 模块路径
- (void)setModule:(nullable id)newModule forPath:(NSString *)path;

/// 模块由外部提供懒加载，强引用。
@property (nonatomic, strong, nullable) id<XZMocoaModuleProvider> provider;

@end

NS_ASSUME_NONNULL_END
