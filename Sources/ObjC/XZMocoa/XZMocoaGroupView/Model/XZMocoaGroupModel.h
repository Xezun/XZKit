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
/// > 视图 XZMocoaGroupView 是 UITableView、UICollectionView 抽象，并非实际视图，不能直接使用。
///
/// 协议所有方法默认不需要实现，任何 NSObject 子类对象，都可以作为列表数据模型。
///
/// 若给`NSObject`实现此协议，那么默认协议的默认实现将被覆盖，同时需实现协议中的所有方法。
@protocol XZMocoaGroupModel <XZMocoaModel>
@optional
/// 列表分区数量。默认 1 只有一个分区。
/// - Parameter context: 自定义参数
- (NSInteger)numberOfSectionsInMocoa:(void *)context;

/// 列表指定分区内单元视图的数量。默认 1 只有一个元素。
/// - Parameters:
///   - context: 自定义参数
///   - section: 分组区域
- (NSInteger)mocoa:(void *)context numberOfCellsInSection:(NSInteger)section;

/// 获取列表指定单元视图的数据模型。默认返回自身。
/// - Parameters:
///   - context: 自定义参数
///   - indexPath: 单元视图的位置
- (nullable id)mocoa:(void *)context modelForCellAtIndexPath:(NSIndexPath *)indexPath;

/// 区域内附加视图的数量。默认返回 0 无附加视图。
/// - Parameters:
///   - context: 自定义参数
///   - kind: 附加视图的类型
///   - section: 分组区域的次序
- (NSInteger)mocoa:(void *)context kind:(XZMocoaKind)kind numberOfSupplementsInSection:(NSInteger)section;

/// 获取指定位置的附加视图的数据模型。默认返回 nil 无附加视图。
/// - Parameters:
///   - context: 自定义参数
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
