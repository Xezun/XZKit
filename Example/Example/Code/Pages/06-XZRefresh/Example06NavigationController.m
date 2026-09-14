//
//  Example06NavigationController.m
//  Example
//
//  Created by Xezun on 2026/2/25.
//

#import "Example06NavigationController.h"
@import XZKit;

@interface Example06NavigationController ()

@end

@implementation Example06NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithTransparentBackground];
    appearance.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    appearance.shadowColor     = rgb(0xBCBCBC);
    
    UINavigationBar *navigationBar = self.navigationBar;
    navigationBar.standardAppearance = appearance;
    navigationBar.compactAppearance  = appearance;
    navigationBar.scrollEdgeAppearance = appearance;
    if (@available(iOS 15.0, *)) {
        navigationBar.compactScrollEdgeAppearance = appearance;
    }
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
