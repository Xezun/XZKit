//
//  XZMocoaCollectionPlaceholderSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include("XZKit.h")
#import "XZMocoaCollectionSupplementView.h"
#else
#import <XZKit/XZMocoaCollectionSupplementView.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionPlaceholderSupplementView : UICollectionReusableView
@end
#else
typedef UICollectionReusableView XZMocoaCollectionPlaceholderSupplementView;
#endif

NS_ASSUME_NONNULL_END
