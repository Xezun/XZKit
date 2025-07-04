//
//  XZLogSystem.h
//  XZKit
//
//  Created by 徐臻 on 2025/7/3.
//

#import <Foundation/Foundation.h>
@import OSLog;

NS_ASSUME_NONNULL_BEGIN

@interface XZLogSystem : NSObject

/// 默认日志输出，默认启用。
@property (class, nonatomic, readonly) XZLogSystem *defaultLogSystem;

/// 库 XZKit 中的输出系统。默认关闭。
@property (class, nonatomic, readonly) XZLogSystem *XZKitLogSystem NS_SWIFT_NAME(XZKit);

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *domain;
@property (nonatomic, setter=setEnabled:) BOOL isEnabled;

- (instancetype)initWithName:(NSString *)name domain:(NSString *)domain type:(os_log_type_t)type;

// not in use for now

@property (class, nonatomic, readonly) XZLogSystem *debugLogSystem;
@property (class, nonatomic, readonly) XZLogSystem *errorLogSystem;
@property (class, nonatomic, readonly) XZLogSystem *faultLogSystem;
@property (nonatomic, readonly) os_log_t OSLogSystem;
@property (nonatomic, readonly) os_log_type_t OSLogType;

@end

NS_ASSUME_NONNULL_END
