//
//  UIApplication+XZKit.m
//  XZKit
//
//  Created by Xezun on 2021/6/23.
//

#import "UIApplication+XZKit.h"

@implementation UIApplication (XZKit)

+ (BOOL)xz_isViewControllerBasedStatusBarAppearance {
    NSNumber *setting = NSBundle.mainBundle.infoDictionary[@"UIViewControllerBasedStatusBarAppearance"];
    if (setting != nil) {
        return setting.boolValue;
    }
    return YES;
}

- (BOOL)xz_isViewControllerBasedStatusBarAppearance {
    return UIApplication.xz_isViewControllerBasedStatusBarAppearance;
}

@end
