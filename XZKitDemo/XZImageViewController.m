//
//  XZImageViewController.m
//  XZKitDemo
//
//  Created by Xezun on 2021/2/16.
//

#import "XZImageViewController.h"
#import <XZKit/XZKit.h>

@interface XZImageSliderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@end

@interface XZImageViewController () {
    BOOL _isProcessing;
}

@property (nonatomic, strong) UIImage *image;

@property (weak, nonatomic) IBOutlet XZImageSliderView *shadowsLevelsView;
@property (weak, nonatomic) IBOutlet XZImageSliderView *midtonesLevelsView;
@property (weak, nonatomic) IBOutlet XZImageSliderView *highlightsLevelsView;
@property (weak, nonatomic) IBOutlet XZImageSliderView *brightnessView;
@property (weak, nonatomic) IBOutlet XZImageSliderView *alphaView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation XZImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZImage *image = [[XZImage alloc] init];
    image.size            = CGSizeMake(300, 200);
    image.backgroundImage = [UIImage imageNamed:@"icon_image"];
    image.contentMode     = UIViewContentModeScaleAspectFill;
    image.contentInsets   = UIEdgeInsetsMake(10, 10, 10, 10);
    image.backgroundColor = rgba(0x000000, 1.0);
    
    // 设置所有边框和圆角
    image.borderColor     = rgba(0xEF7B4F, 1.0);
    image.borderWidth     = 2.0;
    image.cornerRadius    = 10.0;
    //image.borderDash      = XZImageLineDashMake(10, 10);
    
    // 设置所有边框
//    image.borders.width = 10.0;
//    image.borders.color = [UIColor.redColor colorWithAlphaComponent:0.5];
    
    // 设置所有圆角
//    image.corners.width = 10.0;
//    image.corners.color = UIColor.greenColor;
//    image.corners.radius = 10;
    
//    image.borders.width = 12;
//    image.corners.width = 12;
//    image.corners.radius = 20;
    
//    image.borders.arrow.anchor = 0;
//    image.borders.arrow.vector = 20;
//    image.borders.arrow.width  = 40;
//    image.borders.arrow.height = 20;
    
//    image.borders.top.arrow.anchor = 0;
//    image.borders.top.arrow.vector = 0;
//    image.borders.top.arrow.width  = 40;
//    image.borders.top.arrow.height = 20;

    image.borders.bottom.arrow.anchor = 0;
    image.borders.bottom.arrow.vector = 0;
    image.borders.bottom.arrow.width  = 20;
    image.borders.bottom.arrow.height = 10;
    
//    image.borders.left.arrow.anchor = 0;
//    image.borders.left.arrow.vector = 0;
//    image.borders.left.arrow.width  = 20;
//    image.borders.left.arrow.height = 10;
    
//    image.borders.right.arrow.anchor = 0;
//    image.borders.right.arrow.vector = 0;
//    image.borders.right.arrow.width  = 20;
//    image.borders.right.arrow.height = 10;
    
    self.image = image.image;
    
    [self recoverImageLevelsButtonAction:nil];
    
//    self.imageView.image = [[UIImage imageNamed:@"icon_star"] xz_imageByBlendingColor:rgb(0xff9900)];
}

- (IBAction)imageLevelsChangeAction:(id)sender {
    CGFloat shadows = self.shadowsLevelsView.slider.value;
    CGFloat midtones = self.midtonesLevelsView.slider.value;
    CGFloat highlights = self.highlightsLevelsView.slider.value;
    
    self.shadowsLevelsView.valueLabel.text = [NSString stringWithFormat:@"%.2f", shadows];
    
    if (midtones < 500) {
        midtones /= 500;
    } else {
        midtones = 9.0 * (midtones - 500) / 500 + 1.0;
    }
    self.midtonesLevelsView.valueLabel.text = [NSString stringWithFormat:@"%.2f", midtones];
    
    self.highlightsLevelsView.valueLabel.text = [NSString stringWithFormat:@"%.2f", highlights];
    
    if (_isProcessing) {
        return;
    }
    
    _isProcessing = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_isProcessing = NO;
    });
    
    XZImageLevels levels = XZImageLevelsMake(shadows, midtones, highlights);
    self.imageView.image = [self.image xz_imageByFilteringImageLevels:levels];
    
//    self.imageView.image = [self.image xz_imageByFilteringBrightness:shadows];
}

- (IBAction)recoverImageLevelsButtonAction:(id)sender {
    self.shadowsLevelsView.slider.value = 0;
    self.midtonesLevelsView.slider.value = 500;
    self.highlightsLevelsView.slider.value = 1.0;
    [self imageLevelsChangeAction:nil];
}

- (IBAction)brightnessValueChangedAction:(UISlider *)sender {
    CGFloat value = self.brightnessView.slider.value;
    self.brightnessView.valueLabel.text = [NSString stringWithFormat:@"%.2f", value];
    
    if (_isProcessing) {
        return;
    }
    _isProcessing = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_isProcessing = NO;
    });
    
    self.imageView.image = [self.image xz_imageByFilteringBrightness:value];
}

- (IBAction)recoverBrightnessButtonAction:(id)sender {
    if (self.brightnessView.slider.value == 0.5) {
        return;
    }
    self.brightnessView.slider.value = 0.5;
    [self brightnessValueChangedAction:nil];
}

- (IBAction)imageAlphaValueChangedAction:(id)sender {
    CGFloat value = self.alphaView.slider.value;
    self.alphaView.valueLabel.text = [NSString stringWithFormat:@"%.2f", value];
    
    if (_isProcessing) {
        return;
    }
    _isProcessing = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_isProcessing = NO;
    });
    
    self.imageView.image = [self.image xz_imageByBlendingAlpha:value];
}

- (IBAction)recoverImageAlphaButtonAction:(id)sender {
    if (self.alphaView.slider.value == 1.0) {
        return;
    }
    self.alphaView.slider.value = 1.0;
    [self imageAlphaValueChangedAction:nil];
}

- (IBAction)imageTintColorButtonAction:(UINavigationItem *)sender {
    if (_isProcessing) {
        return;
    }
    _isProcessing = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self->_isProcessing = NO;
    });
    
    UIColor *color = rgb(arc4random());
    self.navigationController.navigationBar.tintColor = color;
    self.imageView.image = [[UIImage imageNamed:@"icon_star"] xz_imageByBlendingColor:color];
}



@end


@implementation XZImageSliderView



@end


