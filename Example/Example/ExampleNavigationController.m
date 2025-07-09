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
    
    UIImage *image = [UIImage imageNamed:@"icon-nav-background"];
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundImage = image;
        appearance.titleTextAttributes = @{ NSForegroundColorAttributeName: UIColor.labelColor };
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        [self.navigationBar setBackgroundImage:image forBarMetrics:(UIBarMetricsDefault)];
    }
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.presentedViewController ?: self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.presentedViewController ?: self.topViewController;
}

@end
