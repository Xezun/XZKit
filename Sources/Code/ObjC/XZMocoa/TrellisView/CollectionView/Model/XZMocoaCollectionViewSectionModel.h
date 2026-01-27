//
//  XZMocoaCollectionViewSectionModel.h
//  Pods
//
//  Created by Xezun on 2023/7/23.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTrellisViewSectionModel.h>
#else
#import "XZMocoaTrellisViewSectionModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// UICollectionView 的 section 层（抽象层）的数据模型。
@protocol XZMocoaCollectionViewSectionModel <XZMocoaTrellisViewSectionModel>
@end

NS_ASSUME_NONNULL_END
