//
//  XZMocoaCollectionViewPlaceholderCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaCollectionViewCell.h>
#else
#import "XZMocoaCollectionViewCell.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionViewPlaceholderCell : UICollectionViewCell <XZMocoaCollectionViewCell>
@end
#else
typedef UICollectionViewCell XZMocoaCollectionViewPlaceholderCell;
#endif

NS_ASSUME_NONNULL_END
