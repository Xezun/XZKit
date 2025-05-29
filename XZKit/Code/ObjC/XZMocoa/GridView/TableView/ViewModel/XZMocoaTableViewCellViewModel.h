//
//  XZMocoaTableViewCellViewModel.h
//  
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaGridViewCellViewModel.h"

@protocol XZMocoaTableViewCell;

NS_ASSUME_NONNULL_BEGIN

/// UITableViewCell 视图模型基类。
@interface XZMocoaTableViewCellViewModel : XZMocoaGridViewCellViewModel

/// 视图高度。
@property (nonatomic) CGFloat height;

@end

@interface XZMocoaTableViewCellViewModel (XZMocoaTableViewCellUpdates)

- (void)cell:(id<XZMocoaTableViewCell>)cell didUpdateForKey:(XZMocoaUpdatesKey)key atIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
