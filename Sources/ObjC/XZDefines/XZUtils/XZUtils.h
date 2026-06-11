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
///
/// 比较基于 `-[NSString compare:]` 方法，并不对版本号进行实质性检查。
/// @li 1、返回值 `NSOrderedAscending` 表示 `version2` 为更高版本。
/// @li 2、返回值 `NSOrderedDescending` 表示 `version1` 为更高版本。
/// @li 3、返回值 `NSOrderedSame` 表示版本号相同，或者两个参数不是合法的版本号字符串。
/// @li 4、若参数指针相同，则认为版本号相同，不论它们是否合法。
/// @li 5、若参数类型非法，那么字符串比非字符串的版本号更高，否则版本号相等。
/// @param version1 待比较的版本号1
/// @param version2 待比较的版本号2
FOUNDATION_EXPORT NSComparisonResult XZVersionCompare(NSString * _Nullable version1, NSString * _Nullable version2) NS_SWIFT_UNAVAILABLE("Use Swift.Version instead");

/// 获取当前的时间戳。使用 `gettimeofday` 函数，不会创建 `NSDate` 对象。
FOUNDATION_EXPORT NSTimeInterval XZTimestamp(void) NS_SWIFT_NAME(timestamp());

/// 如果 urlString 无法直接构造 NSURL 对象，则尝试检测并编码其中的非法字符，然后再尝试构造 NSURL 对象。
/// - Parameter urlString: URL字符串
FOUNDATION_EXPORT NSURL * _Nullable NSURLFromString(NSString * _Nullable urlString);

/// 格式化字符串构造 NSURL 对象的便利函数。
/// - Parameter format: 字符串格式模版
FOUNDATION_EXPORT NSURL * _Nullable NSURLMake(NSString *format, ...) NS_FORMAT_FUNCTION(1,2) NS_SWIFT_UNAVAILABLE("Not Supported");

NS_ASSUME_NONNULL_END
