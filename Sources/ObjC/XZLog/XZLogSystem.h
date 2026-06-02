//
//  XZLogSystem.h
//  XZKit
//
//  Created by Xezun on 2025/7/3.
//

#import <Foundation/Foundation.h>
#import <OSLog/OSLog.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, XZLogType) {
    XZLogTypeDebug,
    XZLogTypeError,
    XZLogTypeFault,
};

/// 日志系统，用来标记日志类型，以及控制日志的输出。
/// @note 日志系统不是线程安全的，请自行保证线程安全，比如只初始化一次。
@interface XZLogSystem : NSObject

/// 默认日志输出，默认启用。
@property (class, nonatomic, readonly) XZLogSystem *defaultLogSystem;

/// 库 XZKit 中的输出系统。默认关闭。
@property (class, nonatomic, readonly) XZLogSystem *XZKitLogSystem NS_SWIFT_NAME(XZKit);

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
- (instancetype)initWithName:(NSString *)name domain:(NSString *)domain;

// not in use for now
- (BOOL)isLogEnabledForType:(XZLogType)type;
- (void)setLogEnabled:(BOOL)isLogEnabled forType:(XZLogType)type;

/// 当前未启用。
/// 使用 OSLog 框架时，执行日志输出的对象。
@property (nonatomic, readonly) os_log_t oslogSystem;

@end

NS_ASSUME_NONNULL_END
