//
//  XZMocoaTableViewCellViewModel.h
//  
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaGridViewCellViewModel.h"

@protocol XZMocoaTableView, XZMocoaTableViewCell;

NS_ASSUME_NONNULL_BEGIN

/// UITableViewCell 视图模型基类。
@interface XZMocoaTableViewCellViewModel : XZMocoaGridViewCellViewModel
/// 视图高度。
@property (nonatomic) CGFloat height;

- (void)tableView:(id<XZMocoaTableView>)tableView didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(id<XZMocoaTableView>)tableView willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(id<XZMocoaTableView>)tableView didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(id<XZMocoaTableView>)tableView didUpdateCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forKey:(XZMocoaUpdatesKey)key;

@end

NS_ASSUME_NONNULL_END
