//
//  XZMocoaCollectionViewPlaceholderSupplementaryView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaCollectionViewSupplementaryView.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionViewPlaceholderSupplementaryView : XZMocoaCollectionViewSupplementaryView
@end
#else
typedef XZMocoaCollectionViewSupplementaryView XZMocoaCollectionViewPlaceholderSupplementaryView;
#endif

NS_ASSUME_NONNULL_END
