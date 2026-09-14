//
//  XZMocoaCollectionPlaceholderCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include("XZKit.h")
#import "XZMocoaCollectionCell.h"
#else
#import <XZKit/XZMocoaCollectionCell.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionPlaceholderCell : UICollectionViewCell
@end
#else
typedef UICollectionViewCell XZMocoaCollectionPlaceholderCell;
#endif

NS_ASSUME_NONNULL_END
