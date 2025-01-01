//
//  XZMocoaCollectionViewPlaceholderCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionViewPlaceholderCell : XZMocoaCollectionViewCell
@end
#else
typedef XZMocoaCollectionViewCell XZMocoaCollectionViewPlaceholderCell;
#endif

NS_ASSUME_NONNULL_END
