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

@protocol XZMocoaTableView, UITableViewDelegate;

/// 使用 Mocoa 时，UITableViewCell 应遵循本协议。
/// @note
/// UITableViewCell 已默认实现了本协议，如需使用仅需声明遵循协议即可。
@protocol XZMocoaTableViewCell <XZMocoaGridViewCell>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewCellViewModel *viewModel;
@end

@interface UITableViewCell (XZMocoaTableViewCell)

/// 视图模型。
/// @attention 在 Cell 回归重用池时，此属性不会置空，所以如果执行清理操作，需要重写``-prepareForReuse``方法。
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewCellViewModel *viewModel;

/// 当前 Cell 的点击事件。默认不执行任何操作。
/// @param tableView 当前 Cell 所属的 UITableView 对象
/// @param indexPath 当前 Cell 的当前所在的位置
- (void)tableView:(id<XZMocoaTableView>)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(id<XZMocoaTableView>)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

/// 当前 Cell 将要被展示在指定位置。默认不执行任何操作。
/// @param tableView 当前 Cell 所属的 UITableView 对象
/// @param indexPath 当前 Cell 的将要展示的位置
- (void)tableView:(id<XZMocoaTableView>)tableView willDisplayRowAtIndexPath:(NSIndexPath *)indexPath;

/// 当前 Cell 已结束在指定位置的展示。默认不执行任何操作。
/// @param tableView 当前 Cell 所属的 UITableView 对象
/// @param indexPath 当前 Cell 的当前所在的位置
- (void)tableView:(id<XZMocoaTableView>)tableView didEndDisplayingRowAtIndexPath:(NSIndexPath*)indexPath;

/// 当前 Cell 的更新事件，比如侧滑编辑、删除等事件。默认直接通过层级关系向上传递事件。
/// @param tableView cell 所在的容器视图
/// @param indexPath cell 在容器视图中的位置
/// @param key 更新事件类型
- (void)tableView:(id<XZMocoaTableView>)tableView didEditRowAtIndexPath:(NSIndexPath *)indexPath forUpdatesKey:(XZMocoaUpdatesKey)key completion:(void (^_Nullable)(BOOL succeed))completion NS_SWIFT_NAME(tableView(_:didEditRowAt:forUpdates:completion:));
@end

NS_ASSUME_NONNULL_END
