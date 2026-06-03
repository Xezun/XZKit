//
//  XZMocoaGridCell.h
//  XZMocoa
//
//  Created by Xezun on 2025/5/29.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaGridCellViewModel.h>
#else
#import "XZMocoaView.h"
#import "XZMocoaGridCellViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR @protocol XZMocoaGridCell <XZMocoaView>
@optional
/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaGridCellViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
