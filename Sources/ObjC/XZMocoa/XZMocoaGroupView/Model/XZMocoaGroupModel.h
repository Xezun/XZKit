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
/// - 协议提供了默认实现，任何`NSObject`子类对象，都可以作为列表数据模型。
/// - 为基类`NSObject`声明遵循此协议，可自定义默认规则，同时协议的默认实现将被覆盖。
/// - 数据模型实现此协议时，可通过自身的`mocoaName`来区分不同的业务场景，进行定制解析。
/// - 还可通过重写`XZMocoaGroupViewModel`的数据解析方法，来实现对数据的定制解析。
@protocol XZMocoaGroupModel <XZMocoaModel>

@optional
/// 列表分区数量。默认 1 只有一个分区。
/// - Parameters:
///   - context: 自定义参数，默认情况下，此参数为调用此方法的视图模型
///   - null: 仅占位用
- (NSInteger)mocoa:(id)context numberOfSections:(nullable id)null;

/// 列表指定分区内单元视图的数量。默认 1 只有一个元素。
/// - Parameters:
///   - context: 自定义参数，默认情况下，此参数为调用此方法的视图模型
///   - section: 分组区域
- (NSInteger)mocoa:(id)context numberOfCellsInSection:(NSInteger)section;

/// 获取列表指定单元视图的数据模型。默认返回自身。
/// - Parameters:
///   - context: 自定义参数，默认情况下，此参数为调用此方法的视图模型
///   - indexPath: 单元视图的位置
- (nullable id)mocoa:(id)context modelForCellAtIndexPath:(NSIndexPath *)indexPath;

/// 区域内附加视图的数量。默认返回 0 附加视图。
/// - Parameters:
///   - context: 自定义参数，默认情况下，此参数为调用此方法的视图模型
///   - kind: 附加视图的类型
///   - section: 分组区域的次序
- (NSInteger)mocoa:(id)context kind:(XZMocoaKind)kind numberOfSupplementsInSection:(NSInteger)section;

/// 获取指定位置的附加视图的数据模型。默认 0 无附加视图的数据模型。
/// - Parameters:
///   - context: 自定义参数，默认情况下，此参数为调用此方法的视图模型
///   - kind: 附加视图的类型
///   - indexPath: 附加视图的位置
- (nullable id)mocoa:(id)context kind:(XZMocoaKind)kind modelForSupplementAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface NSObject (XZMocoaGroupModel)
@end

@interface NSArray (XZMocoaGroupModel)
@end

@interface NSFetchedResultsController (XZMocoaGroupModel)
@end

NS_ASSUME_NONNULL_END
