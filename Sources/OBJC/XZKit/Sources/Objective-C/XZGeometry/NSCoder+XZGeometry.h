//
//  NSCoder+XZGeometry.h
//  XZKit
//
//  Created by Xezun on 2021/2/28.
//

#import <XZKit/XZGeometry.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSCoder (XZGeometry)

/// 归档编码 XZEdgeInsets 值。
/// @param insets XZEdgeInsets 值
/// @param key 键名
- (void)encodeXZEdgeInsets:(XZEdgeInsets)insets forKey:(NSString *)key;

/// 解档 XZEdgeInsets 值。
/// @param key 键名。
- (XZEdgeInsets)decodeXZEdgeInsetsForKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
