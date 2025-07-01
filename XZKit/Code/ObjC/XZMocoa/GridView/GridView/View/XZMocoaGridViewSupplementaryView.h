//
//  XZMocoaGridViewSupplementaryView.h
//  XZMocoa
//
//  Created by 徐臻 on 2025/5/29.
//

#import <UIKit/UIKit.h>
#import "XZMocoaView.h"
#import "XZMocoaGridViewSupplementaryViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaGridViewSupplementaryView <XZMocoaView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaGridViewSupplementaryViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
