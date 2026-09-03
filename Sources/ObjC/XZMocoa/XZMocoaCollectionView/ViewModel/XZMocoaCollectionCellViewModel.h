//
//  XZMocoaCollectionCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaGroupReusableViewModel.h"

@protocol XZMocoaCollectionView, XZMocoaCollectionCell;

NS_ASSUME_NONNULL_BEGIN

/// UICollectionViewCell 视图模型基类。
@interface XZMocoaCollectionCellViewModel : XZMocoaGroupReusableViewModel

@property (nonatomic) CGSize size;

/// 收到来自 Cell 视图的点击事件，默认不执行任何操作。
/// - Parameters:
///   - collectionView: 视图所在的容器视图
///   - cell: 发送事件的视图
///   - indexPath: 视图在容器视图中的位置
- (void)collectionViewCell:(UICollectionViewCell *)cell wasSelectedAtIndexPath:(NSIndexPath *)indexPath;

/// 收到来自 Cell 视图的点击取消事件，默认不执行任何操作。
/// - Parameters:
///   - cell: 发送事件的视图
///   - indexPath: 视图在容器视图中的位置
- (void)collectionViewCell:(UICollectionViewCell *)cell wasDeselectedAtIndexPath:(NSIndexPath *)indexPath;

/// 收到来自 Cell 视图的展示事件，默认不执行任何操作。
/// - Parameters:
///   - collectionView: 视图所在的容器视图
///   - cell: 发送事件的视图
///   - indexPath: 视图在容器视图中的位置
- (void)collectionViewCell:(UICollectionViewCell *)cell willBeDisplayedAtIndexPath:(NSIndexPath *)indexPath;

/// 收到来自 Cell 视图的隐藏事件，默认不执行任何操作。
/// - Parameters:
///   - collectionView: 视图所在的容器视图
///   - cell: 发送事件的视图
///   - indexPath: 视图在容器视图中的位置
- (void)collectionViewCell:(UICollectionViewCell *)cell wasEndedDisplayingAtIndexPath:(NSIndexPath *)indexPath;

@end


NS_ASSUME_NONNULL_END
