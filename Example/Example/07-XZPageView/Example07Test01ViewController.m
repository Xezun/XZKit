//
//  Example07Test01ViewController.m
//  Example
//
//  Created by Xezun on 2023/7/27.
//

#import "Example07Test01ViewController.h"
@import SDWebImage;
@import XZPageControl;
@import XZPageView;
@import XZDefines;

@interface Example07Test01ViewController () <XZPageViewDelegate, XZPageViewDataSource>

@property (weak, nonatomic) IBOutlet XZPageView *pageView;
@property (weak, nonatomic) IBOutlet XZPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *pageWidthLabel;

@property (nonatomic) NSInteger count;
@property (nonatomic, copy) NSArray *imageURLs;
@end

@implementation Example07Test01ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageURLs = @[
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/df38e2b4-31bb-447f-9987-ce04368696c5.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/3b1ef5df-f143-44dd-9d36-c93867b2529c.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/108363a8-ff04-4784-9640-981183e81066.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/4677eadf-99bf-4112-8bc6-68a487a427eb.jpg"],
        [NSURL URLWithString:@"https://img.ithome.com/newsuploadfiles/focus/dd138b93-a114-4c27-b96d-e9853319907f.jpg"]
    ];
    self.count = self.imageURLs.count;
    
    self.pageControl.numberOfPages = self.count;
    self.pageControl.indicatorFillColor = UIColor.whiteColor;
    self.pageControl.currentIndicatorFillColor = UIColor.orangeColor;
    
    self.pageView.isLooped = YES;
    // self.pageView.autoPagingInterval = 5.0;
    
    self.pageView.delegate = self;
    self.pageView.dataSource = self;
    [self.pageControl addTarget:self action:@selector(pageControlDidChangeValue:) forControlEvents:(UIControlEventValueChanged)];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (NSInteger)numberOfPagesInPageView:(XZPageView *)pageView {
    return self.count;
}

- (UIView *)pageView:(XZPageView *)pageView viewForPageAtIndex:(NSInteger)index reusingView:(UIImageView *)reusingView {
    if (reusingView == nil) {
        reusingView = [[UIImageView alloc] initWithFrame:pageView.bounds];
    }
    reusingView.tag = index;
    [reusingView sd_setImageWithURL:self.imageURLs[index]];
    return reusingView;
}

- (BOOL)pageView:(XZPageView *)pageView shouldReuseView:(__kindof UIView *)reusingView {
    return YES;
}

- (void)pageView:(XZPageView *)pageView willShowView:(UIView *)view animated:(BOOL)animated {
    NSLog(@"%s, view: %ld, animated: %@", __PRETTY_FUNCTION__, view.tag, animated ? @"true" : @"false");
}

- (void)pageView:(XZPageView *)pageView didShowView:(UIView *)view animated:(BOOL)animated {
    NSLog(@"%s, view: %ld, animated: %@", __PRETTY_FUNCTION__, view.tag, animated ? @"true" : @"false");
    self.pageControl.currentPage = pageView.currentPage;
}

- (void)pageView:(XZPageView *)pageView willHideView:(UIView *)view animated:(BOOL)animated {
    NSLog(@"%s, view: %ld, animated: %@", __PRETTY_FUNCTION__, view.tag, animated ? @"true" : @"false");
}

- (void)pageView:(XZPageView *)pageView didHideView:(UIView *)view animated:(BOOL)animated {
    NSLog(@"%s, view: %ld, animated: %@", __PRETTY_FUNCTION__, view.tag, animated ? @"true" : @"false");
}

- (void)pageView:(XZPageView *)pageView didTurnPageInTransition:(CGFloat)transition {
    // XZLog(@"didTurnPageInTransition: %f", transition);
}

- (void)pageControlDidChangeValue:(XZPageControl *)pageControl {
    [self.pageView setCurrentPage:pageControl.currentPage animated:YES];
}

- (IBAction)loopableSwitchAction:(UISwitch *)sender {
    self.pageView.isLooped = sender.isOn;
}

- (IBAction)autoPagingSwitchAction:(UISwitch *)sender {
    self.pageView.autoPagingInterval = sender.isOn ? 3.0 : 0;
}

- (IBAction)countSegmentAction:(UISegmentedControl *)sender {
    NSInteger const count = sender.selectedSegmentIndex;
    self.count = count;
    [self.pageView reloadData];
    self.pageControl.numberOfPages = count;
}

- (IBAction)orientationSwitchAction:(UISwitch *)sender {
    if (sender.isOn) {
        self.pageView.orientation = XZPageViewOrientationVertical;
    } else {
        self.pageView.orientation = XZPageViewOrientationHorizontal;
    }
}

- (IBAction)widthSegmentedControlValueChanged:(UISegmentedControl *)sender {
    CGRect frame = self.pageView.superview.bounds;
    frame.size.width -= 1;
    frame.size.width += 0.1 * (sender.selectedSegmentIndex + 1);
    self.pageView.frame = frame;
    self.pageWidthLabel.text = [NSString stringWithFormat:@"%.1f", frame.size.width];
}
 
- (IBAction)contentOffsetSegmentedControlValueChanged:(UISegmentedControl *)sender {
    UIScrollView *scrollView = self.pageView;
    CGFloat const value = [[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] floatValue];
    [scrollView setContentOffset:CGPointMake(scrollView.frame.size.width * value, 0) animated:YES];
}

@end
