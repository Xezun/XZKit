//
//  XZLogSystem.h
//  XZKit
//
//  Created by Xezun on 2025/7/3.
//

#import <Foundation/Foundation.h>
#import <OSLog/OSLog.h>

NS_ASSUME_NONNULL_BEGIN

/// 日志系统，用来标记日志类型，以及控制日志的输出。
/// @note 日志系统不是线程安全的，请自行保证线程安全，比如只初始化一次。
@interface XZLogSystem : NSObject

/// 默认日志输出，默认启用。
@property (class, nonatomic, readonly) XZLogSystem *defaultSystem NS_SWIFT_NAME(default);

/// 库 XZKit 中的输出系统。默认关闭。
@property (class, nonatomic, readonly) XZLogSystem *XZKitSystem NS_SWIFT_NAME(XZKit);

/// 给日志系统取的名称。
@property (nonatomic, readonly) NSString *name;

/// 日志系统的标识符。
@property (nonatomic, readonly) NSString *domain;

/// 是否允许日志输出。
@property (nonatomic, setter=setEnabled:) BOOL isEnabled;

/// 构造日志输出系统。
/// - Parameters:
///   - name: 名称
///   - domain: 标识符
///   - type: 日志类别
- (instancetype)initWithName:(NSString *)name domain:(NSString *)domain NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

/// 在 Swift 中，宏 `#XZLog` 使用 OSLog 框架输出的日志。
@property (nonatomic, readonly) os_log_t oslog;

@end

NS_ASSUME_NONNULL_END
