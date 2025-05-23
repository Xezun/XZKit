//
//  XZMocoaTableView.h
//  XZMocoa
//
//  Created by Xezun on 2021/3/24.
//  Copyright © 2021 Xezun. All rights reserved.
//

#import "XZMocoaGridView.h"
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

@protocol XZMocoaTableView <XZMocoaGridView>
@optional
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewModel *viewModel;
@property (nonatomic, strong) IBOutlet UITableView *contentView;
@end

/// 对 UITableView 进行了封装，以支持 MVVM 设计模式。
@interface XZMocoaTableView : XZMocoaGridView <XZMocoaTableView>

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

@interface XZMocoaTableView (UITableViewDataSource) <UITableViewDataSource>
@end

@interface XZMocoaTableView (UITableViewDelegate) <UITableViewDelegate>
@end

@interface XZMocoaTableView (XZMocoaTableViewModelDelegate) <XZMocoaTableViewModelDelegate>
@end

NS_ASSUME_NONNULL_END
