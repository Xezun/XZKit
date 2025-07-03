//
//  XZLogSystem.h
//  XZKit
//
//  Created by 徐臻 on 2025/7/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XZLogSystem : NSObject

/// XZKit 日志输出。
@property (class, nonatomic, readonly) XZLogSystem *XZKit NS_SWIFT_NAME(XZKit);

@property (nonatomic, readonly) NSString *domain;
@property (nonatomic, setter=setEnabled:) BOOL isEnabled;

- (instancetype)initWithDomain:(NSString *)domain;

@end

NS_ASSUME_NONNULL_END
