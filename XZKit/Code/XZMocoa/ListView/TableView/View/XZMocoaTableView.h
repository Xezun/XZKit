//
//  XZMocoaTableView.h
//  XZMocoa
//
//  Created by Xezun on 2021/3/24.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaListView.h"
#import "XZMocoaTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

// 在 IB 中，IBInspectable 值在 -initWithCoder: 中并没有被赋值，一般需要在 -awakeFromNib 方法中才能获取。
// 命名规则：tableView/tableViewCell/tableViewHeaderFooterView
// XZMocoaTableModel
// XZMocoaTableView
// XZMocoaTableViewModel
// -
// XZMocoaTableViewCell
// XZMocoaTableViewCellModel
// XZMocoaTableViewCellViewModel


/// 对 UITableView 进行了封装，以支持 MVVM 设计模式。
@interface XZMocoaTableView : XZMocoaListView

/// 视图模型。
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewModel *viewModel;

/// 视图 UITableView 将作为 contentView 呈现。
/// @note
/// 当前视图接管了 delegate 和 dataSource 代理，请避免更改这两属性。
/// @discussion
/// 在 IB 中使用 XZMocoaTableView 时，将 UITableView 关联到此属性上即可。
@property (nonatomic, strong) IBOutlet UITableView *contentView;

/// 指定初始化方法，可以在初始化时，指定内部使用的`tableView`的类型及样式。
/// @param tableViewClass 该参数决定属性`tableView`的实际类型
/// @param style 属性`tableView`的样式
- (instancetype)initWithTableViewClass:(Class)tableViewClass style:(UITableViewStyle)style NS_DESIGNATED_INITIALIZER;

/// 支持在 IB 中使用，添加 UITableView 作为子视图并 outlet 关联到 contentView 属性即可。
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

/// 便利方法，使用`UITableView`作为初始化类型。
/// @param frame 当前试图的展示区域
/// @param style 属性`tableView`的样式
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;

/// 便利方法，使用`UITableView`作为初始化类型。
/// @note 默认创建的视图大小，与屏幕相同。
/// @param style 属性`tableView`的样式
- (instancetype)initWithStyle:(UITableViewStyle)style;

@end

@class UICollectionView;

// MARK: - 下面的方法，子类在重写时，根据实际情况判断是否需要调用父类方法。

/// XZMocoaTableView 实现了协议 UITableViewDataSource 中的方法列表。
@interface XZMocoaTableView (UITableViewDataSource) <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (__kindof UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

/// XZMocoaTableView 没有实现任何 UIScrollViewDelegate 中的方法。
/// @note 由于父类并没有实现这些方法，子类重写不需要调用父类方法。
/// @note 出于性能考虑，协议 UIScrollViewDelegate 中的方法请按需实现，避免实现空方法。
@interface XZMocoaTableView (UIScrollViewDelegate) <UIScrollViewDelegate>
@end

/// XZMocoaTableView 已实现的协议 UITableViewDelegate 中的方法。
/// @note 子类可以重写自己的实现，或者调用父类的实现。
@interface XZMocoaTableView (UITableViewDelegate) <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

/// XZMocoaTableView 实现了协议 XZMocoaTableViewModelDelegate 中的全部方法。
/// @note 子类可以重写自己的实现，或者调用父类的实现。
@interface XZMocoaTableView (XZMocoaTableViewModelDelegate) <XZMocoaTableViewModelDelegate>
@end

NS_ASSUME_NONNULL_END
