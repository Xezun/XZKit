//
//  XZMocoaTableViewCellViewModel.h
//  
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridViewCellViewModel.h>
#else
#import "XZMocoaGridViewCellViewModel.h"
#endif

@protocol XZMocoaTableView, XZMocoaTableViewCell;

NS_ASSUME_NONNULL_BEGIN

/// UITableViewCell 视图模型基类。
@interface XZMocoaTableViewCellViewModel : XZMocoaGridViewCellViewModel
/// 视图高度。
@property (nonatomic) CGFloat height;

- (void)tableView:(id<XZMocoaTableView>)tableView didSelectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(id<XZMocoaTableView>)tableView didDeselectCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(id<XZMocoaTableView>)tableView willDisplayCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(id<XZMocoaTableView>)tableView didEndDisplayingCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(id<XZMocoaTableView>)tableView didEditCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forUpdatesKey:(XZMocoaUpdatesKey)key completion:(void (^ _Nullable)(BOOL))completion NS_SWIFT_NAME(tableView(_:didEdit:at:forUpdates:completion:));

@end

NS_ASSUME_NONNULL_END
