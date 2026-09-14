//
//  XZMocoaCollectionView.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/24.
//

#if __has_include(<XZKit/XZKit.h>)
#import <XZKit/XZMocoaGroupView.h>
#import <XZKit/XZMocoaCollectionViewModel.h>
#else
#import "XZMocoaGroupView.h"
#import "XZMocoaCollectionViewModel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface XZMocoaCollectionView : XZMocoaGroupView

@property (nonatomic, strong) IBOutlet UICollectionView *contentView;
@property (nonatomic, strong, nullable) XZMocoaCollectionViewModel *viewModel;

- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCollectionViewClass:(Class)collectionViewClass layout:(UICollectionViewLayout *)layout NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLayout:(UICollectionViewLayout *)layout;
- (instancetype)initWithFrame:(CGRect)frame layout:(UICollectionViewLayout *)layout;
- (instancetype)initWithFrame:(CGRect)frame;
/// 布局代理。
@property (nonatomic, weak) id<UICollectionViewDelegateFlowLayout> delegate;
@end

// 以下由 XZMocoaCollectionViewProxy 动态实现。

@interface XZMocoaCollectionView (XZMocoaCollectionView) <XZMocoaCollectionViewModelDelegate>
@end
@interface XZMocoaCollectionView (UICollectionViewDelegate) <UICollectionViewDelegate>
@end
@interface XZMocoaCollectionView (UICollectionViewDataSource) <UICollectionViewDataSource>
@end
@interface XZMocoaCollectionView (UICollectionViewDelegateFlowLayout) <UICollectionViewDelegateFlowLayout>
@end

NS_ASSUME_NONNULL_END
