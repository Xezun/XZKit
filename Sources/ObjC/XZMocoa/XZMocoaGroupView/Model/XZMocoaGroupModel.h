//
//  XZMocoaGroupModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/4/10.
//

#import <CoreData/CoreData.h>
#import "XZMocoaModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UITableViewDataSource;

/// 分组列表视图的数据模型，例如 UITableView、UICollectionView 的数据模型。
///
/// 视图 XZMocoaGroupView 是 UITableView、UICollectionView 抽象，并非实际视图，不能直接使用。
///
/// 此协议提供了默认实现，所有 NSObject 子类对象，都可以作为列表数据模型。
@protocol XZMocoaGroupModel <XZMocoaModel>
@optional
/// 列表分区数量。
- (NSInteger)numberOfSectionsInMocoa:(void *)context;

/// 列表指定分区内单元视图的数量。
/// - Parameter section: 分区
- (NSInteger)mocoa:(void *)context numberOfCellsInSection:(NSInteger)section;

/// 获取列表指定单元视图的数据模型。
/// - Parameter indexPath: 单元视图的位置
- (nullable id)mocoa:(void *)context modelForCellAtIndexPath:(NSIndexPath *)indexPath;

/// 区域内附加视图的数量。
/// - Parameters:
///   - kind: 附加视图的类型
///   - section: 区域的位置
- (NSInteger)mocoa:(void *)context kind:(XZMocoaKind)kind numberOfSupplementsInSection:(NSInteger)section;

/// 获取指定位置的附加视图的数据模型。
/// - Parameters:
///   - kind: 附加视图的类型
///   - indexPath: 附加视图的位置
- (nullable id)mocoa:(void *)context kind:(XZMocoaKind)kind modelForSupplementAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface NSObject (XZMocoaGroupModel)
@end

@interface NSArray (XZMocoaGroupModel)
@end

@interface NSFetchedResultsController (XZMocoaGroupModel)
@end

NS_ASSUME_NONNULL_END
