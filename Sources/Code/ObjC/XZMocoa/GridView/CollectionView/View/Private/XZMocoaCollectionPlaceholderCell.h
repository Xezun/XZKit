//
//  XZMocoaCollectionPlaceholderCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaCollectionCell.h>
#else
#import "XZMocoaCollectionCell.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionPlaceholderCell : UICollectionViewCell <XZMocoaCollectionCell>
@end
#else
typedef UICollectionViewCell XZMocoaCollectionPlaceholderCell;
#endif

NS_ASSUME_NONNULL_END
