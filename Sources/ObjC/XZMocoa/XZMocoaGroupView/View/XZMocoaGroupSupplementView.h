//
//  XZMocoaGroupSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2025/5/29.
//

#import <UIKit/UIKit.h>
#import "XZMocoaView.h"
#import "XZMocoaGroupSupplementViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaGroupSupplementView <XZMocoaView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaGroupSupplementViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
