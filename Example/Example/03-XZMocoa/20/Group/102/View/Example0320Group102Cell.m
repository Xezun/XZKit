//
//  Example0320Group102Cell.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example0320Group102Cell.h"
#import "Example0320Group102CellViewModel.h"
@import SDWebImage;

@interface Example0320Group102Cell () <XZPageViewDelegate, XZPageViewDataSource>

@end

@implementation Example0320Group102Cell

+ (void)load {
    XZMocoa(@"https://mocoa.xezun.com/examples/20/table/102/:/").viewNibClass = self;
}

@dynamic viewModel;

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // 解决 UIScrollView 屏蔽了 cell 的点击事件的问题
    self.pageView.userInteractionEnabled = NO;
    [self addGestureRecognizer:self.pageView.panGestureRecognizer];
    
    self.pageView.isLooped = YES;
    self.pageControl.currentIndicatorShape = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 10, 6.0) cornerRadius:3.0];
    
    self.pageView.delegate = self;
    self.pageView.dataSource = self;
    [self.pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:(UIControlEventValueChanged)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)viewModelDidChange:(nullable XZMocoaViewModel *)oldValue {
    [super viewModelDidChange:oldValue];
    
    Example0320Group102CellViewModel *viewModel = self.viewModel;
    if (viewModel == nil) {
        return;
    }
    self.pageControl.numberOfPages = viewModel.images.count;
    self.pageControl.currentPage = 0;
    [self.pageView reloadData];
    self.pageView.currentPage = 0;
}

- (void)pageControlValueChanged:(XZPageControl *)pageControl {
    [self.pageView setCurrentPage:pageControl.currentPage animated:YES];
    Example0320Group102CellViewModel *viewModel = self.viewModel;
    viewModel.currentIndex = pageControl.currentPage;
}

- (NSInteger)numberOfPagesInPageView:(XZPageView *)pageView {
    Example0320Group102CellViewModel *viewModel = self.viewModel;
    return viewModel.images.count;
}

- (UIView *)pageView:(XZPageView *)pageView viewForPageAtIndex:(NSInteger)index reusingView:(UIImageView *)reusingView {
    if (reusingView == nil) {
        reusingView = [[UIImageView alloc] initWithFrame:pageView.bounds];
        reusingView.contentMode = UIViewContentModeScaleAspectFill;
    }
    Example0320Group102CellViewModel *viewModel = self.viewModel;
    [reusingView sd_setImageWithURL:viewModel.images[index]];
    return reusingView;
}

- (UIView *)pageView:(XZPageView *)pageView prepareForReusingView:(UIImageView *)reusingView {
    reusingView.image = nil;
    return reusingView;
}

- (void)pageView:(XZPageView *)pageView didShowPageAtIndex:(NSInteger)index {
    self.pageControl.currentPage = index;
    Example0320Group102CellViewModel *viewModel = self.viewModel;
    viewModel.currentIndex = index;
}

@end
