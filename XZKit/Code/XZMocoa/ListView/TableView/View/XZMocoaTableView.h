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

@protocol XZMocoaTableView <XZMocoaListView>
@property (nonatomic, strong, nullable) __kindof XZMocoaTableViewModel *viewModel;
@property (nonatomic, strong) IBOutlet UITableView *contentView;
@end

@class XZMocoaTableViewProxy;

/// 对 UITableView 进行了封装，以支持 MVVM 设计模式。
@interface XZMocoaTableView : XZMocoaListView <XZMocoaTableView>

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

@property (nonatomic, strong) XZMocoaTableViewProxy *proxy;

@end

@class UICollectionView;

@interface XZMocoaTableViewProxy : NSProxy <XZMocoaTableView>
@property (nonatomic, unsafe_unretained, readonly) id<XZMocoaTableView> tableView;
@property (nonatomic, strong, nullable) XZMocoaTableViewModel *viewModel;
@property (nonatomic, weak) id<UITableViewDelegate> delegate;
@property (nonatomic, weak) id<UITableViewDataSource> dataSource;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithTableView:(id<XZMocoaTableView>)tableView;
@end

/// 协议 UITableViewDataSource 中已实现方法列表。
@interface XZMocoaTableViewProxy (UITableViewDataSource) <UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (__kindof UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

/// 协议 UITableViewDelegate 中已实现方法列表。
@interface XZMocoaTableViewProxy (UITableViewDelegate) <UITableViewDelegate>
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
@end

/// 已实现了 XZMocoaTableViewModelDelegate 的全部方法
@interface XZMocoaTableViewProxy (XZMocoaTableViewModelDelegate) <XZMocoaTableViewModelDelegate>
@end

NS_ASSUME_NONNULL_END
