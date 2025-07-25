//
//  XZMocoaCollectionViewController.h
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#import <UIKit/UIKit.h>
#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaCollectionView.h>
#else
#import "XZMocoaCollectionView.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewController : UICollectionViewController <XZMocoaCollectionView>
@property (nonatomic, weak) id<UICollectionViewDelegate> delegate;
@property (nonatomic, weak) id<UICollectionViewDataSource> dataSource;
@end

@interface XZMocoaCollectionViewController (XZMocoaCollectionViewModelDelegate) <XZMocoaCollectionViewModelDelegate>
@end

@interface XZMocoaCollectionViewController () <UICollectionViewDelegateFlowLayout>
@end

NS_ASSUME_NONNULL_END
