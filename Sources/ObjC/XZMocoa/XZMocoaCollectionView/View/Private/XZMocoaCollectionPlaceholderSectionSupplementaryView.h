//
//  XZMocoaCollectionPlaceholderSectionSupplementaryView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaCollectionSectionSupplementaryView.h>
#else
#import "XZMocoaCollectionSectionSupplementaryView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaCollectionPlaceholderSectionSupplementaryView : UICollectionReusableView <XZMocoaCollectionSectionSupplementaryView>
@end
#else
typedef UICollectionReusableView XZMocoaCollectionPlaceholderSectionSupplementaryView;
#endif

NS_ASSUME_NONNULL_END
