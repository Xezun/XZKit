//
//  XZMocoaCollectionViewPlaceholderCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionViewPlaceholderCell : UICollectionViewCell <XZMocoaCollectionViewCell>
@end
#else
typedef UICollectionViewCell XZMocoaCollectionViewPlaceholderCell;
#endif

NS_ASSUME_NONNULL_END
