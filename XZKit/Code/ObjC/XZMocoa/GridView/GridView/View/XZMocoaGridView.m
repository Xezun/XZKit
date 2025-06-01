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
        if (_contentView.superview != self) {
            // 判断 superview 再决定是否添加，以避免从 IB 中初始化的情况下，改变视图层级
            [self addSubview:_contentView];
        }
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

