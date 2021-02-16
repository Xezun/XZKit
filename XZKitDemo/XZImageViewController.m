//
//  XZImageViewController.m
//  XZKitDemo
//
//  Created by Xezun on 2021/2/16.
//

#import "XZImageViewController.h"
#import <XZKit/XZKit.h>

@interface XZImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation XZImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    XZImage image = XZImageMake(CGSizeMake(150, 150), XZColorMake(0xEEEEEEFF), XZColorMake(0xCCCCCCFF), 1, 6);
    
//    image.borders.top.color    = UIColor.blackColor.XZColor;
//    image.borders.right.color  = UIColor.greenColor.XZColor;
//    image.borders.bottom.color = UIColor.blueColor.XZColor;
//    image.borders.left.color   = UIColor.blackColor.XZColor;
    
//    image.borders.top.dash.width = 4;
//    image.borders.top.dash.space = 4;
//    
//    image.borders.left.dash.width = 4;
//    image.borders.left.dash.space = 4;
//    
//    image.borders.bottom.dash.width = 4;
//    image.borders.bottom.dash.space = 4;
//    
//    image.borders.right.dash.width = 4;
//    image.borders.right.dash.space = 4;
    
    image.borders.top.arrow = (XZImageBorderArrow){0, 0, 10, 4};
    image.borders.left.arrow = (XZImageBorderArrow){0, 0, 10, 4};
    image.borders.bottom.arrow = (XZImageBorderArrow){0, 0, 10, 4};
    image.borders.right.arrow = (XZImageBorderArrow){0, 0, 10, 4};
//    image.borders.bottom.arrow = CGRectZero;
//    image.borders.left.arrow  = CGRectZero;
//    image.borders.right.arrow = CGRectZero;
    
    self.imageView.image = [UIImage xz_imageWithXZImage:image];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
