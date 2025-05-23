//
//  XZMocoaTableViewPlaceholderHeaderFooterView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTableViewHeaderFooterView.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTableViewPlaceholderHeaderFooterView : XZMocoaTableViewHeaderFooterView
@end
#else
typedef XZMocoaTableViewHeaderFooterView XZMocoaTableViewPlaceholderHeaderFooterView;
#endif

NS_ASSUME_NONNULL_END
