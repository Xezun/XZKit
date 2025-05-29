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
@protocol XZMocoaTableViewCell <XZMocoaGridViewCell>

@optional
/// ViewModel 对象。
/// @note 监听此属性，子类不需要重写，直接方法 -viewModelDidUpdate 中操作即可。
/// @note 在设置新值时，将先从移除旧的 viewModel 上绑定的事件。
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewCellViewModel *viewModel;

- (void)tableView:(id<XZMocoaTableView>)tableView didUpdateForKey:(XZMocoaUpdatesKey)key atIndexPath:(NSIndexPath *)indexPath;

@end

@interface UITableViewCell (XZMocoaTableViewCell)
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewCellViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
