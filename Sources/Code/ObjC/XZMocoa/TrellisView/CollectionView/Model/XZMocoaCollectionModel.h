//
//  XZMocoaCollectionModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTrellisModel.h>
#else
#import "XZMocoaTrellisModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

/// UICollectionView 的数据模型。
@protocol XZMocoaCollectionModel <XZMocoaTrellisModel>
@end

NS_ASSUME_NONNULL_END
