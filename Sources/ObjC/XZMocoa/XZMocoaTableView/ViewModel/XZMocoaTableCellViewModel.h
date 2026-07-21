//
//  XZMocoaTableCellViewModel.h
//  
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupCellViewModel.h>
#else
#import "XZMocoaGroupCellViewModel.h"
#endif

@protocol XZMocoaTableView, XZMocoaTableCell, UITableViewDelegate;

NS_ASSUME_NONNULL_BEGIN

/// UITableViewCell 视图模型基类。
NS_SWIFT_UI_ACTOR @interface XZMocoaTableCellViewModel : XZMocoaGroupCellViewModel
/// 视图高度。
@property (nonatomic) CGFloat height;

- (void)tableViewCell:(UITableViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell wasDeselectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell willBeDisplayedAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell wasEndedDisplayingAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableViewCell:(UITableViewCell *)cell wasEndedEditingAtIndexPath:(NSIndexPath *)indexPath withEventsName:(XZMocoaEventsName)name completion:(void (NS_SWIFT_NONSENDABLE ^ _Nullable)(BOOL))completion;

@end

NS_ASSUME_NONNULL_END
