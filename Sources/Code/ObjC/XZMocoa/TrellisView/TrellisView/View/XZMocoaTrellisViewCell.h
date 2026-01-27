//
//  XZMocoaTrellisViewCell.h
//  XZMocoa
//
//  Created by 徐臻 on 2025/5/29.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaTrellisViewCellViewModel.h>
#else
#import "XZMocoaView.h"
#import "XZMocoaTrellisViewCellViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_UI_ACTOR @protocol XZMocoaTrellisViewCell <XZMocoaView>
@optional
/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaTrellisViewCellViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
