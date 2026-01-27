//
//  XZMocoaTableViewHeaderFooterView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTrellisViewSupplementaryView.h>
#import <XZKit/XZMocoaTableViewHeaderFooterViewModel.h>
#else
#import "XZMocoaTrellisViewSupplementaryView.h"
#import "XZMocoaTableViewHeaderFooterViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaTableViewHeaderFooterView <XZMocoaTrellisViewSupplementaryView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewHeaderFooterViewModel *viewModel;
@end

@interface UITableViewHeaderFooterView (XZMocoaTableViewHeaderFooterView)
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewHeaderFooterViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
