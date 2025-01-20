//
//  XZMocoaCollectionView.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/24.
//

#import "XZMocoaCollectionView.h"
#import "XZMocoaCollectionViewCell.h"
#import "XZMocoaCollectionViewSupplementaryView.h"
#import "XZMocoaCollectionViewPlaceholderCell.h"
#import "XZMocoaCollectionViewPlaceholderSupplementaryView.h"
#import "XZMocoaCollectionViewProxy.h"

@implementation XZMocoaCollectionView {
    XZMocoaCollectionViewProxy *_proxy;
}

@dynamic viewModel, contentView;

- (instancetype)initWithCoder:(NSCoder *)coder {
    return [super initWithCoder:coder];
}

- (instancetype)initWithCollectionViewClass:(Class)collectionViewClass layout:(UICollectionViewLayout *)layout {
    self = [super initWithFrame:UIScreen.mainScreen.bounds];
    if (self) {
        UICollectionView *contentView = [[collectionViewClass alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        [super setContentView:contentView];
    }
    return self;
}

- (instancetype)initWithLayout:(UICollectionViewLayout *)layout {
    return [self initWithFrame:UIScreen.mainScreen.bounds layout:layout];
}

- (instancetype)initWithFrame:(CGRect)frame layout:(UICollectionViewLayout *)layout {
    self = [self initWithCollectionViewClass:UICollectionView.class layout:layout];
    if (self) {
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    return [self initWithCollectionViewClass:UICollectionView.class layout:layout];
}

- (void)contentViewWillChange {
    [super contentViewWillChange];
    
    UICollectionView * const collectionView = self.contentView;
    collectionView.delegate = nil;
    collectionView.dataSource = nil;
}

- (void)contentViewDidChange {
    [super contentViewDidChange];
    
    UICollectionView * const collectionView = self.contentView;
    collectionView.delegate   = _proxy;
    collectionView.dataSource = _proxy;
}

- (void)viewModelDidChange {
    [super viewModelDidChange];
    
    // 刷新视图。
    UICollectionView * const collectionView = self.contentView;
    if (@available(iOS 11.0, *)) {
        if (collectionView && !collectionView.hasUncommittedUpdates) {
            [collectionView reloadData];
        }
    } else {
        [collectionView reloadData];
    }
}

- (void)registerCellWithModule:(XZMocoaModule *)module {
    [_proxy registerCellWithModule:module];
}

- (id<UICollectionViewDelegate>)delegate {
    return _proxy.delegate;
}

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate {
    _proxy.delegate = delegate;
}

- (id<UICollectionViewDataSource>)dataSource {
    return _proxy.dataSource;
}

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource {
    _proxy.dataSource = dataSource;
}

@end

