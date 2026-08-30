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
@property (nonatomic, readonly) NSInteger numberOfSections;
/// 列表指定分区内单元视图的数量。
/// - Parameter section: 分区
- (NSInteger)numberOfCellsInSection:(NSInteger)section;
/// 获取列表指定单元视图的数据模型。
/// - Parameter indexPath: 单元视图的位置
- (nullable id)modelForCellAtIndexPath:(NSIndexPath *)indexPath;
/// 区域内附加视图的数量。
/// - Parameters:
///   - kind: 附加视图的类型
///   - section: 区域的位置
- (NSInteger)numberOfSupplementsOfKind:(XZMocoaKind)kind inSection:(NSInteger)section;
/// 获取指定位置的附加视图的数据模型。
/// - Parameters:
///   - kind: 附加视图的类型
///   - indexPath: 附加视图的位置
- (nullable id)modelForSupplementOfKind:(XZMocoaKind)kind atIndexPath:(NSIndexPath *)indexPath;
@end

@interface NSObject (XZMocoaGroupModel)
/// 对象作为列表数据时，列表中子元素的数量。
@property (nonatomic, readonly) NSInteger xz_numberOfElements NS_SWIFT_NAME(numberOfElements);
/// 对象作为列表数据时，位置 index 上的子元素的数据模型。
/// - Parameter index: 子元素的位置
- (nullable id)xz_modelForElementAtIndex:(NSInteger)index NS_SWIFT_NAME(modelForElement(at:));
/// 对象作为列表 section 数据时，类型为 kind 的附加视图的数量。
/// - Parameter kind: 附加视图的类型
- (NSInteger)xz_numberOfSupplementsOfKind:(XZMocoaKind)kind NS_SWIFT_NAME(numberOfSupplements(of:));
/// 对象作为列表 section 数据时，位置 index 上，类型为 kind 的附加视图的数据模型。
/// - Parameters:
///   - kind: 附加视图的类型
///   - index: 附加视图的位置
- (nullable id)xz_modelForSupplementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index NS_SWIFT_NAME(modelForSupplement(of:at:));
@end

@interface NSArray (XZMocoaGroupModel)
@end

@interface NSFetchedResultsController (XZMocoaGroupModel)
@end

NS_ASSUME_NONNULL_END
