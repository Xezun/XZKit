//
//  UIColorTestsViewController.m
//  XZKitDemo
//
//  Created by Xezun on 2021/2/15.
//

#import "UIColorTestsViewController.h"
#import <XZKit/XZKit.h>

@class UIColorTestsView;
@protocol UIColorTestsViewDelegate <NSObject>
- (void)valueDidChange:(UIColorTestsView *)testsView;
@end

@interface UIColorTestsView : UIView
@property (nonatomic) NSInteger value;
@property (nonatomic, weak) id<UIColorTestsViewDelegate> delegate;
@end

@interface UIColorTestsViewController () <UIColorTestsViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *displayView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *modeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *alphaSwitch;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;

@property (strong, nonatomic) IBOutletCollection(UIColorTestsView) NSArray<UIColorTestsView *> *testsViews;
@end

@implementation UIColorTestsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.testsViews enumerateObjectsUsingBlock:^(UIColorTestsView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.delegate = self;
    }];
}

- (void)valueDidChange:(UIColorTestsView *)testsView {
    [self showColor];
}

- (IBAction)modeSegmentControlChanged:(UISegmentedControl *)sender {
    [self showColor];
}

- (IBAction)alphaSwitchChanged:(UISwitch *)sender {
    [self showColor];
}

/// 255, 167, 92, 255
- (void)showColor {
    NSInteger r = self.testsViews[0].value;
    NSInteger g = self.testsViews[1].value;
    NSInteger b = self.testsViews[2].value;
    NSInteger a = self.testsViews[3].value;
    
    self.valueLabel.text = [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX", r, g, b, a];
    
    UIColor *color = nil;
    switch (self.modeSegmentedControl.selectedSegmentIndex) {
        case 0: //
            if (self.alphaSwitch.isOn) {
                NSInteger value = (r<<24) + (g<<16) + (b<<8) + a;
                color = rgba(value);
                self.codeLabel.text = [NSString stringWithFormat:@"rgba(0x%08lX)", value];
            } else {
                NSInteger value = (r<<16) + (g<<8) + b;
                color = rgb(value);
                self.codeLabel.text = [NSString stringWithFormat:@"rgba(0x%06lX)", value];
            }
            break;
        case 1: {
            if (self.alphaSwitch.isOn) {
                NSString *value = [NSString stringWithFormat:@"color: #%02lX%02lX%02lX%02lX;", r, g, b, a];
                color = rgba(value);
                self.codeLabel.text = [NSString stringWithFormat:@"rgba(@\"%@\")", value];
            } else {
                NSString *value = [NSString stringWithFormat:@"color: #%02lX%02lX%02lX;", r, g, b];
                color = rgb(value);
                self.codeLabel.text = [NSString stringWithFormat:@"rgb(@\"%@\")", value];
            }
            break;
        }
        case 2: {
            if (self.alphaSwitch.isOn) {
                color = rgba(r, g, b, a);
                self.codeLabel.text = [NSString stringWithFormat:@"rgba(0x%02lX, 0x%02lX, 0x%02lX, 0x%02lX)", r, g, b, a];
            } else {
                color = rgb(r, g, b);
                self.codeLabel.text = [NSString stringWithFormat:@"rgb(0x%02lX, 0x%02lX,  0x%02lX)", r, g, b];
            }
            break;
        }
        case 3: {
            if (self.alphaSwitch.isOn) {
                color = rgba(r/255.0, g/255.0, b/255.0, a/255.0);
                self.codeLabel.text = [NSString stringWithFormat:@"rgba(%.2f, %.2f,  %.2f,  %.2f)", r/255.0, g/255.0, b/255.0, a/255.0];
            } else {
                color = rgb(r/255.0, g/255.0, b/255.0);
                self.codeLabel.text = [NSString stringWithFormat:@"rgb(%.2f, %.2f,  %.2f)", r/255.0, g/255.0, b/255.0];
            }
            break;
        }
        default:
            break;
    }
    
    self.displayView.backgroundColor = color;
    
    XZRGBA rgba = color.xz_rgbaValue;
    XZLog(@"%ld, %ld, %ld, %ld => %ld, %ld, %ld, %ld", r, g, b, a, rgba.red, rgba.green, rgba.blue, rgba.alpha);
}

@end


@interface UIColorTestsView ()

@property (strong, nonatomic) IBOutlet UIButton *plusButton;
@property (strong, nonatomic) IBOutlet UIButton *minusButton;
@property (strong, nonatomic) IBOutlet UISlider *slider;

@end

@implementation UIColorTestsView

- (void)setValue:(NSInteger)value {
    self.slider.value = value;
}

- (NSInteger)value {
    return self.slider.value;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.slider.value = 255;
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [self.delegate valueDidChange:self];
}

- (IBAction)minusButtonAction:(id)sender {
    self.slider.value -= 1;
    [self.delegate valueDidChange:self];
}

- (IBAction)plusButtonAction:(id)sender {
    self.slider.value += 1;
    [self.delegate valueDidChange:self];
    
}

@end
