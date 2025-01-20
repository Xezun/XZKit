//
//  XZMocoaCollectionViewController.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#import <UIKit/UIKit.h>
#import "XZMocoaCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewController : UICollectionViewController <XZMocoaCollectionView>
@property (nonatomic, weak) id<UICollectionViewDelegate> delegate;
@property (nonatomic, weak) id<UICollectionViewDataSource> dataSource;
@end

NS_ASSUME_NONNULL_END
