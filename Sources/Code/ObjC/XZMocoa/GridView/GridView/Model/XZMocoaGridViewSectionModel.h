//
//  XZMocoaGridViewSectionModel.h
//  XZMocoa
//
//  Created by Xezun on 2021/8/21.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaModel.h>
#else
#import "XZMocoaModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// 以 Cell 作为子视图的视图的数据模型。
/// 在iOS开发中，视图UITableView、UICollectionView的Section为抽象层，而没有实际的视图层，但在数据或逻辑上，该层不可少。
@protocol XZMocoaGridViewSectionModel <XZMocoaModel>

@optional
/// cell 数量。
@property (nonatomic, readonly) NSInteger numberOfCellModels;
/// cell 数据。
/// @param index 在 section 中 cell 的位置
- (nullable id)modelForCellAtIndex:(NSInteger)index;

/// 附加视图的数量，默认 0 。
/// - Parameter kind: 附加视图的类型
- (NSInteger)numberOfModelsForSupplementaryElementOfKind:(XZMocoaKind)kind;
/// 附加视图的数据。
/// - Parameters:
///   - kind: 附加视图的类型
///   - index: 附加视图的位置
- (nullable id)modelForSupplementaryElementOfKind:(XZMocoaKind)kind atIndex:(NSInteger)index;

/// Header 数据。
///
/// 当获取数据源的 header 数据时，方法``-modelForSupplementaryElementOfKind:atIndex:``会直接返回此属性。
@property (nonatomic, readonly, nullable) id headerModel;

/// Footer 数据。
///
/// 当获取数据源的 footer 数据时，方法``-modelForSupplementaryElementOfKind:atIndex:``会直接返回此属性。
@property (nonatomic, readonly, nullable) id footerModel;

@end

@interface NSObject (XZMocoaGridViewSectionModel)
@end

@interface NSArray (XZMocoaGridViewSectionModel)
@end

NS_ASSUME_NONNULL_END
