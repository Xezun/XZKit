//
//  XZMocoaCollectionViewCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/23.
//

#import "XZMocoaView.h"
#import "XZMocoaCollectionViewCellViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView;

/// 使用 Mocoa 时，UICollectionViewCell 应遵循本协议。
/// @note
/// UICollectionViewCell 已默认实现了本协议，如需使用仅需声明遵循协议即可。
@protocol XZMocoaCollectionViewCell <XZMocoaGridViewCell>

@optional
/// ViewModel 对象。
/// @note 监听此属性，子类不需要重写，直接方法 -viewModelDidUpdate 中操作即可。
/// @note 在设置新值时，将先从移除旧的 viewModel 上绑定的事件。
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionViewCellViewModel *viewModel;

// MARK: - 由当前 Cell 所在的 UICollectionViewCell 传递回来的事件

- (void)collectionView:(id<XZMocoaCollectionView>)collectionView didUpdateForKey:(XZMocoaUpdatesKey)key atIndexPath:(NSIndexPath *)indexPath;

@end

@interface UICollectionViewCell (XZMocoaCollectionViewCell)
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionViewCellViewModel *viewModel;
@end

NS_ASSUME_NONNULL_END
