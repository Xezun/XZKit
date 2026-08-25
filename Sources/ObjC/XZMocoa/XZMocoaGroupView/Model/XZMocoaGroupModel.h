//
//  XZMocoaGroupModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/4/10.
//

#import <CoreData/CoreData.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaModel.h>
#import <XZKit/XZMocoaGroupSectionModel.h>
#else
#import "XZMocoaModel.h"
#import "XZMocoaGroupSectionModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 分组列表视图的数据模型，例如 UITableView、UICollectionView 的 Cell 视图数据模型。
///
/// 视图 XZMocoaGroupView 是 UITableView、UICollectionView 抽象，并非实际视图，不能直接使用。
@protocol XZMocoaGroupModel <XZMocoaModel>
@optional
- (NSInteger)numberOfSections;
- (NSInteger)numberOfCellsInSection:(NSInteger)section;
- (nullable id)modelForCellAtIndex:(NSInteger)index inSection:(NSInteger)section;
@end

@interface NSObject (XZMocoaGroupModel)
@end

@interface NSArray (XZMocoaGroupModel)
@end

@interface NSFetchedResultsController (XZMocoaGroupModel)
@end

NS_ASSUME_NONNULL_END
