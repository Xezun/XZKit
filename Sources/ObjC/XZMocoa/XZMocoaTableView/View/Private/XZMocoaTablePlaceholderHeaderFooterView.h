//
//  XZMocoaTablePlaceholderSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTableHeaderFooterView.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderHeaderView : XZMocoaTableHeaderView
@end
@interface XZMocoaTablePlaceholderFooterView : XZMocoaTableFooterView
@end
#else
typedef UITableViewHeaderFooterView XZMocoaTablePlaceholderHeaderView;
typedef UITableViewHeaderFooterView XZMocoaTablePlaceholderFooterView;
#endif

NS_ASSUME_NONNULL_END
