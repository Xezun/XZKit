//
//  XZMocoaGridSupplementaryView.h
//  XZMocoa
//
//  Created by 徐臻 on 2025/5/29.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaView.h>
#import <XZKit/XZMocoaGridSupplementaryViewModel.h>
#else
#import "XZMocoaView.h"
#import "XZMocoaGridSupplementaryViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaGridSupplementaryView <XZMocoaView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaGridSupplementaryViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
