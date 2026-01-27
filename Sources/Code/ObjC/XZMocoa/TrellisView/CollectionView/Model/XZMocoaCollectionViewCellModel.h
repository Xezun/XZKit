//
//  XZMocoaCollectionViewCellModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTrellisViewCellModel.h>
#else
#import "XZMocoaTrellisViewCellModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// UICollectionView 的 cell 的数据模型。
@protocol XZMocoaCollectionViewCellModel <XZMocoaTrellisViewCellModel>
@end

NS_ASSUME_NONNULL_END
