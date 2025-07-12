//
//  XZMocoaTableViewPlaceholderCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaTableViewCell.h>
#else
#import "XZMocoaTableViewCell.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTableViewPlaceholderCell : UITableViewCell <XZMocoaTableViewCell>
@end
#else
typedef UITableViewCell XZMocoaTableViewPlaceholderCell;
#endif

NS_ASSUME_NONNULL_END
