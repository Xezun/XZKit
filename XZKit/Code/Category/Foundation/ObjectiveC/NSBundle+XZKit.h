//
//  NSBundle.h
//  XZKit
//
//  Created by Xezun on 2017/10/31.
//

#import <Foundation/Foundation.h>

@interface NSBundle (XZKit)

/// XZKit Bundle.
/// @note 使用 +bundleWithIdentifier: 创建的 NSBundle 无法加载 Cocoapods 通过 .resource_bundles 引入的资源。
@property (class, nonatomic, readonly, nonnull) NSBundle *XZKitBundle NS_SWIFT_NAME(XZKit);

/// 构建版本。CFBundleVersion，默认 0。
@property (nonatomic, readonly, nonnull) NSString *xz_buildVersionString NS_SWIFT_NAME(buildVersionString);

/// 发行版本。CFBundleShortVersionString，默认 0。
@property (nonatomic, readonly, nonnull) NSString *xz_shortVersionString NS_SWIFT_NAME(shortVersionString);

/// App 名称。CFBundleDisplayName，默认空字符串。
@property (nonatomic, readonly, nonnull) NSString *xz_displayName NS_SWIFT_NAME(displayName);

@end



