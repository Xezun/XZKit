//
//  NSValue+XZGeometry.h
//  XZKit
//
//  Created by Xezun on 2021/2/28.
//

#import <XZKit/XZGeometry.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSValue (XZGeometry)

/// 以 XZEdgeInsets 构造 NSValue 对象。
/// @param edgeInsets XZEdgeInsets
+ (NSValue *)valueWithXZEdgeInsets:(XZEdgeInsets)edgeInsets NS_SWIFT_NAME(init(_:));

/// 取出 XZEdgeInsets 值
@property (nonatomic, readonly) XZEdgeInsets XZEdgeInsetsValue;

@end

NS_ASSUME_NONNULL_END
