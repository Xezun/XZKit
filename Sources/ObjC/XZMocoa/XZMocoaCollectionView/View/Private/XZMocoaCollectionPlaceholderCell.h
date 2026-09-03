//
//  XZMocoaCollectionPlaceholderCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionCell.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionPlaceholderCell : UICollectionViewCell
@end
#else
typedef UICollectionViewCell XZMocoaCollectionPlaceholderCell;
#endif

NS_ASSUME_NONNULL_END
