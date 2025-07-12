//
//  XZMocoaTableViewPlaceholderHeaderFooterView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableViewHeaderFooterView.h>
#else
#import "XZMocoaTableViewHeaderFooterView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTableViewPlaceholderHeaderFooterView : UITableViewHeaderFooterView <XZMocoaTableViewHeaderFooterView>
@end
#else
typedef UITableViewHeaderFooterView XZMocoaTableViewPlaceholderHeaderFooterView;
#endif

NS_ASSUME_NONNULL_END
