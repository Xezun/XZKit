//
//  XZMocoaCollectionViewController.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#import "XZMocoaCollectionViewController.h"
#import "XZMocoaCollectionViewProxy.h"

@interface XZMocoaCollectionViewController () {
    XZMocoaCollectionViewProxy *_proxy;
}

@end

@implementation XZMocoaCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _proxy = [[XZMocoaCollectionViewProxy alloc] initWithCollectionView:self];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _proxy = [[XZMocoaCollectionViewProxy alloc] initWithCollectionView:self];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _proxy = [[XZMocoaCollectionViewProxy alloc] initWithCollectionView:self];
    }
    return self;
}

@dynamic viewModel;

- (void)viewModelWillChange {
    XZMocoaCollectionViewModel * const _viewModel = self.viewModel;
    _viewModel.delegate = nil;
}

- (void)viewModelDidChange {
    XZMocoaCollectionViewModel * const _viewModel = self.viewModel;
    
    [self registerCellWithModule:_viewModel.module];
    _viewModel.delegate = _proxy;

    UICollectionView * const collectionView = self.collectionView;
    if (@available(iOS 11.0, *)) {
        if (collectionView && !collectionView.hasUncommittedUpdates) {
            [collectionView reloadData];
        }
    } else {
        [collectionView reloadData];
    }
}

- (UICollectionView *)contentView {
    return self.collectionView;
}

- (void)setContentView:(UICollectionView *)contentView {
    self.collectionView = contentView;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate   = _proxy;
    self.collectionView.dataSource = _proxy;
}

@end
