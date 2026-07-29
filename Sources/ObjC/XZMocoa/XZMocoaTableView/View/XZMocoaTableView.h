//
//  XZMocoaTableView.h
//  XZMocoa
//
//  Created by Xezun on 2021/3/24.
//  Copyright © 2021 Xezun. All rights reserved.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableViewModel.h>
#import <XZKit/XZMocoaGroupView.h>
#else
#import "XZMocoaGroupView.h"
#import "XZMocoaTableViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

// 在 IB 中，IBInspectable 值在 -initWithCoder: 中并没有被赋值，一般需要在 -awakeFromNib 方法中才能获取。
// 命名规则：tableView/tableViewCell/tableViewHeaderFooterView
// XZMocoaTableModel
// XZMocoaTableView
// XZMocoaTableViewModel
// -
// XZMocoaTableCell
// XZMocoaTableCellModel
// XZMocoaTableCellViewModel
// -
// <XZMocoaTableSection> 虚拟层，无视图
// XZMocoaTableSectionModel
// XZMocoaTableSectionViewModel

NS_SWIFT_UI_ACTOR @protocol XZMocoaTableView <XZMocoaGroupView>
@required
@property (nonatomic, strong, nullable) XZMocoaTableViewModel *viewModel;
@property (nonatomic, strong) IBOutlet UITableView *contentView;
- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didReloadData:(void * _Nullable)null;

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didDeselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didReloadCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didInsertCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didDeleteCellsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths;
- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didMoveCellAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didReloadSectionsAtIndexes:(NSIndexSet *)sections;
- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didInsertSectionsAtIndexes:(NSIndexSet *)sections;
- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didDeleteSectionsAtIndexes:(NSIndexSet *)sections;
- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didMoveSectionAtIndex:(NSInteger)section toIndex:(NSInteger)newSection;

- (void)tableViewModel:(XZMocoaTableViewModel *)tableViewModel didPerformBatchUpdates:(void (^NS_NOESCAPE)(void))batchUpdates completion:(void (^ _Nullable)(BOOL finished))completion;
@end

/// 对 UITableView 进行了封装，以支持 MVVM 设计模式。
NS_SWIFT_UI_ACTOR @interface XZMocoaTableView : XZMocoaGroupView

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

// 以下由 XZMocoaTableViewProxy 动态实现。

@interface XZMocoaTableView (UITableViewDataSource) <UITableViewDataSource>
@end
@interface XZMocoaTableView (UITableViewDelegate) <UITableViewDelegate>
@end
@interface XZMocoaTableView (XZMocoaTableView) <XZMocoaTableView>
@property (nonatomic, strong, nullable) XZMocoaTableViewModel *viewModel;
@property (nonatomic, strong) IBOutlet UITableView *contentView;
@end

NS_ASSUME_NONNULL_END
