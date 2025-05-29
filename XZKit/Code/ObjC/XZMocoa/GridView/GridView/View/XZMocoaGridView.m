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

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)oldValue {
    [super viewModelDidChange:oldValue];
    [self registerModule:self.viewModel.module];
}

@synthesize contentView = _contentView;

- (void)setContentView:(__kindof UIScrollView * const)newValue {
    UIScrollView * const oldValue = _contentView;
    if (newValue != oldValue) {
        [self contentViewWillChange:newValue];
        
        [_contentView removeFromSuperview];
        
        _contentView = newValue;
        
        _contentView.frame = self.bounds;
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_contentView];
        [self registerModule:self.viewModel.module];
        
        [self contentViewDidChange:oldValue];
    }
}

- (void)contentViewWillChange:(UIScrollView *)newValue {
    
}

- (void)contentViewDidChange:(UIScrollView *)oldValue {
    
}

- (void)registerModule:(XZMocoaModule *)module {
    @throw [NSException exceptionWithName:NSGenericException reason:@"必须使用子类，并重写此方法" userInfo:nil];
}

@end

