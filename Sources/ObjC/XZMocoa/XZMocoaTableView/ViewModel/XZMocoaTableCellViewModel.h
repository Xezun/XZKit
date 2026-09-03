//
//  XZMocoaTableCellViewModel.h
//  
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaGroupReusableViewModel.h"

@protocol XZMocoaTableView, XZMocoaTableCell, UITableViewDelegate;

NS_ASSUME_NONNULL_BEGIN

/// UITableViewCell 视图模型基类。
NS_SWIFT_UI_ACTOR @interface XZMocoaTableCellViewModel : XZMocoaGroupReusableViewModel
/// 视图高度。
@property (nonatomic) CGFloat height;

- (void)tableViewCell:(UITableViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell wasDeselectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell willBeDisplayedAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell wasEndedDisplayingAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
