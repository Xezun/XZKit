//
//  XZMocoaCollectionPlaceholderSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionSupplementView.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionPlaceholderSupplementView : UICollectionReusableView <XZMocoaCollectionSupplementView>
@end
#else
typedef UICollectionReusableView XZMocoaCollectionPlaceholderSupplementView;
#endif

NS_ASSUME_NONNULL_END
