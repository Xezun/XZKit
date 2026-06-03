//
//  XZMocoaTablePlaceholderHeaderFooterView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableHeaderFooterView.h>
#else
#import "XZMocoaTableHeaderFooterView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderHeaderFooterView : UITableViewHeaderFooterView <XZMocoaTableHeaderFooterView>
@end
#else
typedef UITableViewHeaderFooterView XZMocoaTablePlaceholderHeaderFooterView;
#endif

NS_ASSUME_NONNULL_END
