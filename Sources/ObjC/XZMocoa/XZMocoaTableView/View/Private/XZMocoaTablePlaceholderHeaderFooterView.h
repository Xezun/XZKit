//
//  XZMocoaTablePlaceholderSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTableHeaderFooterView.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderHeaderFooterView : XZMocoaTableHeaderFooterView
@end
#else
typedef UITableViewHeaderFooterView XZMocoaTablePlaceholderHeaderFooterView;
#endif

NS_ASSUME_NONNULL_END
