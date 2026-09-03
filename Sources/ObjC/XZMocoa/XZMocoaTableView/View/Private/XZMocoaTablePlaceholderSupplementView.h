//
//  XZMocoaTablePlaceholderSupplementView.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/19.
//

#import "XZMocoaTableSupplementView.h"

NS_ASSUME_NONNULL_BEGIN

#if DEBUG
@interface XZMocoaTablePlaceholderSupplementView : UITableViewHeaderFooterView <XZMocoaTableSupplementView>
@end
#else
typedef UITableViewHeaderFooterView XZMocoaTablePlaceholderSupplementView;
#endif

NS_ASSUME_NONNULL_END
