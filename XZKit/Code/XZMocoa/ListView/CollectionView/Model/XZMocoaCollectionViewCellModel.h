//
//  XZMocoaCollectionViewCellModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/8.
//

#import "XZMocoaModel.h"

NS_ASSUME_NONNULL_BEGIN

/// UICollectionView 的 cell 的数据模型。
@protocol XZMocoaCollectionViewCellModel <XZMocoaModel>
@end

/// 因一致性而提供，非必须基类。
/// @note 任何遵循 XZMocoaCollectionViewCellModel 协议的对象都可以作为数据模型，而非必须基于此类。
@interface XZMocoaCollectionViewCellModel : NSObject <XZMocoaCollectionViewCellModel>
@end

NS_ASSUME_NONNULL_END
