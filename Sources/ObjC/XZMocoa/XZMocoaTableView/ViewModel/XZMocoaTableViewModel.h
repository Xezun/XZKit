//
//  XZMocoaTableViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaGroupViewModel.h"
#import "XZMocoaTableSupplementViewModel.h"
#import "XZMocoaTableCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaTableViewModel;

/// 为 XZMocoaTableView 提供监听 ViewModel 事件的协议。
@protocol XZMocoaTableViewModelDelegate <XZMocoaGroupViewModelDelegate>
@required
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

/// XZMocoaTableView 的视图模型基类。
@interface XZMocoaTableViewModel : XZMocoaGroupViewModel

@property (nonatomic, weak) id<XZMocoaTableViewModelDelegate> delegate;

/// 在进行批量更新或局部更新时，视图更新的动画效果，默认为 UITableViewRowAnimationAutomatic 自动选择合适的动画效果。
@property (nonatomic) UITableViewRowAnimation rowAnimation;
/// 总高度。
@property (nonatomic, readonly) CGFloat height;

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;

@end

@interface XZMocoaTableViewModel (XZMocoaTableViewModel)
///// section 视图模型集合。
//@property (nonatomic, readonly) NSArray<__kindof XZMocoaTableSectionViewModel *> *sectionViewModels;
///// 获取 section 视图模型。
///// - Parameter index: 位置
//- (__kindof XZMocoaTableSectionViewModel *)sectionViewModelAtIndex:(NSInteger)index;
///// 获取 cell 视图模型。
///// - Parameter indexPath: 位置
//- (__kindof XZMocoaTableCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
