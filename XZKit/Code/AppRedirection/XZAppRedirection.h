//
//  XZAppRedirection.h
//  XZKit
//
//  Created by Xezun on 2018/6/12.
//  Copyright © 2018年 XEZUN INC. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 设计思路：当一个重定向任务发送给根控制器之后，这个任务就会像响应者链一样向下传递，直至目的页面。
 因为每个控制都知道自己可以到达的“下级控制器”，那么就从根控制器开始发送重定向任务，由控制器决定重定向任务要转发的下级控制器。
 基于此，首先需要约定重定向任务的规则，那么当控制器收到重定向任务后，通过约定好的规则，判断重定向任务中是否有其需要执行的操作。
 当控制器执行完重定向操作后（导航到下级或打开新的页面），再尝试将重定向任务发送至下级控制器。
 
 为了保证控制器生命周期的完整，重定向的任务可以在控制器生命周期任意阶段发送，但是重定向任务只会在控制器处于显示状态时被调用。
 
 本框架只处理了重定向事件触发和转发的问题，而约定重定向规则需根据具体的业务逻辑进行，即根据不同的业务，设计不同的 redirection 信息。
 
 @note 由于 Swift 一些特性，以及运行时的限制等原因，不能完美实现。
 */

@interface UIViewController (XZAppRedirection)

/// 此属性用于标识控制器是否正在显示。当且仅当控制器生命周期在 [viewDidAppear, viewWillDisappear) 之间时，此属性为 YES 。
///
/// @note 此属性的意义在于，当此属性为 YES 时，可以直接在此控制器上进行转场。
/// @note 当子类控制器 viewDidAppear 方法被调用时，此属性已为 YES 。
/// @note 当子类控制器 viewWillDisappear 方法被调用时，此属性已为 NO 。
@property (nonatomic, readonly) BOOL xz_isAppearing NS_SWIFT_NAME(isAppearing);

/// 将重定向任务派送给控制器。
/// @note 在同一个 runloop 中，多次发送的重定向任务，只有最后发送的有效。
/// @note 如果重定向任务设置 nil ，则会取消当前的重定向任务（如果还没执行）。
///
/// @param redirection 重定向任务。
- (void)xz_setNeedsRedirectWithRedirection:(nullable id)redirection NS_SWIFT_NAME(setNeedsRedirect(with:));

/// 如果当前控制器有未进行的任务，则立即调用 `-didRecevieRedirection:` 方法。
/// @note 未标记需要重定向时，不执行任何操作。
/// @note 控制器未显示时，不执行任何操作（控制器显示时，会自动调用本方法）。
/// @note 没有重定向任务时，不执行任何操作。
/// @note 执行重定向任务（调用 `-didRecevieRedirection:` 方法），如果有下级控制器，自动将重定向任务发送给下级控制器（任务信息同步移动到下一个）。
///
/// @note 默认情况下，该方法会在控制器处于显示状态时自动执行。
- (void)xz_redirectIfNeeded NS_SWIFT_NAME(redirectIfNeeded());

/// 执行重定向，并返回重定向的下级控制器。
/// @note 该方法只在控制器处于显示状态时（viewDidAppear之后）才会被调用。
///
///
/// @param redirection 重定向任务。
/// @return 重定向任务的下一个控制器。
- (nullable UIViewController *)xz_didRecevieRedirection:(nonnull id)redirection NS_SWIFT_NAME(didRecevieRedirection(_:));

@end




