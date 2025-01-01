//
//  NSIndexSet+XZKit.h
//  XZKit
//
//  Created by Xezun on 2021/8/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSIndexSet (XZKit)

- (nullable id)xz_reduce:(nullable id)initial next:(id _Nullable (^NS_NOESCAPE)(id _Nullable result, NSInteger idx, BOOL *stop))next OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");
- (NSMutableArray *)xz_map:(id _Nonnull (^NS_NOESCAPE)(NSInteger idx, BOOL *stop))transform OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");
- (NSMutableArray *)xz_compactMap:(id _Nullable (^NS_NOESCAPE)(NSInteger idx, BOOL *stop))transform OBJC_SWIFT_UNAVAILABLE("请直接使用 Swift 版本");

@end

NS_ASSUME_NONNULL_END
