//
//  XZMocoaTableSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupSupplementView.h>
#import <XZKit/XZMocoaTableSupplementViewModel.h>
#else
#import "XZMocoaGroupSupplementView.h"
#import "XZMocoaTableSupplementViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaTableSupplementView <XZMocoaGroupSupplementView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaTableSupplementViewModel *viewModel;
@end

@interface UITableViewHeaderFooterView (XZMocoaTableSupplementView)
@property (nonatomic, strong, nullable) __kindof XZMocoaTableSupplementViewModel *viewModel;
@end

@interface XZMocoaTableSupplementView : UITableViewHeaderFooterView <XZMocoaTableSupplementView>
@end

@interface XZMocoaTableSectionHeaderView : XZMocoaTableSupplementView <XZMocoaTableSupplementView>
@end

@interface XZMocoaTableSectionFooterView : XZMocoaTableSupplementView <XZMocoaTableSupplementView>
@end

NS_ASSUME_NONNULL_END
