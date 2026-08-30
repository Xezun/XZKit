//
//  XZMocoaCollectionViewController.h
//  XZKit
//
//  Created by Xezun on 2025/1/20.
//

#import <UIKit/UIKit.h>
#import "XZMocoaCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionViewController : UICollectionViewController
@end

@interface XZMocoaCollectionViewController (XZMocoaCollectionView)
@property (nonatomic, strong, nullable) XZMocoaCollectionViewModel *viewModel;
@property (nonatomic, strong) IBOutlet UICollectionView *contentView;
- (void)prepareForModule:(nullable XZMocoaModule *)module;
@end

@interface XZMocoaCollectionViewController (UICollectionViewDelegateFlowLayout) <UICollectionViewDelegateFlowLayout>
@end

NS_ASSUME_NONNULL_END
