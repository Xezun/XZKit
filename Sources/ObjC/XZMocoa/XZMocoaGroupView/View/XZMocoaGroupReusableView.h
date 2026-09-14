//
//  XZMocoaGroupReusableView.h
//  XZMocoa
//
//  Created by Xezun on 2025/5/29.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupReusableViewModel.h>
#else
#import "XZMocoaGroupReusableViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR @protocol XZMocoaGroupReusableView <XZMocoaView>
@optional
/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaGroupReusableViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
