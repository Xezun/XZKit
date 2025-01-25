//
//  XZMocoaTableViewCell.h
//  XZMocoa
//
//  Created by Xezun on 2021/1/13.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XZMocoaTableView.h"
#import "XZMocoaTableViewCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UITableViewDelegate;

/// 使用 Mocoa 时，UITableViewCell 应遵循本协议。
/// @note
/// UITableViewCell 已默认实现了本协议，如需使用仅需声明遵循协议即可。
@protocol XZMocoaTableViewCell <XZMocoaView>

@optional
/// ViewModel 对象。
/// @note 监听此属性，子类不需要重写，直接方法 -viewModelDidUpdate 中操作即可。
/// @note 在设置新值时，将先从移除旧的 viewModel 上绑定的事件。
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewCellViewModel *viewModel;

// MARK: - 由当前 Cell 所在的 UITableView 传递回来的事件

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

@end

/// 因一致性而提供，非必须基类。
/// @note 任何 UITableViewCell 对象都可以作为 Mocoa 的 View 实例，而非必须基于此类。
@interface XZMocoaTableViewCell : UITableViewCell <XZMocoaTableViewCell>
@end

NS_ASSUME_NONNULL_END
