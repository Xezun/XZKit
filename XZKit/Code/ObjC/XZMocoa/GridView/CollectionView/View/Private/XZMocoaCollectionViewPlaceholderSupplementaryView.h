//
//  XZMocoaCollectionViewPlaceholderSupplementaryView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionViewSupplementaryView.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionViewPlaceholderSupplementaryView : UICollectionReusableView <XZMocoaCollectionViewSupplementaryView>
@end
#else
typedef UICollectionReusableView XZMocoaCollectionViewPlaceholderSupplementaryView;
#endif

NS_ASSUME_NONNULL_END
