//
//  XZMocoaCollectionPlaceholderSupplementaryView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaCollectionSupplementaryView.h>
#else
#import "XZMocoaCollectionSupplementaryView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionPlaceholderSupplementaryView : UICollectionReusableView <XZMocoaCollectionSupplementaryView>
@end
#else
typedef UICollectionReusableView XZMocoaCollectionPlaceholderSupplementaryView;
#endif

NS_ASSUME_NONNULL_END
