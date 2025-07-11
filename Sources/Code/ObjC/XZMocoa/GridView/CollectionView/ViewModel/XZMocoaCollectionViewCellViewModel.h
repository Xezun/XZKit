//
//  XZMocoaCollectionViewCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridViewCellViewModel.h>
#else
#import "XZMocoaGridViewCellViewModel.h"
#endif

@protocol XZMocoaCollectionView, XZMocoaCollectionViewCell;

NS_ASSUME_NONNULL_BEGIN

/// UICollectionViewCell 视图模型基类。
@interface XZMocoaCollectionViewCellViewModel : XZMocoaGridViewCellViewModel

@property (nonatomic) CGSize size;

/// 收到来自 Cell 视图的点击事件，默认不执行任何操作。
/// - Parameters:
///   - collectionView: 视图所在的容器视图
///   - cell: 发送事件的视图
///   - indexPath: 视图在容器视图中的位置
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didSelectCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/// 收到来自 Cell 视图的展示事件，默认不执行任何操作。
/// - Parameters:
///   - collectionView: 视图所在的容器视图
///   - cell: 发送事件的视图
///   - indexPath: 视图在容器视图中的位置
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView willDisplayCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

/// 收到来自 Cell 视图的隐藏事件，默认不执行任何操作。
/// - Parameters:
///   - collectionView: 视图所在的容器视图
///   - cell: 发送事件的视图
///   - indexPath: 视图在容器视图中的位置
- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath*)indexPath;

@end


NS_ASSUME_NONNULL_END
