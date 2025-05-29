//
//  XZMocoaCollectionViewCellViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaGridViewCellViewModel.h"

@protocol XZMocoaCollectionViewCell;

NS_ASSUME_NONNULL_BEGIN

/// UICollectionViewCell 视图模型基类。
@interface XZMocoaCollectionViewCellViewModel : XZMocoaGridViewCellViewModel

@property (nonatomic) CGSize size;

@end

@interface XZMocoaCollectionViewCellViewModel (XZMocoaCollectionViewCellUpdates)

- (void)cell:(id<XZMocoaCollectionViewCell>)cell didUpdateForKey:(XZMocoaUpdatesKey)key atIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
