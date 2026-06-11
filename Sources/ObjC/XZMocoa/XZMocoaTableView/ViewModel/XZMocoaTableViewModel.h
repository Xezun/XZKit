//
//  XZMocoaTableViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupViewModel.h>
#import <XZKit/XZMocoaTableSectionViewModel.h>
#import <XZKit/XZMocoaTableHeaderFooterViewModel.h>
#import <XZKit/XZMocoaTableCellViewModel.h>
#else
#import "XZMocoaGroupViewModel.h"
#import "XZMocoaTableSectionViewModel.h"
#import "XZMocoaTableHeaderFooterViewModel.h"
#import "XZMocoaTableCellViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@class XZMocoaTableViewModel;

/// XZMocoaTableView 的视图模型基类。
@interface XZMocoaTableViewModel : XZMocoaGroupViewModel

/// 在进行批量更新或局部更新时，视图更新的动画效果，默认为 UITableViewRowAnimationAutomatic 自动选择合适的动画效果。
@property (nonatomic) UITableViewRowAnimation rowAnimation;
/// 总高度。
@property (nonatomic, readonly) CGFloat height;

- (void)didSelectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;

@end

@interface XZMocoaTableViewModel (XZMocoaTableViewModel)
/// section 视图模型集合。
@property (nonatomic, readonly) NSArray<__kindof XZMocoaTableSectionViewModel *> *sectionViewModels;
/// 获取 section 视图模型。
/// - Parameter index: 位置
- (__kindof XZMocoaTableSectionViewModel *)sectionViewModelAtIndex:(NSInteger)index;
/// 获取 cell 视图模型。
/// - Parameter indexPath: 位置
- (__kindof XZMocoaTableCellViewModel *)cellViewModelAtIndexPath:(NSIndexPath *)indexPath;
@end

NS_ASSUME_NONNULL_END
