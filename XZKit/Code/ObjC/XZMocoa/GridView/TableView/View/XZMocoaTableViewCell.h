//
//  XZMocoaTableViewCell.h
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZMocoaGridViewCell.h"
#import "XZMocoaTableViewCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaTableView;

/// 使用 Mocoa 时，UITableViewCell 应遵循本协议。
/// @note
/// UITableViewCell 已默认实现了本协议，如需使用仅需声明遵循协议即可。
@protocol XZMocoaTableViewCell <XZMocoaGridViewCell>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewCellViewModel *viewModel;
@end

@interface UITableViewCell (XZMocoaTableViewCell)
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewCellViewModel *viewModel;
/// 当前 Cell 的点击事件。
/// @param tableView 当前 Cell 所属的 UITableView 对象
/// @param indexPath 当前 Cell 的当前所在的位置
- (void)tableView:(id<XZMocoaTableView>)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

/// 当前 Cell 将要被展示在指定位置。
/// @param tableView 当前 Cell 所属的 UITableView 对象
/// @param indexPath 当前 Cell 的将要展示的位置
- (void)tableView:(id<XZMocoaTableView>)tableView willDisplayRowAtIndexPath:(NSIndexPath *)indexPath;

/// 当前 Cell 已结束在指定位置的展示。
/// @param tableView 当前 Cell 所属的 UITableView 对象
/// @param indexPath 当前 Cell 的当前所在的位置
- (void)tableView:(id<XZMocoaTableView>)tableView didEndDisplayingRowAtIndexPath:(NSIndexPath*)indexPath;

/// 当前 Cell 的侧滑编辑事件。
/// @param tableView cell 所在的容器视图
/// @param indexPath cell 在容器视图中的位置
/// @param key 已选择的侧滑编辑事件
- (void)tableView:(id<XZMocoaTableView>)tableView didUpdateRowAtIndexPath:(NSIndexPath *)indexPath forKey:(XZMocoaUpdatesKey)key;
@end

NS_ASSUME_NONNULL_END
