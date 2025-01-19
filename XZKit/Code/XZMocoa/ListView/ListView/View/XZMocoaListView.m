//
//  XZMocoaListView.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaListView.h"

@implementation XZMocoaListView

#pragma mark - 属性

@synthesize viewModel = _viewModel;

- (void)setViewModel:(__kindof XZMocoaListViewModel *)viewModel {
    if (_viewModel != viewModel) {
        [self viewModelWillChange];
        
        // 目前来说，没有解除注册的必要
        // [self registerCellWithModule:viewModel.module];
        _viewModel.delegate = nil;
        
        [viewModel ready];
        _viewModel = viewModel;
        
        [self registerCellWithModule:_viewModel.module];
        _viewModel.delegate = self;
        
        [self viewModelDidChange];
    }
}

- (void)viewModelWillChange {
    
}

- (void)viewModelDidChange {
    
}

@synthesize contentView = _contentView;

- (void)setContentView:(__kindof UIScrollView *)contentView {
    if (_contentView != contentView) {
        [self contentViewWillChange];
        
        [_contentView removeFromSuperview];
        _contentView = contentView;
        _contentView.frame = self.bounds;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];
        [self registerCellWithModule:self.viewModel.module];
        
        [self contentViewDidChange];
    }
}

- (void)contentViewWillChange {
    
}

- (void)contentViewDidChange {
    
}

- (void)registerCellWithModule:(XZMocoaModule *)module {
    @throw [NSException exceptionWithName:NSGenericException reason:@"必须使用子类，并重写此方法" userInfo:nil];
}

@end

