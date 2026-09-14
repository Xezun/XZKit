//
//  ExampleNavigationController.m
//  Example
//
//  Created by Xezun on 2024/9/10.
//

#import "ExampleNavigationController.h"
@import XZKit;

@interface ExampleNavigationController ()

@end

@implementation ExampleNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    appearance.titleTextAttributes = @{
        NSForegroundColorAttributeName: UIColor.labelColor
    };
    if (@available(iOS 26.0, *)) {
        [appearance configureWithTransparentBackground];
    } else {
        appearance.backgroundColor = UIColor.systemBackgroundColor;
        appearance.shadowColor = UIColor.systemGray3Color;
    }
    self.navigationBar.standardAppearance = appearance;
    self.navigationBar.scrollEdgeAppearance = appearance;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.presentedViewController ?: self.topViewController;
}

@end
