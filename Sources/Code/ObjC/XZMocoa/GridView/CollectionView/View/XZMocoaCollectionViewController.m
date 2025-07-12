//
//  XZMocoaCollectionViewController.m
//  XZKit
//
//  Created by 徐臻 on 2025/1/20.
//

@import ObjectiveC;
#import "XZMocoaCollectionViewController.h"
#import "XZMocoaCollectionViewProxy.h"
#import "XZLog.h"

@interface XZMocoaCollectionViewController ()

@end

@implementation XZMocoaCollectionViewController

+ (void)initialize {
    if (self == [XZMocoaCollectionViewController class]) {
        unsigned int count = 0;
        Method *list = class_copyMethodList([XZMocoaCollectionViewProxy class], &count);
        for (unsigned int i = 0; i < count; i++) {
            Method const method = list[i];
            SEL const selector = method_getName(method);
            IMP const implemnt = method_getImplementation(method);
            const char * const types = method_getTypeEncoding(method);
            if (!class_addMethod(self, selector, implemnt, types)) {
                XZLog(@"为 %@ 添加方法 %@ 失败", self, NSStringFromSelector(selector));
            }
        }
    }
}

@dynamic viewModel;

- (UICollectionView *)contentView {
    return self.collectionView;
}

- (void)setContentView:(UICollectionView *)contentView {
    self.collectionView = contentView;
}

- (void)viewModelWillChange:(nullable XZMocoaViewModel *)newValue {
    [super viewModelWillChange:newValue];
    
    XZMocoaCollectionViewModel *_viewModel = self.viewModel;
    _viewModel.delegate = nil;
}

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)oldValue {
    [super viewModelDidChange:oldValue];
    
    XZMocoaCollectionViewModel *_viewModel = self.viewModel;
    [self registerModule:_viewModel.module];
    _viewModel.delegate = self;
    
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

@end
