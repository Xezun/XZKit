//
//  XZMocoaCollectionModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaListModel.h"

/// UICollectionView 的数据模型。
@protocol XZMocoaCollectionModel <XZMocoaListModel>
@end

/// 因一致性而提供，非必须基类。
/// @note 任何遵循 XZMocoaCollectionModel 协议的对象都可以作为数据模型，而非必须基于此类。
@interface XZMocoaCollectionModel : NSObject <XZMocoaCollectionModel>
@end
