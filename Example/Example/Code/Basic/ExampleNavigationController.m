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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 在 Xcode 27 + iOS 27 之后，通过 UIApplication 获取或修改状态栏的方法都不再生效。
    
    // ❌ 返回的值不再准确
    CGRect           statusBarFrame  = UIApplication.sharedApplication.statusBarFrame;
    BOOL             statusBarHidden = UIApplication.sharedApplication.statusBarHidden;
    UIStatusBarStyle statusBarStyle  = UIApplication.sharedApplication.statusBarStyle;
    // ❌ 修改样式、是否隐藏无效
    [UIApplication.sharedApplication setStatusBarHidden:YES animated:YES];
    [UIApplication.sharedApplication setStatusBarStyle:(UIStatusBarStyleLightContent)];
    
    // 在 Xcode 27 + iOS 27 之后，获取状态栏相关属性，需要通过 statusBarManager 来获取。
    // ✅ 获取 statusBarManager 可通过**正在显示中**的 view 或 window 来获取。
    UIWindowScene *windowScene = self.view.window.windowScene;
    CGRect           statusBarFrame  = windowScene.statusBarManager.statusBarFrame;
    BOOL             statusBarHidden = windowScene.statusBarManager.statusBarHidden;
    UIStatusBarStyle statusBarStyle  = windowScene.statusBarManager.statusBarStyle;
}

// Xcode 27 + iOS 27 之后，控制状态栏样式，需要在控制器中实现如下方法。
// 如下方法生效的前提是：
// 在 Info.plist 中设置 UIViewControllerBasedStatusBarAppearance = true 或移除此配置项。
// ⚠️ 注意：配置 UIViewControllerBasedStatusBarAppearance = true 之后，iOS 26 之下，也必须通过如下方法控制状态栏样式。
// 也就是控制状态栏，必须改成新的方式，旧的代码彻底无效，即使在 iOS26 以下也无效。

// ✅ 控制状态栏是否显示
- (BOOL)prefersStatusBarHidden {
    return YES;
}

// ✅ 状态栏的样式
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.presentedViewController ?: self.topViewController;
}

@end

