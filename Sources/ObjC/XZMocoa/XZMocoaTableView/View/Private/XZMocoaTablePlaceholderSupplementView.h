//
//  XZMocoaTablePlaceholderSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableSupplementView.h>
#else
#import "XZMocoaTableSupplementView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderSupplementView : UITableViewHeaderFooterView <XZMocoaTableSupplementView>
@end
#else
typedef UITableViewHeaderFooterView XZMocoaTablePlaceholderSupplementView;
#endif

NS_ASSUME_NONNULL_END
