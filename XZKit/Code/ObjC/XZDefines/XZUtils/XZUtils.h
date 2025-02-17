//
//  XZUtils.h
//  XZKit
//
//  Created by Xezun on 2023/8/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 默认动画时长 0.35 秒。
FOUNDATION_EXPORT NSTimeInterval const XZAnimationDuration;

/// 比较两个版本号，格式如 2.3.1，位数任意。
/// @discussion 如果返回 NSOrderedAscending 则表示 version2 是更高版本。
/// @discussion 如果返回 NSOrderedDescending 则表示 version1 更更高版本。
/// @param version1 被比较的版本
/// @param version2 待比较的版本
FOUNDATION_EXPORT NSComparisonResult XZVersionStringCompare(NSString * _Nullable version1, NSString * _Nullable version2) NS_SWIFT_UNAVAILABLE("Use Swift.Version instead");

/// 获取当前的时间戳。使用 `gettimeofday` 函数，不会创建 `NSDate` 对象。
FOUNDATION_EXPORT NSTimeInterval XZTimestamp(void) NS_SWIFT_NAME(timestamp());

NS_ASSUME_NONNULL_END
