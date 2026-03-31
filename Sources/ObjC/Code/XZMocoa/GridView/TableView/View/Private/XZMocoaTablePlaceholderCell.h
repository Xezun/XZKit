//
//  XZMocoaTablePlaceholderCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableCell.h>
#else
#import "XZMocoaTableCell.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderCell : UITableViewCell <XZMocoaTableCell>
@end
#else
typedef UITableViewCell XZMocoaTablePlaceholderCell;
#endif

NS_ASSUME_NONNULL_END
