//
//  XZMocoaCollectionView.h
//  XZMocoa
//
//  Created by Xezun on 2023/7/24.
//

#import "XZMocoaListView.h"
#import "XZMocoaCollectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol XZMocoaCollectionView <XZMocoaListView>
@property (nonatomic, strong, nullable) __kindof XZMocoaCollectionViewModel *viewModel;
@property (nonatomic, strong) IBOutlet UICollectionView *contentView;
@end

@interface XZMocoaCollectionView : XZMocoaListView <XZMocoaCollectionView>
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCollectionViewClass:(Class)collectionViewClass layout:(UICollectionViewLayout *)layout NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithLayout:(UICollectionViewLayout *)layout;
- (instancetype)initWithFrame:(CGRect)frame layout:(UICollectionViewLayout *)layout;
- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, weak) id<UICollectionViewDelegate> delegate;
@property (nonatomic, weak) id<UICollectionViewDataSource> dataSource;
@end

NS_ASSUME_NONNULL_END
