//
//  XZMocoaTableCell.h
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZMocoaGroupReusableView.h"
#import "XZMocoaTableCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef UITableViewCell XZMocoaTableCell;

@interface UITableViewCell (XZMocoaTableCell)

/// 视图模型。
/// @attention 在 Cell 回归重用池时，此属性不会置空，所以如果执行清理操作，需要重写``-prepareForReuse``方法。
@property (nonatomic, strong, nullable) __kindof XZMocoaTableCellViewModel *viewModel;

/// 当前 cell 所在的列表容器。
@property (nonatomic, readonly, nullable) UITableView *xz_tableView NS_SWIFT_NAME(tableView);

/// 当前 Cell 的点击事件。默认不执行任何操作。
/// @param tableView 当前 Cell 所属的 UITableView 对象
/// @param indexPath 当前 Cell 的当前所在的位置
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

/// 当前 Cell 将要被展示在指定位置。默认不执行任何操作。
/// @param tableView 当前 Cell 所属的 UITableView 对象
/// @param indexPath 当前 Cell 的将要展示的位置
- (void)tableView:(UITableView *)tableView willDisplayRowAtIndexPath:(NSIndexPath *)indexPath;

/// 当前 Cell 已结束在指定位置的展示。默认不执行任何操作。
/// @param tableView 当前 Cell 所属的 UITableView 对象
/// @param indexPath 当前 Cell 的当前所在的位置
- (void)tableView:(UITableView *)tableView didEndDisplayingRowAtIndexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END
