//
//  XZMocoaCollectionView.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/24.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGridView.h>
#import <XZKit/XZMocoaCollectionViewModel.h>
#else
#import "XZMocoaGridView.h"
#import "XZMocoaCollectionViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView <XZMocoaGridView>
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionViewModel *viewModel;
@property (nonatomic, strong) IBOutlet UICollectionView *contentView;
@end

@interface XZMocoaCollectionView : XZMocoaGridView <XZMocoaCollectionView>
@property (nonatomic, strong) IBOutlet UICollectionView *contentView;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCollectionViewClass:(Class)collectionViewClass layout:(UICollectionViewLayout *)layout NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLayout:(UICollectionViewLayout *)layout;
- (instancetype)initWithFrame:(CGRect)frame layout:(UICollectionViewLayout *)layout;
- (instancetype)initWithFrame:(CGRect)frame;
@end

@interface XZMocoaCollectionView (XZMocoaCollectionViewModelDelegate) <XZMocoaCollectionViewModelDelegate>
@end

@interface XZMocoaCollectionView (UICollectionViewDelegate) <UICollectionViewDelegate>
@end

@interface XZMocoaCollectionView (UICollectionViewDataSource) <UICollectionViewDataSource>
@end

@interface XZMocoaCollectionView (UICollectionViewDelegateFlowLayout) <UICollectionViewDelegateFlowLayout>
@end

NS_ASSUME_NONNULL_END
