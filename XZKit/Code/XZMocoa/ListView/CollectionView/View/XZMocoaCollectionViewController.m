//
//  XZMocoaCollectionViewController.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

#import "XZMocoaCollectionViewController.h"

@interface XZMocoaCollectionViewController ()

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self.proxy;
    self.collectionView.dataSource = self.proxy;
}

@synthesize viewModel = _viewModel;

- (void)setViewModel:(__kindof XZMocoaCollectionViewModel *)viewModel {
    if (_viewModel != viewModel) {
        [self viewModelWillChange];
        
        _viewModel.delegate = nil;
        
        _viewModel = viewModel;
        
        [self registerCellWithModule:_viewModel.module];
        _viewModel.delegate = self.proxy;
        
        [self viewModelDidChange];
    }
}

- (void)viewModelDidChange {
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
    [self.proxy registerCellWithModule:module];
}

@end
