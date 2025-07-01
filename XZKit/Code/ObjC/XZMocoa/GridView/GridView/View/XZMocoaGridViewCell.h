//
//  XZMocoaGridViewCell.h
//  XZMocoa
//
//  Created by 徐臻 on 2025/5/29.
//

#import <UIKit/UIKit.h>
#import "XZMocoaView.h"
#import "XZMocoaGridViewCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaGridViewCell <XZMocoaView>
@optional
/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaGridViewCellViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
