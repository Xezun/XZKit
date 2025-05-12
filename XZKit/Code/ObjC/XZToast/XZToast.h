//
//  XZToast.h
//  XZToast
//
//  Created by 徐臻 on 2025/3/2.
//

#import <UIKit/UIKit.h>
#import "XZToastDefines.h"
#import "UIKit+XZToast.h"

NS_ASSUME_NONNULL_BEGIN

/// 一种用于展示业务或逻辑状态的提示消息。
///
/// 这是一个基类，业务可通过子类自定义提示消息的视图。
@interface XZToast : NSObject

/// 呈现提示消息的视图。
@property (nonatomic, readonly) __kindof UIView *view;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithView:(UIView *)view NS_DESIGNATED_INITIALIZER;

/// 便利构造方法。
/// - Parameter view: 呈现提示消息的视图
+ (instancetype)viewToast:(UIView *)view NS_SWIFT_UNAVAILABLE("Use instance initializer instead.");

/// 消息类型的提示。
/// - Parameter text: 文本内容
+ (instancetype)messageToast:(NSString *)text NS_SWIFT_NAME(init(message:));

/// 加载类型的提示。
/// - Parameter text: 文本内容
+ (instancetype)loadingToast:(nullable NSString *)text NS_SWIFT_NAME(init(loading:));

/// 操作状态提示类型：成功状态。
/// - Parameter text: 文本内容
+ (instancetype)successToast:(nullable NSString *)text NS_SWIFT_NAME(init(success:));

/// 操作状态提示类型：失败状态。
/// - Parameter text: 文本内容
+ (instancetype)failureToast:(nullable NSString *)text NS_SWIFT_NAME(init(failure:));

/// 操作状态提示类型：警告状态。
/// - Parameter text: 文本内容
+ (instancetype)warningToast:(nullable NSString *)text NS_SWIFT_NAME(init(warning:));

/// 操作状态提示类型：等待状态。
/// - Parameter text: 文本内容
+ (instancetype)waitingToast:(nullable NSString *)text NS_SWIFT_NAME(init(waiting:));

@end

NS_ASSUME_NONNULL_END
