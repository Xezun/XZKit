//
//  XZMocoaTableSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import <UIKit/UIKit.h>
#import "XZMocoaGroupSupplementView.h"
#import "XZMocoaTableSupplementViewModel.h"

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

@interface XZMocoaTableHeaderView : XZMocoaTableSupplementView
@end

@interface XZMocoaTableFooterView : XZMocoaTableSupplementView 
@end

NS_ASSUME_NONNULL_END
