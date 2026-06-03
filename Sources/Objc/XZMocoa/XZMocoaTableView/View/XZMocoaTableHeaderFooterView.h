//
//  XZMocoaTableHeaderFooterView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSupplementaryView.h>
#import <XZKit/XZMocoaTableHeaderFooterViewModel.h>
#else
#import "XZMocoaGroupSupplementaryView.h"
#import "XZMocoaTableHeaderFooterViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaTableHeaderFooterView <XZMocoaGroupSupplementaryView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaTableHeaderFooterViewModel *viewModel;
@end

@interface UITableViewHeaderFooterView (XZMocoaTableHeaderFooterView)
@property (nonatomic, strong, nullable) __kindof XZMocoaTableHeaderFooterViewModel *viewModel;
@end

@interface XZMocoaTableHeaderFooterView : UITableViewHeaderFooterView <XZMocoaTableHeaderFooterView>
@end

@interface XZMocoaTableHeaderView : XZMocoaTableHeaderFooterView <XZMocoaTableHeaderFooterView>
@end

@interface XZMocoaTableFooterView : XZMocoaTableHeaderFooterView <XZMocoaTableHeaderFooterView>
@end

NS_ASSUME_NONNULL_END
