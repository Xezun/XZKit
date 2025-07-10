//
//  XZMocoaGridModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/4/10.
//

#import <CoreData/CoreData.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaModel.h>
#import <XZKit/XZMocoaGridViewSectionModel.h>
#else
#import "XZMocoaModel.h"
#import "XZMocoaGridViewSectionModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 方格子视图的数据模型，例如 UITableView、UICollectionView 的 Cell 视图数据模型。
///
/// 视图 XZMocoaGridView 是 UITableView、UICollectionView 抽象，并非实际视图，不能直接使用。
@protocol XZMocoaGridModel <XZMocoaModel>
@optional
/// section 的数量。
@property (nonatomic, readonly) NSInteger numberOfSectionModels;
/// section 的数据。
/// - Parameter index: section 的位置
- (nullable id)modelForSectionAtIndex:(NSInteger)index;
@end

@interface NSObject (XZMocoaGridModel)
@end

@interface NSArray (XZMocoaGridModel)
@end

@interface NSFetchedResultsController (XZMocoaGridModel)
@end

NS_ASSUME_NONNULL_END
