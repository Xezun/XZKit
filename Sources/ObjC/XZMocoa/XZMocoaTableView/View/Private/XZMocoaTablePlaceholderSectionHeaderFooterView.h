//
//  XZMocoaTablePlaceholderSectionHeaderFooterView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableSectionHeaderFooterView.h>
#else
#import "XZMocoaTableSectionHeaderFooterView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderSectionHeaderFooterView : UITableViewHeaderFooterView <XZMocoaTableSectionHeaderFooterView>
@end
#else
typedef UITableViewHeaderFooterView XZMocoaTablePlaceholderSectionHeaderFooterView;
#endif

NS_ASSUME_NONNULL_END
