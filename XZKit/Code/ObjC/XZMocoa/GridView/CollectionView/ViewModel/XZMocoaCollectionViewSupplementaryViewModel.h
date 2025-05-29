//
//  XZMocoaCollectionViewSupplementaryViewModel.h
//  XZMocoa
//
//  Created by Xezun on 2023/8/9.
//

#import "XZMocoaGridViewSupplementaryViewModel.h"

@protocol XZMocoaCollectionViewSupplementaryView;

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewSupplementaryViewModel : XZMocoaGridViewSupplementaryViewModel

@property (nonatomic) CGSize size;

- (void)supplementaryView:(id<XZMocoaCollectionViewSupplementaryView>)supplementaryView didUpdateForKey:(XZMocoaUpdatesKey)key atIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
