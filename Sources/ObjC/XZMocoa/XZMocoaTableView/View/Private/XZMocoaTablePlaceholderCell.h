//
//  XZMocoaTablePlaceholderCell.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTableCell.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderCell : UITableViewCell
@end
#else
typedef UITableViewCell XZMocoaTablePlaceholderCell;
#endif

NS_ASSUME_NONNULL_END
