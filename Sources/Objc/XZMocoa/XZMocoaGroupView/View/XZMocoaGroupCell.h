//
//  XZMocoaGroupCell.h
//  XZMocoa
//
//  Created by Xezun on 2025/5/29.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaGroupCellViewModel.h>
#else
#import "XZMocoaView.h"
#import "XZMocoaGroupCellViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR @protocol XZMocoaGroupCell <XZMocoaView>
@optional
/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaGroupCellViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
