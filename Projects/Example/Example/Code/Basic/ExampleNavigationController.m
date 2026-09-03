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
    appearance.backgroundImage = [UIImage imageNamed:@"icon-nav-background"];
    appearance.titleTextAttributes = @{ NSForegroundColorAttributeName: UIColor.labelColor };
    appearance.shadowColor = UIColor.systemGray3Color;
    self.navigationBar.standardAppearance = appearance;
    self.navigationBar.scrollEdgeAppearance = appearance;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.presentedViewController ?: self.topViewController;
}

@end
