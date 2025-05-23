//
//  XZMocoaGridView.m
//  XZMocoa
//
//  Created by Xezun on 2023/7/22.
//

#import "XZMocoaGridView.h"

@implementation XZMocoaGridView

#pragma mark - 属性

@dynamic viewModel;

- (void)viewModelWillChange {
    XZMocoaGridViewModel * const _viewModel = self.viewModel;
    _viewModel.delegate = nil;
}

- (void)viewModelDidChange {
    XZMocoaGridViewModel * const _viewModel = self.viewModel;
    [self registerModule:_viewModel.module];
    _viewModel.delegate = self;
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
        [self registerModule:self.viewModel.module];
        
        [self contentViewDidChange];
    }
}

- (void)contentViewWillChange {
    
}

- (void)contentViewDidChange {
    
}

- (void)registerModule:(XZMocoaModule *)module {
    @throw [NSException exceptionWithName:NSGenericException reason:@"必须使用子类，并重写此方法" userInfo:nil];
}

@end

