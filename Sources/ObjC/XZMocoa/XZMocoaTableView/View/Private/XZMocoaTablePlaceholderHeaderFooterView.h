//
//  XZMocoaTablePlaceholderSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include("XZKit.h")
#import "XZMocoaTableHeaderFooterView.h"
#else
#import <XZKit/XZMocoaTableHeaderFooterView.h>
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderHeaderFooterView : XZMocoaTableHeaderView
@end
#else
typedef UITableViewHeaderFooterView XZMocoaTablePlaceholderHeaderFooterView;
#endif

NS_ASSUME_NONNULL_END
