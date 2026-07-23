//
//  XZMocoaTableSectionHeaderFooterView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSectionSupplementaryView.h>
#import <XZKit/XZMocoaTableSectionHeaderFooterViewModel.h>
#else
#import "XZMocoaGroupSectionSupplementaryView.h"
#import "XZMocoaTableSectionHeaderFooterViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaTableSectionHeaderFooterView <XZMocoaGroupSectionSupplementaryView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaTableSectionHeaderFooterViewModel *viewModel;
@end

@interface UITableViewHeaderFooterView (XZMocoaTableSectionHeaderFooterView)
@property (nonatomic, strong, nullable) __kindof XZMocoaTableSectionHeaderFooterViewModel *viewModel;
@end

@interface XZMocoaTableSectionHeaderFooterView : UITableViewHeaderFooterView <XZMocoaTableSectionHeaderFooterView>
@end

@interface XZMocoaTableSectionHeaderView : XZMocoaTableSectionHeaderFooterView <XZMocoaTableSectionHeaderFooterView>
@end

@interface XZMocoaTableSectionFooterView : XZMocoaTableSectionHeaderFooterView <XZMocoaTableSectionHeaderFooterView>
@end

NS_ASSUME_NONNULL_END
